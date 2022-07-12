#include "iob-gpio.h"

//GPIO functions

//Set GPIO base address
void gpio_init(int base_address){
  IOB_GPIO_INIT_BASEADDR(base_address);
}

//Get values from inputs
uint32_t gpio_get(){
  return IOB_GPIO_GET_READ();
}

//Set values on outputs
void gpio_set(uint32_t value){
  IOB_GPIO_SET_WRITE(value);
}

//Set mask for outputs (bits 1 are outputs, bits 0 are inputs)
void gpio_write_mask(uint32_t value){
  IOB_GPIO_SET_WRITE_MASK(value);
}
