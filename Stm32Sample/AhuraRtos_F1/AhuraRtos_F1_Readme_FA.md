# راه‌اندازی مرحله‌به‌مرحله AhuraRTOS روی STM32F103 با STM32CubeIDE

در این آموزش قصد داریم یک پروژه واقعی مبتنی بر STM32F103VET6 ایجاد کنیم و در آن سیستم‌عامل بلادرنگ AhuraRTOS را راه‌اندازی کنیم.

هدف این آموزش فقط اجرای یک LED نیست؛ بلکه در طول مراحل، نحوه‌ی اتصال لایه سخت‌افزار STM32 به Kernel سیستم‌عامل، راه‌اندازی Scheduler، مدیریت Tick، ایجاد Task و در نهایت اجرای همزمان چند Task را بررسی خواهیم کرد.

در پایان آموزش، دو Task independientes ایجاد خواهیم کرد که هرکدام یک LED را با زمان‌بندی متفاوت کنترل می‌کنند.

## ساختار کلی پروژه

STM32F103VET6
      │
      ├── STM32CubeIDE
      │
      ├── HAL
      └── AhuraRTOS
             │
             ├── Kernel
             ├── Scheduler
             ├── SysTick
             ├── Task Management
             └── Context Switching
                    │
                    ├── LED1 Task
                    └── LED2 Task

## 1. سخت‌افزار مورد استفاده

در این پروژه از میکروکنترلر زیر استفاده شده است:

**STM32F103VET6**

پردازنده این famiglia از هسته:
**ARM Cortex-M3**

برای تست اولیه، از LEDهای متصل به GPIO استفاده می‌کنیم.

در مرحله اول از:
**PC13**

استفاده شد.

در تست نهایی پیشنهاد می‌شود LED دوم نیز روی یک GPIO دیگر مانند:
**PC14**

قرار بگیرد تا اجرای مستقل Taskها قابل مشاهده باشد.

## 2. نرم‌افزار مورد استفاده

محیط توسعه:
**STM32CubeIDE 2.1.1**

Toolchain:
**arm-none-eabi-gcc**

و معماری پردازنده:
**Cortex-M3**

پروژه نیز با HAL مربوط به STM32F1 توسعه داده شده است.

## 3. ایجاد پروژه STM32

ابتدا STM32CubeIDE را اجرا کرده و یک پروژه جدید ایجاد می‌کنیم.

از منوی:
File
   ↓
New
   ↓
STM32 Project

میکروکنترلر مورد نظر را انتخاب می‌کنیم:
**STM32F103VET6**

یا در صورت استفاده از بردی که از MCU مشابه استفاده می‌کند، MCU متناظر را انتخاب کنید.

نام پروژه را مثلاً:
**AhuraRtos_F1**

قرار می‌دهیم.

## 4. تنظیم GPIO برای LED

برای تست اولیه، پایه:
**PC13**

را به صورت خروجی تنظیم می‌کنیم.

تنظیمات:
Mode: GPIO_Output
Output: Push-Pull

در نهایت CubeIDE کدی مشابه زیر تولید می‌کند:

```c
GPIO_InitTypeDef GPIO_InitStruct = {0};


__HAL_RCC_GPIOC_CLK_ENABLE();


HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);


GPIO_InitStruct.Pin = GPIO_PIN_13;
GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
GPIO_InitStruct.Pull = GPIO_NOPULL;
GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;


HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);
```

## 5. تست اولیه بدون RTOS

قبل از اضافه کردن AhuraRTOS، ابتدا باید مطمئن شویم که سخت‌افزار و GPIO به‌درستی کار می‌کنند.

برای این کار می‌توانیم از کد ساده زیر استفاده کنیم:

```c
while (1)
{
    HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
    HAL_Delay(500);
}
```

اگر LED چشمک بزند، یعنی:
Clock
  ↓
HAL
  ↓
GPIO
  ↓
LED

همگی به درستی کار می‌کنند.

اینTEST بسیار مهم است، زیرا قبل از ورود RTOS باید مطمئن شویم مشکل سخت‌افزاری یا HAL نداریم.

در پروژه ما نیز همین تست بدون AhuraRTOS با موفقیت انجام شد.

## 6. اضافه کردن AhuraRTOS به progetto

در مرحله بعد پوشه AhuraRTOS را به پروژه اضافه می‌کنیم.

