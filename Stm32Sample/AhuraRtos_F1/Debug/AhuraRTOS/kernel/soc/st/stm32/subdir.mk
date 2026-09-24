################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../AhuraRTOS/kernel/soc/st/stm32/soc_cb.c 

OBJS += \
./AhuraRTOS/kernel/soc/st/stm32/soc_cb.o 

C_DEPS += \
./AhuraRTOS/kernel/soc/st/stm32/soc_cb.d 


# Each subdirectory must supply rules for building sources it contributes
AhuraRTOS/kernel/soc/st/stm32/%.o AhuraRTOS/kernel/soc/st/stm32/%.su AhuraRTOS/kernel/soc/st/stm32/%.cyclo: ../AhuraRTOS/kernel/soc/st/stm32/%.c AhuraRTOS/kernel/soc/st/stm32/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xE -c -I../Core/Inc -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS" -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS/kernel/arch/arm/common" -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS/kernel/core" -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS/kernel" -I"E:/Electronics/STM32/AhuraOS/AhuraRTOS_Example/Stm32Sample/AhuraRtos_F1/AhuraRTOS/kernel/arch/arm/cortex_m3" -I../Drivers/STM32F1xx_HAL_Driver/Inc -I../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-AhuraRTOS-2f-kernel-2f-soc-2f-st-2f-stm32

clean-AhuraRTOS-2f-kernel-2f-soc-2f-st-2f-stm32:
	-$(RM) ./AhuraRTOS/kernel/soc/st/stm32/soc_cb.cyclo ./AhuraRTOS/kernel/soc/st/stm32/soc_cb.d ./AhuraRTOS/kernel/soc/st/stm32/soc_cb.o ./AhuraRTOS/kernel/soc/st/stm32/soc_cb.su

.PHONY: clean-AhuraRTOS-2f-kernel-2f-soc-2f-st-2f-stm32

