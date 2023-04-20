/* PC Emulation of GPIO peripheral */

#include <stdint.h>
#include <stdio.h>

#include "iob_gpio_swreg.h"

static uint32_t base;

void GPIO_INIT_BASEADDR(uint32_t addr) {
    base = addr;
    return;
}

//Get values from inputs
uint32_t gpio_get(){
    return 0xaaaaaaaa;
}

//Set values on outputs
void gpio_set(uint32_t outputs){
}
