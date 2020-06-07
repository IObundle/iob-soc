// boot copy address
#if USE_BOOT==1
#if (USE_DDR==0 || (USE_DDR==1 && RUN_DDR==0))
char *mem = (char *) (1<<BOOTROM_ADDR_W);
#else
char *mem = (char *) EXTRA_BASE;
#endif
#endif

//boot controller base address
#define BOOTCTR_BASE (1 << SRAM_ADDR_W)


