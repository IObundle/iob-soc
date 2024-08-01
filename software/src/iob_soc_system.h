#define E_BIT 31 // Extra memory selection bit
#define P_BIT 30 // Peripheral bus selection bit
#define B_BIT 29 // Bootcontroller selection bit

// extra memory base address
// extra memory is SRAM if running from DDR or DDR if running from SRAM
#define EXTRA_BASE (1 << E_BIT)

// peripheral bus base
#define PBUS_BASE (1 << P_BIT)

// boot controller base address
#define BOOTCTR_BASE (1 << B_BIT)