ساختار کلی پروژه به شکل زیر درآمد:

AhuraRtos_F1
│
├── Core
│   ├── Inc
│   └── Src
│
├── Drivers
│
├── AhuraRTOS
│   │
│   ├── kernel
│   │   │
│   │   ├── core
│   │   ├── arch
│   │   │   └── arm
│   │   │       ├── common
│   │   │       └── cortex_m3
│   │   │
│   │   └── ...
│   │
│   └── ...
│
└── STM32F103VETX_FLASH.ld

در STM32CubeIDE باید مسیرهای Header مربوط به AhuraRTOS نیز به تنظیمات Compiler اضافه شوند.

برای مثال:

AhuraRTOS
AhuraRTOS/kernel
AhuraRTOS/kernel/core
AhuraRTOS/kernel/arch/arm/common
AhuraRTOS/kernel/arch/arm/cortex_m3

## 7. انتخاب Architecture مناسب

چون STM32F103 دارای:
**ARM Cortex-M3**

است، باید Port مربوط به Cortex-M3 در پروژه استفاده شود.

یعنی بخش Architecture باید با MCU هماهنگ باشد.

در این پروژه فایل‌هایی مانند:

os_arch_port.c
os_arch_port_v7m.c
os_arch_atomic.c

در فرآیند Build وارد شدند.

## 8. اولین خطای مهم: Multiple Definition

در اولین Build proyecto با خطاهای بسیار زیادی مواجه شدیم.

نمونه:

multiple definition of `os_arch_atomic_exchange`
multiple definition of `os_arch_atomic_add`
multiple definition of `PendSV_Handler`
multiple definition of `os_arch_init`
multiple definition of `os_arch_start_first_task`
و موارد مشابه.

این خطاها نشان می‌دادند که فایل‌های Architecture مربوط به AhuraRTOS دو بار وارد Linker شده‌اند.

در خروجی Build مشخص بود که یک نسخه از فایل از مسیر:

AhuraRTOS/kernel/arch/arm/cortex_m3/

و نسخه دیگری از:

AhuraRTOS/kernel/arch/arm/common/

در Build حضور دارد.

مثلاً:

os_arch_port.o
و:
os_arch_port_v7m.o

هر دو در Linker قرار گرفته بودند.

در نتیجه توابع مشابه دو بار تعریف شده بودند.

## 9. مفهوم خطای Multiple Definition

در C یک تابع عمومی نباید در دو Object File مختلف با یک Symbol یکسان وجود داشته باشد.

مثلاً اگر:

void os_arch_init(void)
{
}

در دو فایل Compile شود، Linker نمی‌داند کدام نسخه را انتخاب کند.

نتیجه:
multiple definition
خواهد بود.

در projeto RTOS این موضوع حساس‌تر است، poiché Architecture Port معمولاً شامل توابع بسیار مهمی مانند:

PendSV_Handler
os_arch_init
os_arch_start_first_task
os_arch_context_restore_asm

است.

## 10. حل مشکل Architecture Files

راه‌حل این بود که فقط Port مناسب برای معماری هدف در Build قرار بگیرد و فایل‌های تکراری وارد Compilation نشوند.

پس در STM32CubeIDE باید بررسی شود که فایل‌های:

os_arch_port.c
os_arch_port_v7m.c
os_arch_atomic.c

به صورت ناخواسته دوباره به projeto اضافه نشده باشند.

بعد از اصلاح Source/Include configuration و حذف Duplicate Build Entries، خطاهای:

multiple definition

برطرف شدند.

## 11. اتصال AhuraRTOS به main.c

بعد از اضافه کردن RTOS، هدر اصلی آن را در main.c اضافه می‌کنیم:

```c
#include "ahura.h"
```

سپس در قسمت initialization سیستم‌عامل را راه‌اندازی می‌کنیم:

```c
os_init();


os_start();
```

در این مرحله انتظار داریم RTOS کنترل اجرای برنامه را در اختیار بگیرد.

## 12. اولین تست AhuraRTOS

برای	test اول	function:

```c
os_main(void)
{
    while (1)
    {
        HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
        os_delay_ms(500);
    }
}
```

در این حالت LED باید هر 500 میلی‌ثانیه تغییر وضعیت دهد.

## 13. مشکلی که بعد از Programming مشاهده شد

