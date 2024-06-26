#include "iob-nco.h"

// Base Address
static uint32_t base;

void nco_reset() {
  IOB_NCO_SET_RESET(1);
  IOB_NCO_SET_RESET(0);
}

void nco_init(uint32_t base_address) {
  base = base_address;
  IOB_NCO_INIT_BASEADDR(base_address);
  nco_reset();
  IOB_NCO_SET_ENABLE(1);
}

uint64_t nco_get_count() {
  // sample nco counter
  IOB_NCO_SET_SAMPLE(1);
  IOB_NCO_SET_SAMPLE(0);

  uint64_t count = (uint64_t)IOB_NCO_GET_DATA_HIGH();
  count <<= IOB_NCO_DATA_LOW_W;
  count |= (uint64_t)IOB_NCO_GET_DATA_LOW();

  return count;
}
