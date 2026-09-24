################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../AhuraRTOS/kernel/core/os_atomic.c \
../AhuraRTOS/kernel/core/os_critical.c \
../AhuraRTOS/kernel/core/os_delay.c \
../AhuraRTOS/kernel/core/os_event.c \
../AhuraRTOS/kernel/core/os_kernel.c \
../AhuraRTOS/kernel/core/os_list.c \
../AhuraRTOS/kernel/core/os_log.c \
../AhuraRTOS/kernel/core/os_mem.c \
../AhuraRTOS/kernel/core/os_mutex.c \
../AhuraRTOS/kernel/core/os_notify.c \
../AhuraRTOS/kernel/core/os_queue.c \
../AhuraRTOS/kernel/core/os_semaphore.c \
../AhuraRTOS/kernel/core/os_task.c \
../AhuraRTOS/kernel/core/os_tick.c \
../AhuraRTOS/kernel/core/os_timer.c 

OBJS += \
./AhuraRTOS/kernel/core/os_atomic.o \
./AhuraRTOS/kernel/core/os_critical.o \
./AhuraRTOS/kernel/core/os_delay.o \
./AhuraRTOS/kernel/core/os_event.o \
./AhuraRTOS/kernel/core/os_kernel.o \
./AhuraRTOS/kernel/core/os_list.o \
./AhuraRTOS/kernel/core/os_log.o \
./AhuraRTOS/kernel/core/os_mem.o \
./AhuraRTOS/kernel/core/os_mutex.o \
./AhuraRTOS/kernel/core/os_notify.o \
./AhuraRTOS/kernel/core/os_queue.o \
./AhuraRTOS/kernel/core/os_semaphore.o \
./AhuraRTOS/kernel/core/os_task.o \
./AhuraRTOS/kernel/core/os_tick.o \
./AhuraRTOS/kernel/core/os_timer.o 

C_DEPS += \
./AhuraRTOS/kernel/core/os_atomic.d \
./AhuraRTOS/kernel/core/os_critical.d \
./AhuraRTOS/kernel/core/os_delay.d \
./AhuraRTOS/kernel/core/os_event.d \
./AhuraRTOS/kernel/core/os_kernel.d \
./AhuraRTOS/kernel/core/os_list.d \
./AhuraRTOS/kernel/core/os_log.d \
./AhuraRTOS/kernel/core/os_mem.d \
./AhuraRTOS/kernel/core/os_mutex.d \
./AhuraRTOS/kernel/core/os_notify.d \
./AhuraRTOS/kernel/core/os_queue.d \
./AhuraRTOS/kernel/core/os_semaphore.d \
./AhuraRTOS/kernel/core/os_task.d \
./AhuraRTOS/kernel/core/os_tick.d \
./AhuraRTOS/kernel/core/os_timer.d 


# Each subdirectory must supply rules for building sources it contributes
AhuraRTOS/kernel/core/%.o AhuraRTOS/kernel/core/%.su AhuraRTOS/kernel/core/%.cyclo: ../AhuraRTOS/kernel/core/%.c AhuraRTOS/kernel/core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xE -c -I../Core/Inc -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS" -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS/kernel/arch/arm/common" -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS/kernel/core" -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS/kernel" -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS/kernel/arch/arm/cortex_m3" -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-AhuraRTOS-2f-kernel-2f-core

clean-AhuraRTOS-2f-kernel-2f-core:
	-$(RM) ./AhuraRTOS/kernel/core/os_atomic.cyclo ./AhuraRTOS/kernel/core/os_atomic.d ./AhuraRTOS/kernel/core/os_atomic.o ./AhuraRTOS/kernel/core/os_atomic.su ./AhuraRTOS/kernel/core/os_critical.cyclo ./AhuraRTOS/kernel/core/os_critical.d ./AhuraRTOS/kernel/core/os_critical.o ./AhuraRTOS/kernel/core/os_critical.su ./AhuraRTOS/kernel/core/os_delay.cyclo ./AhuraRTOS/kernel/core/os_delay.d ./AhuraRTOS/kernel/core/os_delay.o ./AhuraRTOS/kernel/core/os_delay.su ./AhuraRTOS/kernel/core/os_event.cyclo ./AhuraRTOS/kernel/core/os_event.d ./AhuraRTOS/kernel/core/os_event.o ./AhuraRTOS/kernel/core/os_event.su ./AhuraRTOS/kernel/core/os_kernel.cyclo ./AhuraRTOS/kernel/core/os_kernel.d ./AhuraRTOS/kernel/core/os_kernel.o ./AhuraRTOS/kernel/core/os_kernel.su ./AhuraRTOS/kernel/core/os_list.cyclo ./AhuraRTOS/kernel/core/os_list.d ./AhuraRTOS/kernel/core/os_list.o ./AhuraRTOS/kernel/core/os_list.su ./AhuraRTOS/kernel/core/os_log.cyclo ./AhuraRTOS/kernel/core/os_log.d ./AhuraRTOS/kernel/core/os_log.o ./AhuraRTOS/kernel/core/os_log.su ./AhuraRTOS/kernel/core/os_mem.cyclo ./AhuraRTOS/kernel/core/os_mem.d ./AhuraRTOS/kernel/core/os_mem.o ./AhuraRTOS/kernel/core/os_mem.su ./AhuraRTOS/kernel/core/os_mutex.cyclo ./AhuraRTOS/kernel/core/os_mutex.d ./AhuraRTOS/kernel/core/os_mutex.o ./AhuraRTOS/kernel/core/os_mutex.su ./AhuraRTOS/kernel/core/os_notify.cyclo ./AhuraRTOS/kernel/core/os_notify.d ./AhuraRTOS/kernel/core/os_notify.o ./AhuraRTOS/kernel/core/os_notify.su ./AhuraRTOS/kernel/core/os_queue.cyclo ./AhuraRTOS/kernel/core/os_queue.d ./AhuraRTOS/kernel/core/os_queue.o ./AhuraRTOS/kernel/core/os_queue.su ./AhuraRTOS/kernel/core/os_semaphore.cyclo ./AhuraRTOS/kernel/core/os_semaphore.d ./AhuraRTOS/kernel/core/os_semaphore.o ./AhuraRTOS/kernel/core/os_semaphore.su ./AhuraRTOS/kernel/core/os_task.cyclo ./AhuraRTOS/kernel/core/os_task.d ./AhuraRTOS/kernel/core/os_task.o ./AhuraRTOS/kernel/core/os_task.su ./AhuraRTOS/kernel/core/os_tick.cyclo ./AhuraRTOS/kernel/core/os_tick.d ./AhuraRTOS/kernel/core/os_tick.o ./AhuraRTOS/kernel/core/os_tick.su ./AhuraRTOS/kernel/core/os_timer.cyclo ./AhuraRTOS/kernel/core/os_timer.d ./AhuraRTOS/kernel/core/os_timer.o ./AhuraRTOS/kernel/core/os_timer.su

.PHONY: clean-AhuraRTOS-2f-kernel-2f-core