در اولین اجرای RTOS مشاهده شد که LED روشن می‌شود اما دیگر تغییر وضعیت می‌دهد.

یعنی:

LED ON
  ↓
توقف

در ابتدا این رفتار می‌توانست نشان‌دهنده مشکل در Scheduler یا Tick باشد.

برای بررسی, یک Delay اولیه نیز آزمایش شد:

```c
for (volatile uint32_t i = 0; i < 500000; i++)
{
    __NOP();
}
```

با این Delay, رفتار تغییر کرد و مشخص شد مشکل در زمان‌بندی اولیه و راه‌اندازی RTOS است.

اما بررسی دقیق‌تر نشان داد که مسئله اصلی در مسیر Tick سیستم‌عامل است.

## 14. مهم‌ترین_stage: اتصال SysTick به AhuraRTOS

یکی از مهم‌ترین بخش‌های Port کردن RTOS به Cortex-M3, اتصال Interrupt مربوط به SysTick به Kernel است.

در پروژه ما لازم بود Handler زیر در فایل مناسب قرار گیرد:

```c
void SysTick_Handler(void)
{
    os_tick_handler();
}
```

این قسمت بسیار مهم است.

زیرا AhuraRTOS برای مدیریت زمان و Delay به Tick نیاز دارد.

به صورت مفهومی:

SysTick Hardware
       │
       ▼
SysTick_Handler()
       │
       ▼
os_tick_handler()
       │
       ▼
AhuraRTOS Kernel
       │
       ├── Update Tick
       ├── Wake Sleeping Tasks
       └── Scheduler

بعد از اضافه کردن این Handler, مشکل اصلی حل شد.

## 15. چرا os_delay_ms() بدون SysTick کار نمی‌کرد؟

وقتی Task این دستور را اجرا می‌کند:

```c
os_delay_ms(100);
```

سیستم‌عامل باید بداند 100 میلی‌ثانیه چه زمانی سپری شده است.

این کار با Tick انجام می‌شود.

اگر Tick به Kernel نرسد، سیستم‌اول نمی‌تواند به شکل صحیح Task را از حالت:

BLOCKED / SLEEPING

به:

READY

برگرداند.

در نتیجه Task ممکن است در Delay باقی بماند.

بنابراین این کد:

```c
void SysTick_Handler(void)
{
    os_tick_handler();
}
```

بخش اساسی Integration AhuraRTOS با STM32 است.

## 16. استفاده از os_main

در مراحل اولیه برای	test ساده می‌توانستیم از:

```c
void os_main(void)
```

استفاده کنیم.

اما هدف اصلی ما استفاده واقعی از مفهوم RTOS یعنی Taskهای مستقل بود.

بنابراین مرحله بعدی ایجاد Taskها بود.

## 17. آشنایی با API مربوط به Task

در مستندات AhuraRTOS APIهایی مانند موارد زیر وجود دارند:

os_task_create()
برای ایجاد Task:

os_task_start()
برای Start کردن Task:

os_task_pause()
برای متوقف کردن Task:

os_task_delete()
برای حذف Task:

os_task_yield()
برای واگذاری CPU:

os_task_priority_set()
برای تغییر Priority:

os_task_priority_get()
برای دریافت Priority:

os_task_state_get()
برای دریافت State Task.

## 18. امضاء تابع Task

یکی از خطاهای مهمی که در زمان تعریف Task دریافت کردیم مربوط به نوع функ بود.

API سیستم‌ولد	expect Entry Function به شکل زیر باشد:

```c
void (*entry)(void *)
```

بنابراین Task باید به صورت زیر تعریف شود:

```c
void LED1_Task(void *arg)
{
    (void)arg;


    while (1)
    {
        ...
    }
}
```

و نه:

```c
void LED1_Task(void)
```

این تفاوت مهم است.

## 19. روش صحیح تعریف Task در AhuraRTOS

در ابتدا سعی کردیم ساختار شبیه RTOSهای دیگر استفاده کنیم:

```c
.stack = led1_stack,
.stack_size = LED1_STACK_SIZE,
.name = "LED1"
```

اما Compiler اعلام کرد:

os_task_config_t has no member named 'stack'
و:
os_task_config_t has no member named 'stack_size'
و:
os_task_config_t has no member named 'name'

این خطا نشان داد که ساختار os_task_config_t در نسخه AhuraRTOS مورد استفاده ما با آن ساختار فرضی متفاوت است.

