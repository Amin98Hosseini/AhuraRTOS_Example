# AhuraRTOS_Example

Example firmware that integrates **AhuraRTOS** 0.0.0 into an STM32CubeIDE
project for the **STM32F103VET6** (ARM Cortex-M3) microcontroller. It is a
**sample/legacy port** of the AhuraRTOS repository — the kernel in
`AhuraRTOS/` is the upstream open-source RTOS at
https://github.com/AhuraRTOS/AhuraRTOS.

## What this project demonstrates

- Bare-metal STM32CubeMX project layout (HAL, CMSIS, linker script).
- Portability layer: exactly one architecture port (`cortex_m3`),
  `AhuraRTOS/kernel/arch/arm/cortex_m3/os_arch_port.c`.
- Configurable scheduler: tasks, priorities, round-robin time slice.
- Tick integration through `SysTick_Handler -> os_tick_handler()`.
- Multi-tasking with two LED tasks on different GPIOs.
- Kernel features enabled by default: mutexes, counting semaphores, queues,
  events, software timers, task notifications, kernel heap, atomics,
  stack watermark, CPU usage, assertions, buffered logging.

## Repository layout

```text
AhuraRtos_F1/
├── Core/
│   ├── Inc/
│   │   ├── main.h
│   │   ├── os_config.h        # copy of kernel/template/os_config.h
│   │   ├── soc_config.h       # template for the STM32 SoC package
│   │   ├── stm32f1xx_hal_conf.h
│   │   └── stm32f1xx_it.h
│   └── Src/
│       ├── main.c
│       ├── os_cb.c            # copy of kernel/template/os_cb.c
│       ├── os_main.c          # copy of kernel/template/os_main.c
│       ├── stm32f1xx_hal_msp.c
│       ├── stm32f1xx_hal_timebase_tim.c
│       ├── stm32f1xx_it.c
│       ├── syscalls.c
│       ├── sysmem.c
│       ├── system_stm32f1xx.c
│       └── stm32f1xx_it.h
├── Drivers/
│   ├── CMSIS/
│   └── STM32F1xx_HAL_Driver/
├── AhuraRTOS/                 # the kernel (upstream AhuraRTOS repo)
│   ├── kernel/
│   │   ├── ahura.h
│   │   ├── core/
│   │   ├── arch/arm/cortex_m3/
│   │   ├── soc/ (optional)
│   │   └── template/
│   ├── doc/
│   ├── examples/
│   └── tools/
├── Debug/
├── STM32F103VETX_FLASH.ld
└── .cproject, .mxproject, .project, .settings/
```

## Hardware

- **MCU:** STM32F103VET6 (ARM Cortex-M3)
- **Clock:** 72 MHz (HSE, PLL)
- **IO:**
  - LED1 on **PC13**
  - LED2 on **PC14** (second LED for independent task observability)
  - UART1 (TX/RX) for logging (`os_log_output_cb` / printf)
- **Development board:** STMicroelectronics Nucleo-F103RB (or any board
  with PC13/PC14 and a UART).

## Software

- STM32CubeIDE 2.1.1 (project created with the CubeMX toolchain)
- `arm-none-eabi-gcc` (MCU ARM GCC toolchain, 14.3.rel1)
- STM32F1 HAL driver

## Build / Run

Open the workspace in STM32CubeIDE and build the **Debug** configuration
(ARM-GCC). The top-level makefile (`Core/Src/makefile` / `Debug/makefile`)
compiles the application together with the kernel library under
`AhuraRTOS/`. Flash the resulting `AhuraRtos_F1.elf` via the ST-LINK
debugger.

## How the kernel is integrated

1. `AhuraRTOS/kernel/` is the copy of the upstream kernel repository.
2. `Core/Inc/os_config.h` — the **single source of configuration** (copied
   from `AhuraRTOS/kernel/template/os_config.h`).
3. `Core/Src/os_cb.c` — application-owned callbacks (assert,
   stack-overflow, log output).
4. `Core/Src/os_main.c` — default application task body (`os_main()`).
5. Driver include paths in `.cproject` cover
   `AhuraRTOS/kernel/` (for `ahura.h`), `AhuraRTOS/kernel/arch/arm/cortex_m3/`
   (for `os_arch_port.h`), and `Core/Inc/` (for `os_config.h`).
6. The build compiles `AhuraRTOS/kernel/soc/st/stm32/` for the STM32
   SoC-provided callbacks.

## Kernel configuration (`os_config.h`)

All settings live in `Core/Inc/os_config.h` and mirror the upstream
defaults:

