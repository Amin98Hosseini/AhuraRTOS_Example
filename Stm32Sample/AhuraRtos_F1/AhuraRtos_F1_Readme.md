# AhuraRtos_F1 — Step-by-step STM32F103 + AhuraRTOS integration

This directory is a **sample project** that shows how to integrate
**AhuraRTOS 0.0.0** (https://github.com/AhuraRTOS/AhuraRTOS) into an
STM32CubeIDE project targeting the **STM32F103VET6** (ARM Cortex-M3)
microcontroller. It is a **legacy/sample port** — the kernel files live in
`AhuraRTOS/` and are upstream code, while the files in `Core/` are the
application-side integration layer.

The goal is to demonstrate the full bring-up path of a small preemptive
RTOS on a real Cortex-M3 device:

- HAL + CMSIS project setup
- Portability layer (exactly one port — Cortex-M3)
- Kernel configuration (`os_config.h`)
- Application callbacks (`os_cb.c`) and default task body (`os_main.c`)
- Task creation / starting / scheduling
- Tick integration via `SysTick_Handler`
- Two independent LED tasks

---

## 1. Hardware

| Item | Detail |
|---|---|
| MCU | **STM32F103VET6** — ARM Cortex-M3 |
| Speed | 72 MHz (HSE + PLL) |
| LED1 | **PC13** (output, push-pull) |
| LED2 | **PC14** (output, push-pull) — optional, for independent task observation |
| UART | USART1 (TX/RX) — logging / `os_log_output_cb` |
| Toolchain | `arm-none-eabi-gcc` (MCU ARM GCC) |
| IDE | STM32CubeIDE 2.1.1 |

The project uses the **STM32CubeMX / CubeIDE** workflow: the `.io
`, `.cproject`, `.mxproject` and generated HAL sources come from STM32CubeIDE.
`stm32f1xx_hal_timebase_tim.c` provides the HAL timebase on TIM2, so that
**SysTick is free for the kernel**.

---

## 2. Software stack

```text
STM32F103VET6
│
├── STM32CubeIDE 2.1.1
│
├── STM32 HAL + CMSIS (device ST/STM32F1xx)
│
└── AhuraRTOS 0.0.0
    ├── Kernel (portable C11 core)
    ├── Cortex-M3 port (arch/arm/cortex_m3)
    ├── Scheduler, tasks, tick
    └── Configurable features (mutex, semaphore, queue, event,
        timer, notify, heap, atomics, logging, diagnostics)
```

---

## 3. Project layout

```text
AhuraRtos_F1
│
├── Core/
│   ├── Inc/
│   │   ├── main.h
│   │   ├── os_config.h       ← the single config file (copy of template)
│   │   ├── soc_config.h      ← template for the STM32 SoC package
│   │   ├── stm32f1xx_hal_conf.h
│   │   └── stm32f1xx_it.h
│   │
│   └── Src/
│       ├── main.c            ← HAL init + kernel boot + user tasks
│       ├── os_cb.c           ← application-owned callbacks
│       ├── os_main.c         ← default application task body
│       ├── stm32f1xx_hal_msp.c
│       ├── stm32f1xx_hal_timebase_tim.c
│       ├── stm32f1xx_it.c    ← SysTick_Handler → os_tick_handler()
│       ├── syscalls.c
│       ├── sysmem.c
│       ├── system_stm32f1xx.c
│       └── stm32f1xx_it.h
│
├── Drivers/
│   ├── CMSIS/Device/ST/STM32F1xx/
│   └── STM32F1xx_HAL_Driver/
│
├── AhuraRTOS/                ← upstream kernel repository
│   ├── kernel/
│   │   ├── ahura.h
│   │   ├── core/             ← scheduler, sync/IPC, timers, heap, log
│   │   ├── arch/arm/cortex_m3/ ← the port
│   │   ├── soc/st/stm32/     ← STM32 SoC package
│   │   └── template/         ← os_config.h, os_cb.c, os_main.c
│   ├── doc/, examples/, tools/
│   └── README.md
│
├── STM32F103VETX_FLASH.ld
├── .cproject, .mxproject, .project
├── .settings/
└── Debug/
```

---

## 4. Creating the project

1. Launch STM32CubeIDE and create a new STM32 project.
2. Select **STM32F103VET6** (or a board using a compatible MCU).
3. Name the project `AhuraRtos_F1`.
4. Generate code. Make sure:
   - **System Core → NVIC → Code generation** does **not** generate a
     `PendSV_Handler` stub (the kernel defines it). If your generator does
     emit one, disable it in the `.ioc` before generating.
   - **System Core → SYS → Timebase Source → TIM2** (or any spare timer)
     — this moves the HAL timebase off SysTick so the kernel owns it.
   - **USART1** is enabled so logging works.
5. Add the two LEDs (PC13, PC14) as GPIO outputs.

---

## 5. HAL / GPIO configuration

### LED output (PC13, PC14)

```c
GPIO_InitTypeDef GPIO_InitStruct = {0};

__HAL_RCC_GPIOC_CLK_ENABLE();

GPIO_InitStruct.Pin = GPIO_PIN_13 | GPIO_PIN_14;
GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
GPIO_InitStruct.Pull = GPIO_NOPULL;
GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;

HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);
```

`main.c` already contains this (in `MX_GPIO_Init()`).

### UART1

```c
huart1.Instance = USART1;
huart1.Init.BaudRate = 115200;
huart1.Init.WordLength = UART_WORDLENGTH_8B;
huart1.Init.StopBits = UART_STOPBITS_1;
huart1.Init.Parity = UART_PARITY_NONE;
huart1.Init.Mode = UART_MODE_TX_RX;
huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
huart1.Init.OverSampling = UART_OVERSAMPLING_16;

HAL_UART_Init(&huart1);
```

The generated `syscalls.c` provides `_write()` that forwards to
`__io_putchar`, so `printf` / `os_log_output_cb` reach the ST-LINK virtual
COM port at 115200 8N1.

### TIM2 timebase (HAL)

`stm32f1xx_hal_timebase_tim.c` configures TIM2 to call `HAL_IncTick()` at
1 kHz. This is **required**: if the HAL owned SysTick (`HAL_GetTick()`
capped it), the kernel would fight the HAL over the same interrupt.

---

## 6. AhuraRTOS setup steps

### Step 1 — Add the kernel

Copy the upstream repository into your project:

```bash
git clone https://github.com/AhuraRTOS/AhuraRTOS.git
cp -r AhuraRTOS Stm32Sample/AhuraRtos_F1/AhuraRTOS
```

The kernel must be reachable by the build (the generated makefile already
includes `AhuraRTOS/kernel/...`).

### Step 2 — Configuration (`Core/Inc/os_config.h`)

Copy `AhuraRTOS/kernel/template/os_config.h` into `Core/Inc/` — which is
already done. This is the **single source of configuration**. Key defaults
in this project:

| Define | Value | Meaning |
|---|---|---|
| `OS_CONFIG_TICK_HZ` | 1000 | Tick period 1 ms |
| `OS_CONFIG_TICK_SOURCE` | `OS_CONFIG_TICK_SOURCE_SYSTICK` | SysTick is the tick |
| `OS_CONFIG_TIME_SLICE_TICKS` | 1 | Round-robin every tick |
| `OS_CONFIG_MAX_USER_TASKS` | 8 | User task slots |
| `OS_CONFIG_MIN_STACK_SIZE` | 256 | Min stack bytes |
| `OS_CONFIG_STACK_CHECK_ENABLE` | 1 | Stack-overflow detection |
| `OS_CONFIG_MAIN_TASK_STACK_SIZE` | 1024 | Default app task stack |
| `OS_CONFIG_MAX_SYSCALL_IRQ_PRIORITY` | 0 | Mask everything at boot |
| `OS_CONFIG_MUTEX_ENABLE` | 1 | Priority-inheriting mutexes |
| `OS_CONFIG_SEMAPHORE_ENABLE` | 1 | Counting semaphores |
| `OS_CONFIG_QUEUE_ENABLE` | 1 | Fixed-item-size queues |
| `OS_CONFIG_EVENT_ENABLE` | 1 | Event bit groups |
| `OS_CONFIG_TIMER_ENABLE` | 1 | Software timers |
| `OS_CONFIG_TIMER_STACK_SIZE` | 512 | Timer service stack |
| `OS_CONFIG_TIMER_PRIORITY` | `OS_TASK_PRIO_MAX` | Timer task priority |
| `OS_CONFIG_NOTIFY_ENABLE` | 1 | Per-task notifications |
| `OS_CONFIG_ALLOC_ENABLE` | 1 | Kernel heap (4096 bytes) |
| `OS_CONFIG_ATOMIC_ENABLE` | 1 | Atomic operations |
| `OS_CONFIG_STACK_WATERMARK_ENABLE` | 1 | Stack-usage diagnostics |
| `OS_CONFIG_CPU_USAGE_ENABLE` | 1 | CPU-load sampling |
| `OS_CONFIG_ASSERT_ENABLE` | 1 | `OS_ASSERT` + deadlock detection |
| `OS_CONFIG_LOG_ENABLE` | 1 | Buffered logging |
| `OS_CONFIG_TEST_ENABLE` | 0 | Self-test suite (off) |
| `OS_CONFIG_TRUSTZONE` | disabled | TrustZone (not on M3) |
| `OS_CONFIG_CORE_COUNT` | 1 | Single core |

### Step 3 — Application callbacks (`Core/Src/os_cb.c`)

This file holds the three callbacks the kernel **declares but does not
define**:

- `os_assert_failed_cb(file, line)` — reports a failing `OS_ASSERT`.
- `os_stack_overflow_cb(task_name)` — reports a stack overflow.
- `os_log_output_cb(data, length)` — transmits a finished log line.

In this project `os_log_output_cb` is a no-op placeholder; connect it to
`HAL_UART_Transmit()` or `printf` for real logging.

### Step 4 — Default application task (`Core/Src/os_main.c`)

`os_main()` is the body of the **default application task** that `os_init()`
creates for you. This project leaves it as a placeholder that just sleeps
(`os_delay_ms(1000U)`). Your own code goes here.

### Step 5 — Add the two LED tasks (`Core/Src/main.c`)

Tasks are declared with `OS_TASK_DEFINE` and started with
`OS_TASK_CONFIG` + `os_task_create`/`os_task_start`:

```c
#include "main.h"
#include "ahura.h"

OS_TASK_DEFINE(led1_task, 512U);
OS_TASK_DEFINE(led2_task, 512U);

void LED1_Task(void *arg)
{
    (void)arg;

    while (1)
    {
        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
        os_delay_ms(100);
    }
}

void LED2_Task(void *arg)
{
    (void)arg;

    while (1)
    {
        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);
        os_delay_ms(200);
    }
}

int main(void)
{
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();
    MX_USART1_UART_Init();

    os_init();

    os_task_create(&led1_task,
        OS_TASK_CONFIG(LED1_Task, NULL, OS_TASK_PRIO_10));
    os_task_create(&led2_task,
        OS_TASK_CONFIG(LED2_Task, NULL, OS_TASK_PRIO_5));

    os_task_start(&led1_task);
    os_task_start(&led2_task);

    os_start();   /* never returns — the scheduler now runs */

    while (1) {}
}
```

Important points:

- `os_init()` **creates and starts** the default application task, so no
  task needs to be created just to start.
- `os_start()` **never returns**; control passes to the scheduler.
- Tasks are created *before* `os_start()`; tasks you need only after the
  scheduler runs can be created inside `os_main()`.

### Step 6 — Tick integration (`Core/Src/stm32f1xx_it.c`)

The kernel needs `os_tick_handler()` called at `OS_CONFIG_TICK_HZ`
(1000 Hz). On Cortex-M3 the port programs **SysTick** itself:

```c
void SysTick_Handler(void)
{
    os_tick_handler();   /* one call per tick */
}
```

This is the single most important integration line. Do **not** call
`HAL_IncTick()` from `SysTick_Handler` (the HAL timebase lives in TIM2).

### Step 7 — Build and flash

Open the project in STM32CubeIDE and build **Debug**. Flash
`Debug/AhuraRtos_F1.elf` over the ST-LINK. The two LEDs blink at different
rates (100 ms vs 200 ms on PC13):

- **LED1** toggles every **100 ms** (higher priority, shorter delay)
- **LED2** toggles every **200 ms** (lower priority)

With PC14, the second LED gives independent task observability.

---

## 7. What the kernel provides

The AhuraRTOS kernel is **preemptive, priority-based**, with 31 user
priority levels (1 = lowest, 30 = highest; 0 = idle task, 31 = kernel max).
It ships the following subsystems:

| Subsystem | API |
|---|---|
| Tasks | `os_task_create`, `os_task_start`, `os_task_pause`, `os_task_delete`, `os_task_yield`, `os_task_state_get`, `os_task_priority_set/get` |
| Delay / time | `os_delay_ms`, `os_delay_us`, `os_tick_get` |
| Critical sections | `os_critical_enter`, `os_critical_exit` |
| Scheduler lock | `os_kernel_lock`, `os_kernel_unlock`, `os_kernel_is_locked` |
| Mutex | `os_mutex_init`, `os_mutex_lock`, `os_mutex_unlock` (priority inheritance, deadlock detection) |
| Semaphore | `os_semaphore_init`, `os_semaphore_give`, `os_semaphore_take` |
| Queue | `OS_QUEUE_DEFINE_STATIC/BUFFER/DYNAMIC`, `os_queue_send/receive/cleanup` |
| Event | `os_event_init`, `os_event_set_bits`, `os_event_clear_bits`, `os_event_wait_bits` |
| Notification | `os_notify_give`, `os_notify_wait` |
| Timer | `os_timer_start`, `os_timer_restart`, `os_timer_pause`, `os_timer_stop`, `os_timer_period_set`, `os_timer_callback_set` |
| Deferred call | `os_timer_submit`, `OS_TIMER_DEFINE_SUBMIT` |
| Heap | `os_mem_alloc`, `os_mem_free`, `os_mem_free_get`, `os_mem_watermark_get` |
| Diagnostics | `os_task_stack_watermark_get`, `os_cpu_usage_get`, `os_stack_overflow_cb` |
| Logging | `OS_LOG_ERROR/WARN/INFO/DEBUG`, `os_log_write`, `os_log_dropped_get` |
| List | `os_list_init`, `os_list_push_back`, `os_list_pop_front`, `os_list_remove` |
| Atomics | `os_atomic_*` (14 operations) |

### Task priorities

```text
OS_TASK_PRIO_IDLE      = 0   (kernel idle task)
OS_TASK_PRIO_1_LOWEST  = 1   (lowest user level)
OS_TASK_PRIO_1 … OS_TASK_PRIO_30  = 1..30  (user levels)
OS_TASK_PRIO_30_HIGHEST = 30
OS_TASK_PRIO_MAX       = 31  (kernel service tasks)
```

### Example: two tasks with different priorities

```c
void LED1_Task(void *arg)
{
    (void)arg;
    while (1)
    {
        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
        os_delay_ms(100);
    }
}

void LED2_Task(void *arg)
{
    (void)arg;
    while (1)
    {
        HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);
        os_delay_ms(200);
    }
}
```

`LED1` runs at priority 10, `LED2` at priority 5. When `LED1` blocks in
`os_delay_ms(100)`, the scheduler immediately runs `LED2`. If both run at
the same priority, `OS_CONFIG_TIME_SLICE_TICKS` governs how long each gets
before a round-robin switch.

---

## 8. Common errors and how this project fixes them

### Error 1 — Multiple Definition of port symbols (e.g. `os_arch_atomic_exchange`, `PendSV_Handler`)

**Cause:** the Cortex-M3 port implementation was compiled more than once —
usually because the project accidentally added both
`AhuraRTOS/kernel/arch/arm/cortex_m3/` and its `common/` sibling, or a
generated `PendSV_Handler` stub conflicts with the kernel's port.

**Fix:** build exactly **one** architecture port. Keep the generated
`PendSV_Handler` from being duplicated (disable it in the `.ioc` if your
CubeMX version emits it), and ensure only `os_arch_port.c` is in the
build.

### Error 2 — `void LED1_Task(void)` incompatible with `void (*entry)(void *)`

**Cause:** the kernel expects every task entry to take a `void *context`
argument. A `void task(void)` (no parameter) does not match the prototype.

**Fix:** define tasks as

```c
void LED1_Task(void *arg)
{
    (void)arg;   /* unused argument — required by the ABI */
    ...
}
```

### Error 3 — `os_task_config_t has no member named 'stack'`, `'stack_size'`, `'name'`

**Cause:** older or different RTOS-style task configuration structs were
assumed. AhuraRTOS decouples the **what/where** of a task (name, stack) from
the **what-it-does** (entry, context, priority) using the macros
`OS_TASK_DEFINE` and `OS_TASK_CONFIG`.

**Fix:** declare tasks with `OS_TASK_DEFINE(led1_task, 512U)` and start
them with `OS_TASK_CONFIG(LED1_Task, NULL, OS_TASK_PRIO_10)` — exactly as
done in `main.c`.

### Error 4 — LED turns on, then stops changing

**Cause:** the tick was not reaching the kernel. `os_delay_ms()` works by
counting ticks; without a tick, the blocked task never gets unblocked.

**Fix:** verify `SysTick_Handler` in `stm32f1xx_it.c` calls
`os_tick_handler()`. Also confirm `OS_CONFIG_TICK_SOURCE` is
`OS_CONFIG_TICK_SOURCE_SYSTICK`.

### Error 5 — No output on the UART

**Cause:** under Newlib, `stdout` may be fully buffered. The generated
`syscalls.c` provides `_write()` → `__io_putchar`, which is sufficient on
CubeIDE projects. If output is still silent, call
`setvbuf(stdout, NULL, _IONBF, 0);` in `main()` before `os_init()`.

---

## 9. Project startup sequence

```text
STM32F103
    │
    ▼
HAL_Init()
    │
    ▼
SystemClock_Config()
    │
    ▼
GPIO Init
    │
    ▼
UART Init
    │
    ▼
os_init()                 ← idle + service tasks + default app task + tick
    │
    ├── os_task_create(led1_task, …)
    ├── os_task_create(led2_task, …)
    ├── os_task_start(led1_task)
    ├── os_task_start(led2_task)
    │
    ▼
os_start()                ← scheduler owns the CPU; never returns
    │
    ▼
Scheduler ──► LED1 Task (prio 10) ──► os_delay_ms() ──► sleeping
    │
    ▼
Scheduler ──► LED2 Task (prio 5)  ──► os_delay_ms() ──► sleeping
    │
    ▼
SysTick_Handler ──► os_tick_handler() ──► scheduler wakes blocked tasks
```

---

## 10. Files and their roles

| File | Role |
|---|---|
| `Core/Src/main.c` | HAL init, boot (`os_init` → `os_start`), task definitions |
| `Core/Src/os_cb.c` | Application-owned callbacks (assert, overflow, log output) |
| `Core/Src/os_main.c` | Default application task body (overridable template) |
| `Core/Src/stm32f1xx_it.c` | `SysTick_Handler` → `os_tick_handler()` |
| `Core/Inc/os_config.h` | Kernel configuration (single source of truth) |
| `Core/Inc/soc_config.h` | STM32 SoC package configuration |
| `AhuraRTOS/kernel/` | Upstream kernel source |
| `STM32F103VETX_FLASH.ld` | Linker script (512 KB FLASH / 64 KB RAM) |

---

## 11. Notes on this being a sample/legacy port

- The kernel version in this tree is **0.0.0** (pre-1.0, early
  development). The API is functional but may still change.
- The Cortex-M3 port is a thin wrapper around the shared ARMv7-M
  implementation (`os_arch_port_v7m.c`), compiled once. No HAL or CMSIS
  headers are needed from the kernel itself.
- The project deliberately keeps the kernel **unchanged**; all target
  knowledge (configuration, callbacks, task code) lives in `Core/`.
- To reuse this project as a template, copy `AhuraRTOS/kernel/template/`
  over `Core/Inc/os_config.h`, `Core/Src/os_cb.c`, `Core/Src/os_main.c`
  and adjust the paths in your build system.