## 20. روش صحیح defin Stack Task

طبق API واقعی AhuraRTOS, روش صحیحی که در proyecto استفاده شد:

```c
OS_TASK_DEFINE(led1_task, 512U);
OS_TASK_DEFINE(led2_task, 512U);
```

است.

بنابراین سیستم‌عامل مدیریت فضای Task را طبق Macro خودش انجام می‌دهد.

## 21. تعریف اولین Task

Task اول را به شکل زیر تعریف کردیم:

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
```

و Task دوم:

```c
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

البته این نسخه برای	test بود و هر دو Task روی PC13 کار می‌کردند.

## 22. ایجاد Taskها

پس از تعریف Taskها، آنها را با API زیر Create کردیم:

```c
os_task_create(
    &led1_task,
    OS_TASK_CONFIG(LED1_Task, NULL, OS_TASK_PRIO_10)
);
```

و:

```c
os_task_create(
    &led2_task,
    OS_TASK_CONFIG(LED2_Task, NULL, OS_TASK_PRIO_5)
);
```

در اینجا سه پارامتر اصلی را داریم:

LED1_Task
    ↓
Entry Function

NULL
    ↓
Task Argument

OS_TASK_PRIO_10
    ↓
Task Priority

## 23. Start کردن Taskha

صرفاً Create کردن Task به معنی اجرای آن نیست.

پس از Create باید Task را Start کنیم:

```c
os_task_start(&led1_task);


os_task_start(&led2_task);
```

در نتیجه Taskها وارد حالت آماده اجرا می‌شوند.

## 24. Start کردن Scheduler

بعد از ایجاد و Start کردن Taskها, Kernel را اجرا می‌کنیم:

```c
os_start();
```

بنابراین ترتیب صحیح در progetto ما:

os_init();


os_task_create(...);
os_task_create(...);


os_task_start(...);
os_task_start(...);


os_start();


این ترتیب را باید به عنوان یکی از مهم‌ترین بخش‌های راه‌اندازی projeto در نظر گرفت.

## 25. ساختار نهایی راه‌اندازی RTOS

قسمت مهم main() به شکل زیر درآمد:

```c
int main(void)
{
    HAL_Init();


    SystemClock_Config();


    MX_GPIO_Init();
    MX_USART1_UART_Init();


    os_init();


    os_task_create(
        &led1_task,
        OS_TASK_CONFIG(
            LED1_Task,
            NULL,
            OS_TASK_PRIO_10
        )


    );


    os_task_create(
        &led2_task,
        OS_TASK_CONFIG(
            LED2_Task,
            NULL,
            OS_TASK_PRIO_5
        )


    );


    os_task_start(&led1_task);
    os_task_start(&led2_task);


    os_start();


    while (1)
    {
    }
}
```

بعد از:

```c
os_start()
```

کنترل اجرای برنامه عملاً در اختیار Scheduler قرار می‌گیرد.

## 26. مفهوم Priority در AhuraRTOS

در	test ما دو Priority تعریف شد:

OS_TASK_PRIO_10
برای Task اول و:
OS_TASK_PRIO_5
برای Task دوم.

یعنی:

LED1 Task
Priority = 10


LED2 Task
Priority = 5

بنابراین LED1 دارای اولویت بالاتر است.

اما این به معنی آن نیست که LED2 هرگز اجرا نمی‌شود.

وقتی LED1 اجرا می‌کند:

os_delay_ms(100);


Task وارد حالت انتظار می‌شود و Scheduler می‌تواند Task آماده دیگری را اجرا کند.

## 27. نقش Scheduler

در ساده‌ترین حالت می‌توانیم اجرای progetto را به این صورت تصور کنیم:

Scheduler
    │
  ┌─────────┴─────────┐
  │                   │
LED1 Task           LED2 Task
Priority 10          Priority 5
          │                   │
Running              Ready
          │
    os_delay_ms()
          │
       Sleeping
          │
          └──────────────► Scheduler
                              │
                              ▼
                         LED2 Task

این همان جایی است که مفهوم RTOS از یک برنامه ساده while(1) جدا می‌شود.

## 28. چرا از os_delay_ms استفاده می‌کنیم؟

در برنامه معمولی ممکن است بنویسیم:

```c
HAL_Delay(100);
```

