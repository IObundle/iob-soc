//boot controller base address
#if USE_DDR && RUN_DDR
#define BOOTCTR_BASE EXTRA_BASE | (1 << SRAM_ADDR_W)
#else
#define BOOTCTR_BASE (1 << SRAM_ADDR_W)
#endif
