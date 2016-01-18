#include "stm32f4xx_rcc.h"
#include "stm32f4xx_gpio.h"

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

void assert_param(bool x)
{
    if (x) {}
}

int main(void)
{
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

    GPIO_InitTypeDef gpioInit;

    gpioInit.GPIO_Mode = GPIO_Mode_OUT;
    gpioInit.GPIO_OType = GPIO_OType_PP;
    gpioInit.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_12;
    gpioInit.GPIO_PuPd = GPIO_PuPd_NOPULL;
    gpioInit.GPIO_Speed = GPIO_Speed_2MHz;

    GPIO_Init(GPIOD, &gpioInit);

    GPIO_SetBits(GPIOD, GPIO_Pin_12);
    GPIO_ResetBits(GPIOD, GPIO_Pin_13);

    volatile uint32_t c = 0;
    while(1)
    {

        c = 1000000;
        while (c > 0) c--;

        GPIO_ToggleBits(GPIOD, GPIO_Pin_12 | GPIO_Pin_13);

        c = 1000000;
        while (c > 0) c--;

        GPIO_ToggleBits(GPIOD, GPIO_Pin_12 | GPIO_Pin_13);
    }

    return EXIT_SUCCESS;
}