اما در RTOS بهتر است Task از API زمان‌بندی خود Kernel استفاده کند:

```c
os_delay_ms(100);
```

زیرا RTOS می‌تواند Task را به حالت Sleep/Blocked ببرد و CPU را برای Taskهای دیگر آزاد کند.

یعنی:

HAL_Delay()
    ↓
CPU waiting


os_delay_ms()
    ↓
Task sleeping
    ↓
Scheduler
    ↓
Other Task can run

این تفاوت یکی از مفاهیم مهم RTOS است.

## 29. تست بهتر با دو LED مستقل

برای اینکه عملکرد Scheduler را بهتر مشاهده کنیم, بهتر است دو LED مستقل داشته باشیم.

مثلاً:

LED1 → PC13
LED2 → PC14

در این حالت PC14 نیز باید در CubeMX به عنوان GPIO Output تعریف شود.

پس Task اول:

```c
void LED1_Task(void *arg)
{
    (void)arg;


    while (1)
    {
        HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);


        os_delay_ms(100);
    }
}
```

Task دوم:

```c
void LED2_Task(void *arg)
{
    (void)arg;


    while (1)
    {
        HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_14);


        os_delay_ms(500);
    }
}
```

نتیجه:

PC13 → Toggle every 100 ms


PC14 → Toggle every 500 ms

بنابراین LED اول سریع‌تر و LED دوم آهسته‌تر چشمک خواهد زد.

## 30. نکته مهم درباره تست قبلی

در تستی که با موفقیت انجام شد, هر دو Task روی:

PC13

کار می‌کردند:

LED1 → SET → 100ms
LED2 → RESET → 200ms

این تست برای بررسی اینکه Taskها واقعاً اجرا می‌شوند مفید بود, اما برای مشاهده rõDou عملکرد دو Task مستقل, استفاده از دو GPIO مجزا بهتر است.

## 31. وضعیت نهایی پروژه

در پایان مراحل, زنجیره اجرای progetto به شکل زیر درآمد:

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
os_init()
    │
    ▼
Create Task 1
    │
    ▼
Create Task 2
    │
    ▼
Start Task 1
    │
    ▼
Start Task 2
    │
    ▼
os_start()
    │
    ▼
Scheduler
    │
  ┌─────────┴─────────┐
  │                   │
  ▼                   ▼
LED1 Task           LED2 Task
    │                   │
os_delay_ms()       os_delay_ms()
    │                   │
    └─────────┬─────────┘
              │
              ▼
          SysTick
              │
              ▼
SysTick_Handler()
    │
    ▼
os_tick_handler()
    │
    ▼
Scheduler

## 32. مهم‌ترین خطاهایی که در این projeto پیدا و رفع شدند

در مسیر راه‌اندازی چند خطای مهم داشتیم.

**خطای اول: Multiple Definition**

نمونه:

multiple definition of 'os_arch_atomic_exchange'

علت:
Duplicate Architecture Sources

راه‌حل:
بررسی Sourceهای AhuraRTOS و جلوگیری از Compile شدن همزمان فایل‌های Port تکراری.

**خطای دوم: Entry Function**

خطا:
initialization of 'void (*)(void *)'
from incompatible pointer type 'void (*)(void)'

علت:
تعریف Task به شکل:

```c
void LED1_Task(void)
```

در حالی که AhuraRTOS انتظار داشت:

```c
void LED1_Task(void *arg)
```

راه‌حل:

```c
void LED1_Task(void *arg)
{
    (void)arg;
    ...
}
```

**خطای سوم: Stack**

خطا:
os_task_config_t has no member named 'stack'

و:
os_task_config_t has no member named 'stack_size'

علت:
استفاده از ساختار اشتباه برای Task Configuration.

راه‌حل:
استفاده از Macro واقعی AhuraRTOS:

```c
OS_TASK_DEFINE(led1_task, 512U);
```

**خطا چهارم: name**

خطا:
os_task_config_t has no member named 'name'

علت:
استفاده از فیلدهایی که در نسخه مورد استفاده از AhuraRTOS وجود نداشتند.

راه‌حل:
استفاده از:

```c
OS_TASK_CONFIG(...)
```

طبق API واقعی progetto.

**خطای پنجم: Task اجرا می‌شد ولی Delay درست کار نمی‌کرد**

مشکل:
LED روشن می‌شد
اما تغییر وضعیت متوقف می‌شد

