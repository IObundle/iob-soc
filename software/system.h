//
//Memory map
//

//select extra memory:
//extra memory is SRAM if running from DDR or DDR if running from SRAM
#define EXTRA_BASE (1<<E)

//select boot controller
#define BOOTCTR_BASE (1<<B)

#ifdef USE_DDR
#define USE_DDR_SW 1
#else
#define USE_DDR_SW 0
#endif

#ifdef RUN_EXTMEM
#define RUN_EXTMEM_SW 1
#else
#define RUN_EXTMEM_SW 0
#endif
