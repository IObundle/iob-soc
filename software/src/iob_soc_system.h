#define P_BIT 30 // Peripheral bus selection bit

// peripheral bus base
#define PBUS_BASE (1 << P_BIT)

#define BOOTLDR_ADDR ((1 << IOB_SOC_MEM_ADDR_W) - (1 << IOB_SOC_BOOTROM_ADDR_W))