| Option | Value | Meaning |
|---|---|---|
| `OS_CONFIG_TICK_HZ` | 1000 | Kernel tick frequency |
| `OS_CONFIG_TICK_SOURCE` | `OS_CONFIG_TICK_SOURCE_SYSTICK` | SysTick drives the tick |
| `OS_CONFIG_TIME_SLICE_TICKS` | 1 | Round-robin quantum per tick |
| `OS_CONFIG_MAX_USER_TASKS` | 8 | User task slots |
| `OS_CONFIG_MIN_STACK_SIZE` | 256 | Minimum stack (bytes) |
| `OS_CONFIG_STACK_CHECK_ENABLE` | 1 | Stack-overflow detection |
| `OS_CONFIG_MAIN_TASK_STACK_SIZE` | 1024 | Default app task stack |
| `OS_CONFIG_MAX_SYSCALL_IRQ_PRIORITY` | 0 | Zero-latency interrupt zone |
| `OS_CONFIG_MUTEX_ENABLE` | 1 | Priority-inheriting mutexes |
| `OS_CONFIG_SEMAPHORE_ENABLE` | 1 | Counting semaphores |
| `OS_CONFIG_QUEUE_ENABLE` | 1 | Fixed-size queues |
| `OS_CONFIG_EVENT_ENABLE` | 1 | Event bit flags |
| `OS_CONFIG_TIMER_ENABLE` | 1 | Software timers |
| `OS_CONFIG_TIMER_STACK_SIZE` | 512 | Timer service task stack |
| `OS_CONFIG_TIMER_PRIORITY` | `OS_TASK_PRIO_MAX` | Timer service priority |
| `OS_CONFIG_NOTIFY_ENABLE` | 1 | Task notifications |
| `OS_CONFIG_ALLOC_ENABLE` | 1 | Kernel heap (4 KiB) |
| `OS_CONFIG_ATOMIC_ENABLE` | 1 | Atomic word operations |
| `OS_CONFIG_STACK_WATERMARK_ENABLE` | 1 | Stack usage diagnostics |
| `OS_CONFIG_CPU_USAGE_ENABLE` | 1 | CPU-load sampling |
| `OS_CONFIG_ASSERT_ENABLE` | 1 | `OS_ASSERT` + deadlock detection |
| `OS_CONFIG_LOG_ENABLE` | 1 | Buffered logging |
| `OS_CONFIG_TEST_ENABLE` | 0 | Self-test suite (off) |
| `OS_CONFIG_TRUSTZONE` | disabled | TrustZone (M3 does not have it) |
| `OS_CONFIG_CORE_COUNT` | 1 | Single-core scheduler |

## Tasks and API used in this project

The two application tasks are declared with the kernel macros:

```c
OS_TASK_DEFINE(led1_task, 512U);
OS_TASK_DEFINE(led2_task, 512U);
```

- `os_init()` — initialize the kernel (idle + service tasks, default app
  task, tick).
- `os_task_create(&task, OS_TASK_CONFIG(entry, ctx, prio))` — create a task.
  Signature: `OS_TASK_CONFIG(led1_task, NULL, OS_TASK_PRIO_10)`.
- `os_task_start(&task)` — make a created task ready.
- `os_task_yield()` — voluntarily give up the CPU.
- `os_delay_ms(ms)` — block the calling task.
- `os_start()` — start the scheduler; does not return.

SysTick is the kernel tick source (see `stm32f1xx_it.c`):

```c
void SysTick_Handler(void)
{
    os_tick_handler();      /* one call per tick */
}
```

## Troubleshooting

- **Multiple definition of PendSV_Handler / os_arch_atomic_*** — the
  Cortex-M3 port file was included twice. STM32CubeIDE projects may also
  contain a generated `PendSV_Handler` stub in `Core/Src/stm32f1xx_it.c`;
  keep exactly one definition (disable the generated one).
- **LED on but not toggling** — the SysTick tick was not routed to
  `os_tick_handler()`. See `stm32f1xx_it.c`.
- **No output over UART** — `syscalls.c` must provide `_write()` to
  `file == 1` (stdout). The generated file does this via `__io_putchar`.
- **Clock/tick mismatch** — `os_init()` programs the tick from the live
  `SystemCoreClock` variable, so run `SystemCoreClockUpdate()` before
  calling `os_init()`.

## Notes

- This is a **sample/legacy** port of AhuraRTOS (`0.0.0`). The kernel is
  functional and self-tests, but the API may still change; not recommended
  for production.
- No HAL, no CMSIS dependency, no linker-script edits are required by the
  kernel itself, but this sample uses the STM32 HAL and CMSIS device
  headers for the port and peripheral setup.