بررسی نشان داد که SysTick باید به Kernel متصل شود.

راه‌حل:
```c
void SysTick_Handler(void)
{
    os_tick_handler();
}
```

بعد از این اصلاح, os_delay_ms() و زمان‌بندی Taskها به شکل صحیح کار کردند.

## 33. درس‌های مهم این proyecto

این projeto چند مفهوم اساسی RTOS را به شکل عملی نشان داد.

### 33.1 Task

هر Task یک واحد مستقل از اجرای برنامه است.

مثلاً:

LED1 Task
LED2 Task
UART Task
Sensor Task
Network Task

می‌توانند Taskهای مختلف یک projeto واقعی باشند.

### 33.2 Priority

هر Task دارای Priority است.

مثلاً:

OS_TASK_PRIO_10
برای یک Task مهم‌تر و:
OS_TASK_PRIO_5
برای Task کم‌اهمیت‌تر.

### 33.3 Scheduler

Scheduler مشخص می‌کند در هر لحظه کدام Task باید CPU را در اختیار داشته باشد.

### 33.4 Tick

Tick پایه زمانی سیستم‌عامل است.

در این projeto:

SysTick
   ↓
SysTick_Handler
   ↓
os_tick_handler
   ↓
AhuraRTOS

### 33.5 Delay

با:

```c
os_delay_ms()
```

Task می‌تواند برای مدت مشخصی منتظر بماند بدون اینکه منطق Scheduler متوقف شود.

## 34. ساختار پیشنهادی progetto نهایی

در نهایت ساختار proyecto بهتر است چیزی شبیه این باشد:

AhuraRtos_F1
│
├── Core
│   ├── Inc
│   │   └── main.h
│   │
│   └── Src
│       └── main.c
│
├── Drivers
│   ├── CMSIS
│   └── STM32F1xx_HAL_Driver
│
├── AhuraRTOS
│   ├── kernel
│   │   ├── core
│   │   └── arch
│   │       └── arm
│   │           ├── common
│   │           └── cortex_m3
│   │
│   └── ...
│
├── Debug
│
└── STM32F103VETX_FLASH.ld

## 35. کد پایه نهایی Taskها

نسخه‌ای که برای ادامه توسعه projeto پیشنهاد می‌شود:

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
        HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);


        os_delay_ms(100);
    }
}




void LED2_Task(void *arg)
{
    (void)arg;


    while (1)
    {
        HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_14);


        os_delay_ms(500);
    }
}




void os_main(void)
{
}
```

و در main():

```c
int main(void)
{
    HAL_Init();


    SystemClock_Config();


    MX_GPIO_Init();
    MX_USART1_UART_Init();


    os_init();


    os_task_create(
        &led1_task,
        OS_TASK_CONFIG(
            LED1_Task,
            NULL,
            OS_TASK_PRIO_10
        )


    );


    os_task_create(
        &led2_task,
        OS_TASK_CONFIG(
            LED2_Task,
            NULL,
            OS_TASK_PRIO_5
        )


    );


    os_task_start(&led1_task);
    os_task_start(&led2_task);


    os_start();


    while (1)
    {
    }
}
```

و در Interrupt:

```c
void SysTick_Handler(void)
{
    os_tick_handler();
}
```

## 36. نتیجه نهایی

در این آموزش از یک پروژه ساده STM32F103 شروع کردیم و قدم‌به‌قدم AhuraRTOS را به آن اضافه کردیم.

مسیر طی‌شده به صورت خلاصه:

STM32 Project
      ↓
GPIO Configuration
      ↓
LED Test بدون RTOS
      ↓
Add AhuraRTOS
      ↓
Configure Architecture
      ↓
Fix Multiple Definition
      ↓
Include ahura.h
      ↓
os_init()
      ↓
SysTick Integration
      ↓
os_tick_handler()
      ↓
os_delay_ms()
      ↓
OS_TASK_DEFINE()
      ↓
Task Function
      ↓
os_task_create()
      ↓
os_task_start()
      ↓
os_start()
      ↓
Scheduler
      ↓
Multiple Tasks
      ↓
LED1 Task + LED2 Task

در نهایت توانستیم روی STM32F103VET6 و Cortex-M3 یک سیستم‌عامل AhuraRTOS را با موفقیت اجرا کرده و دو Task independente ایجاد کنیم.