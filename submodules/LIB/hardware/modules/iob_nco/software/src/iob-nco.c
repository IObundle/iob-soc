#include "iob-nco.h"

// Base Address
static uint32_t base;

void nco_reset() {
  IOB_NCO_SET_SOFT_RESET(1);
  IOB_NCO_SET_SOFT_RESET(0);
}

void nco_init(uint32_t base_address) {
  base = base_address;
  IOB_NCO_INIT_BASEADDR(base_address);
  nco_reset();
}

void nco_enable(bool enable) {
  IOB_NCO_SET_ENABLE(enable);
}

void nco_set_period(uint32_t period) {
  IOB_NCO_SET_PERIOD(period);
}
