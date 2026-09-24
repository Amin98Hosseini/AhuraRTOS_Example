################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../AhuraRTOS/kernel/arch/arm/common/os_arch_atomic.c \
../AhuraRTOS/kernel/arch/arm/common/os_arch_port_v7m.c 

OBJS += \
./AhuraRTOS/kernel/arch/arm/common/os_arch_atomic.o \
./AhuraRTOS/kernel/arch/arm/common/os_arch_port_v7m.o 

C_DEPS += \
./AhuraRTOS/kernel/arch/arm/common/os_arch_atomic.d \
./AhuraRTOS/kernel/arch/arm/common/os_arch_port_v7m.d 


# Each subdirectory must supply rules for building sources it contributes
AhuraRTOS/kernel/arch/arm/common/%.o AhuraRTOS/kernel/arch/arm/common/%.su AhuraRTOS/kernel/arch/arm/common/%.cyclo: ../AhuraRTOS/kernel/arch/arm/common/%.c AhuraRTOS/kernel/arch/arm/common/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xE -c -I../Core/Inc -I"C:/Users/Diatell/Desktop/AhuraRtos_F1/AhuraRTOS" -I"C:/Users/Diatell/Desktop/AhuraRtos_F1/AhuraRTOS/kernel/arch/arm/common" -I"C:/Users/Diatell/Desktop/AhuraRtos_F1/AhuraRTOS/kernel/core" -I"C:/Users/Diatell/Desktop/AhuraRtos_F1/AhuraRTOS/kernel" -I"C:/Users/Diatell/Desktop/AhuraRtos_F1/AhuraRTOS/kernel/arch/arm/cortex_m3" -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-AhuraRTOS-2f-kernel-2f-arch-2f-arm-2f-common

clean-AhuraRTOS-2f-kernel-2f-arch-2f-arm-2f-common:
	-$(RM) ./AhuraRTOS/kernel/arch/arm/common/os_arch_atomic.cyclo ./AhuraRTOS/kernel/arch/arm/common/os_arch_atomic.d ./AhuraRTOS/kernel/arch/arm/common/os_arch_atomic.o ./AhuraRTOS/kernel/arch/arm/common/os_arch_atomic.su ./AhuraRTOS/kernel/arch/arm/common/os_arch_port_v7m.cyclo ./AhuraRTOS/kernel/arch/arm/common/os_arch_port_v7m.d ./AhuraRTOS/kernel/arch/arm/common/os_arch_port_v7m.o ./AhuraRTOS/kernel/arch/arm/common/os_arch_port_v7m.su

.PHONY: clean-AhuraRTOS-2f-kernel-2f-arch-2f-arm-2f-common

