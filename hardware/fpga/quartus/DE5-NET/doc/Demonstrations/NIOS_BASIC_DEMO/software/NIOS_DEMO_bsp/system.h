/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2_qsys' in SOPC Builder design 'S5_QSYS'
 * SOPC Builder design path: ../../S5_QSYS.sopcinfo
 *
 * Generated: Tue Mar 21 15:18:59 CST 2017
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x00080820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 50000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "fast"
#define ALT_CPU_DATA_ADDR_WIDTH 0x14
#define ALT_CPU_DCACHE_BYPASS_MASK 0x80000000
#define ALT_CPU_DCACHE_LINE_SIZE 32
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_DCACHE_SIZE 2048
#define ALT_CPU_EXCEPTION_ADDR 0x00040020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 50000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 1
#define ALT_CPU_HARDWARE_MULX_PRESENT 1
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_EXTRA_EXCEPTION_INFO
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 4096
#define ALT_CPU_INITDA_SUPPORTED
#define ALT_CPU_INST_ADDR_WIDTH 0x14
#define ALT_CPU_NAME "nios2_qsys"
#define ALT_CPU_NUM_OF_SHADOW_REG_SETS 0
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x00040000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x00080820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 50000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "fast"
#define NIOS2_DATA_ADDR_WIDTH 0x14
#define NIOS2_DCACHE_BYPASS_MASK 0x80000000
#define NIOS2_DCACHE_LINE_SIZE 32
#define NIOS2_DCACHE_LINE_SIZE_LOG2 5
#define NIOS2_DCACHE_SIZE 2048
#define NIOS2_EXCEPTION_ADDR 0x00040020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 1
#define NIOS2_HARDWARE_MULX_PRESENT 1
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_EXTRA_EXCEPTION_INFO
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 32
#define NIOS2_ICACHE_LINE_SIZE_LOG2 5
#define NIOS2_ICACHE_SIZE 4096
#define NIOS2_INITDA_SUPPORTED
#define NIOS2_INST_ADDR_WIDTH 0x14
#define NIOS2_NUM_OF_SHADOW_REG_SETS 0
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x00040000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_TIMER
#define __ALTERA_NIOS2_GEN2
#define __TERASIC_CLOCK_COUNT
#define __TERASIC_EXT_PLL


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Stratix V"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x81210
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x81210
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x81210
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "S5_QSYS"


/*
 * button configuration
 *
 */

#define ALT_MODULE_CLASS_button altera_avalon_pio
#define BUTTON_BASE 0x81030
#define BUTTON_BIT_CLEARING_EDGE_REGISTER 0
#define BUTTON_BIT_MODIFYING_OUTPUT_REGISTER 0
#define BUTTON_CAPTURE 1
#define BUTTON_DATA_WIDTH 4
#define BUTTON_DO_TEST_BENCH_WIRING 0
#define BUTTON_DRIVEN_SIM_VALUE 0
#define BUTTON_EDGE_TYPE "FALLING"
#define BUTTON_FREQ 50000000
#define BUTTON_HAS_IN 1
#define BUTTON_HAS_OUT 0
#define BUTTON_HAS_TRI 0
#define BUTTON_IRQ 2
#define BUTTON_IRQ_INTERRUPT_CONTROLLER_ID 0
#define BUTTON_IRQ_TYPE "EDGE"
#define BUTTON_NAME "/dev/button"
#define BUTTON_RESET_VALUE 0
#define BUTTON_SPAN 16
#define BUTTON_TYPE "altera_avalon_pio"


/*
 * cdcm configuration
 *
 */

#define ALT_MODULE_CLASS_cdcm TERASIC_EXT_PLL
#define CDCM_BASE 0x0
#define CDCM_IRQ -1
#define CDCM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CDCM_NAME "/dev/cdcm"
#define CDCM_SPAN 8
#define CDCM_TYPE "TERASIC_EXT_PLL"


/*
 * clk_i2c_scl configuration
 *
 */

#define ALT_MODULE_CLASS_clk_i2c_scl altera_avalon_pio
#define CLK_I2C_SCL_BASE 0x81140
#define CLK_I2C_SCL_BIT_CLEARING_EDGE_REGISTER 0
#define CLK_I2C_SCL_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CLK_I2C_SCL_CAPTURE 0
#define CLK_I2C_SCL_DATA_WIDTH 1
#define CLK_I2C_SCL_DO_TEST_BENCH_WIRING 0
#define CLK_I2C_SCL_DRIVEN_SIM_VALUE 0
#define CLK_I2C_SCL_EDGE_TYPE "NONE"
#define CLK_I2C_SCL_FREQ 50000000
#define CLK_I2C_SCL_HAS_IN 0
#define CLK_I2C_SCL_HAS_OUT 1
#define CLK_I2C_SCL_HAS_TRI 0
#define CLK_I2C_SCL_IRQ -1
#define CLK_I2C_SCL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CLK_I2C_SCL_IRQ_TYPE "NONE"
#define CLK_I2C_SCL_NAME "/dev/clk_i2c_scl"
#define CLK_I2C_SCL_RESET_VALUE 0
#define CLK_I2C_SCL_SPAN 16
#define CLK_I2C_SCL_TYPE "altera_avalon_pio"


/*
 * clk_i2c_sda configuration
 *
 */

#define ALT_MODULE_CLASS_clk_i2c_sda altera_avalon_pio
#define CLK_I2C_SDA_BASE 0x81130
#define CLK_I2C_SDA_BIT_CLEARING_EDGE_REGISTER 0
#define CLK_I2C_SDA_BIT_MODIFYING_OUTPUT_REGISTER 0
#define CLK_I2C_SDA_CAPTURE 0
#define CLK_I2C_SDA_DATA_WIDTH 1
#define CLK_I2C_SDA_DO_TEST_BENCH_WIRING 0
#define CLK_I2C_SDA_DRIVEN_SIM_VALUE 0
#define CLK_I2C_SDA_EDGE_TYPE "NONE"
#define CLK_I2C_SDA_FREQ 50000000
#define CLK_I2C_SDA_HAS_IN 0
#define CLK_I2C_SDA_HAS_OUT 0
#define CLK_I2C_SDA_HAS_TRI 1
#define CLK_I2C_SDA_IRQ -1
#define CLK_I2C_SDA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define CLK_I2C_SDA_IRQ_TYPE "NONE"
#define CLK_I2C_SDA_NAME "/dev/clk_i2c_sda"
#define CLK_I2C_SDA_RESET_VALUE 0
#define CLK_I2C_SDA_SPAN 16
#define CLK_I2C_SDA_TYPE "altera_avalon_pio"


/*
 * fan configuration
 *
 */

#define ALT_MODULE_CLASS_fan altera_avalon_pio
#define FAN_BASE 0x81080
#define FAN_BIT_CLEARING_EDGE_REGISTER 0
#define FAN_BIT_MODIFYING_OUTPUT_REGISTER 0
#define FAN_CAPTURE 0
#define FAN_DATA_WIDTH 1
#define FAN_DO_TEST_BENCH_WIRING 0
#define FAN_DRIVEN_SIM_VALUE 0
#define FAN_EDGE_TYPE "NONE"
#define FAN_FREQ 50000000
#define FAN_HAS_IN 0
#define FAN_HAS_OUT 1
#define FAN_HAS_TRI 0
#define FAN_IRQ -1
#define FAN_IRQ_INTERRUPT_CONTROLLER_ID -1
#define FAN_IRQ_TYPE "NONE"
#define FAN_NAME "/dev/fan"
#define FAN_RESET_VALUE 1
#define FAN_SPAN 16
#define FAN_TYPE "altera_avalon_pio"


/*
 * hal configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK TIMER
#define ALT_TIMESTAMP_CLK none


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x81210
#define JTAG_UART_IRQ 1
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * led configuration
 *
 */

#define ALT_MODULE_CLASS_led altera_avalon_pio
#define LED_BASE 0x81070
#define LED_BIT_CLEARING_EDGE_REGISTER 0
#define LED_BIT_MODIFYING_OUTPUT_REGISTER 0
#define LED_CAPTURE 0
#define LED_DATA_WIDTH 4
#define LED_DO_TEST_BENCH_WIRING 0
#define LED_DRIVEN_SIM_VALUE 0
#define LED_EDGE_TYPE "NONE"
#define LED_FREQ 50000000
#define LED_HAS_IN 0
#define LED_HAS_OUT 1
#define LED_HAS_TRI 0
#define LED_IRQ -1
#define LED_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LED_IRQ_TYPE "NONE"
#define LED_NAME "/dev/led"
#define LED_RESET_VALUE 0
#define LED_SPAN 16
#define LED_TYPE "altera_avalon_pio"


/*
 * onchip_memory2 configuration
 *
 */

#define ALT_MODULE_CLASS_onchip_memory2 altera_avalon_onchip_memory2
#define ONCHIP_MEMORY2_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define ONCHIP_MEMORY2_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define ONCHIP_MEMORY2_BASE 0x40000
#define ONCHIP_MEMORY2_CONTENTS_INFO ""
#define ONCHIP_MEMORY2_DUAL_PORT 0
#define ONCHIP_MEMORY2_GUI_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_MEMORY2_INIT_CONTENTS_FILE "S5_QSYS_onchip_memory2"
#define ONCHIP_MEMORY2_INIT_MEM_CONTENT 1
#define ONCHIP_MEMORY2_INSTANCE_ID "NONE"
#define ONCHIP_MEMORY2_IRQ -1
#define ONCHIP_MEMORY2_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ONCHIP_MEMORY2_NAME "/dev/onchip_memory2"
#define ONCHIP_MEMORY2_NON_DEFAULT_INIT_FILE_ENABLED 0
#define ONCHIP_MEMORY2_RAM_BLOCK_TYPE "AUTO"
#define ONCHIP_MEMORY2_READ_DURING_WRITE_MODE "DONT_CARE"
#define ONCHIP_MEMORY2_SINGLE_CLOCK_OP 0
#define ONCHIP_MEMORY2_SIZE_MULTIPLE 1
#define ONCHIP_MEMORY2_SIZE_VALUE 256000
#define ONCHIP_MEMORY2_SPAN 256000
#define ONCHIP_MEMORY2_TYPE "altera_avalon_onchip_memory2"
#define ONCHIP_MEMORY2_WRITABLE 1


/*
 * ref_clock_10g_count configuration
 *
 */

#define ALT_MODULE_CLASS_ref_clock_10g_count TERASIC_CLOCK_COUNT
#define REF_CLOCK_10G_COUNT_BASE 0x81170
#define REF_CLOCK_10G_COUNT_IRQ -1
#define REF_CLOCK_10G_COUNT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define REF_CLOCK_10G_COUNT_NAME "/dev/ref_clock_10g_count"
#define REF_CLOCK_10G_COUNT_SPAN 16
#define REF_CLOCK_10G_COUNT_TYPE "TERASIC_CLOCK_COUNT"


/*
 * ref_clock_sata_count configuration
 *
 */

#define ALT_MODULE_CLASS_ref_clock_sata_count TERASIC_CLOCK_COUNT
#define REF_CLOCK_SATA_COUNT_BASE 0x81150
#define REF_CLOCK_SATA_COUNT_IRQ -1
#define REF_CLOCK_SATA_COUNT_IRQ_INTERRUPT_CONTROLLER_ID -1
#define REF_CLOCK_SATA_COUNT_NAME "/dev/ref_clock_sata_count"
#define REF_CLOCK_SATA_COUNT_SPAN 16
#define REF_CLOCK_SATA_COUNT_TYPE "TERASIC_CLOCK_COUNT"


/*
 * sw configuration
 *
 */

#define ALT_MODULE_CLASS_sw altera_avalon_pio
#define SW_BASE 0x81020
#define SW_BIT_CLEARING_EDGE_REGISTER 0
#define SW_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SW_CAPTURE 1
#define SW_DATA_WIDTH 4
#define SW_DO_TEST_BENCH_WIRING 0
#define SW_DRIVEN_SIM_VALUE 0
#define SW_EDGE_TYPE "ANY"
#define SW_FREQ 50000000
#define SW_HAS_IN 1
#define SW_HAS_OUT 0
#define SW_HAS_TRI 0
#define SW_IRQ 3
#define SW_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SW_IRQ_TYPE "EDGE"
#define SW_NAME "/dev/sw"
#define SW_RESET_VALUE 0
#define SW_SPAN 16
#define SW_TYPE "altera_avalon_pio"


/*
 * temp_int_n configuration
 *
 */

#define ALT_MODULE_CLASS_temp_int_n altera_avalon_pio
#define TEMP_INT_N_BASE 0x81050
#define TEMP_INT_N_BIT_CLEARING_EDGE_REGISTER 0
#define TEMP_INT_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define TEMP_INT_N_CAPTURE 0
#define TEMP_INT_N_DATA_WIDTH 1
#define TEMP_INT_N_DO_TEST_BENCH_WIRING 0
#define TEMP_INT_N_DRIVEN_SIM_VALUE 0
#define TEMP_INT_N_EDGE_TYPE "NONE"
#define TEMP_INT_N_FREQ 50000000
#define TEMP_INT_N_HAS_IN 1
#define TEMP_INT_N_HAS_OUT 0
#define TEMP_INT_N_HAS_TRI 0
#define TEMP_INT_N_IRQ -1
#define TEMP_INT_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TEMP_INT_N_IRQ_TYPE "NONE"
#define TEMP_INT_N_NAME "/dev/temp_int_n"
#define TEMP_INT_N_RESET_VALUE 0
#define TEMP_INT_N_SPAN 16
#define TEMP_INT_N_TYPE "altera_avalon_pio"


/*
 * temp_overt_n configuration
 *
 */

#define ALT_MODULE_CLASS_temp_overt_n altera_avalon_pio
#define TEMP_OVERT_N_BASE 0x81060
#define TEMP_OVERT_N_BIT_CLEARING_EDGE_REGISTER 0
#define TEMP_OVERT_N_BIT_MODIFYING_OUTPUT_REGISTER 0
#define TEMP_OVERT_N_CAPTURE 0
#define TEMP_OVERT_N_DATA_WIDTH 1
#define TEMP_OVERT_N_DO_TEST_BENCH_WIRING 0
#define TEMP_OVERT_N_DRIVEN_SIM_VALUE 0
#define TEMP_OVERT_N_EDGE_TYPE "NONE"
#define TEMP_OVERT_N_FREQ 50000000
#define TEMP_OVERT_N_HAS_IN 1
#define TEMP_OVERT_N_HAS_OUT 0
#define TEMP_OVERT_N_HAS_TRI 0
#define TEMP_OVERT_N_IRQ -1
#define TEMP_OVERT_N_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TEMP_OVERT_N_IRQ_TYPE "NONE"
#define TEMP_OVERT_N_NAME "/dev/temp_overt_n"
#define TEMP_OVERT_N_RESET_VALUE 0
#define TEMP_OVERT_N_SPAN 16
#define TEMP_OVERT_N_TYPE "altera_avalon_pio"


/*
 * temp_scl configuration
 *
 */

#define ALT_MODULE_CLASS_temp_scl altera_avalon_pio
#define TEMP_SCL_BASE 0x81100
#define TEMP_SCL_BIT_CLEARING_EDGE_REGISTER 0
#define TEMP_SCL_BIT_MODIFYING_OUTPUT_REGISTER 0
#define TEMP_SCL_CAPTURE 0
#define TEMP_SCL_DATA_WIDTH 1
#define TEMP_SCL_DO_TEST_BENCH_WIRING 0
#define TEMP_SCL_DRIVEN_SIM_VALUE 0
#define TEMP_SCL_EDGE_TYPE "NONE"
#define TEMP_SCL_FREQ 50000000
#define TEMP_SCL_HAS_IN 0
#define TEMP_SCL_HAS_OUT 1
#define TEMP_SCL_HAS_TRI 0
#define TEMP_SCL_IRQ -1
#define TEMP_SCL_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TEMP_SCL_IRQ_TYPE "NONE"
#define TEMP_SCL_NAME "/dev/temp_scl"
#define TEMP_SCL_RESET_VALUE 0
#define TEMP_SCL_SPAN 16
#define TEMP_SCL_TYPE "altera_avalon_pio"


/*
 * temp_sda configuration
 *
 */

#define ALT_MODULE_CLASS_temp_sda altera_avalon_pio
#define TEMP_SDA_BASE 0x81040
#define TEMP_SDA_BIT_CLEARING_EDGE_REGISTER 0
#define TEMP_SDA_BIT_MODIFYING_OUTPUT_REGISTER 0
#define TEMP_SDA_CAPTURE 0
#define TEMP_SDA_DATA_WIDTH 1
#define TEMP_SDA_DO_TEST_BENCH_WIRING 0
#define TEMP_SDA_DRIVEN_SIM_VALUE 0
#define TEMP_SDA_EDGE_TYPE "NONE"
#define TEMP_SDA_FREQ 50000000
#define TEMP_SDA_HAS_IN 0
#define TEMP_SDA_HAS_OUT 0
#define TEMP_SDA_HAS_TRI 1
#define TEMP_SDA_IRQ -1
#define TEMP_SDA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define TEMP_SDA_IRQ_TYPE "NONE"
#define TEMP_SDA_NAME "/dev/temp_sda"
#define TEMP_SDA_RESET_VALUE 0
#define TEMP_SDA_SPAN 16
#define TEMP_SDA_TYPE "altera_avalon_pio"


/*
 * timer configuration
 *
 */

#define ALT_MODULE_CLASS_timer altera_avalon_timer
#define TIMER_ALWAYS_RUN 0
#define TIMER_BASE 0x81000
#define TIMER_COUNTER_SIZE 32
#define TIMER_FIXED_PERIOD 0
#define TIMER_FREQ 50000000
#define TIMER_IRQ 0
#define TIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_LOAD_VALUE 49999
#define TIMER_MULT 0.001
#define TIMER_NAME "/dev/timer"
#define TIMER_PERIOD 1
#define TIMER_PERIOD_UNITS "ms"
#define TIMER_RESET_OUTPUT 0
#define TIMER_SNAPSHOT 1
#define TIMER_SPAN 32
#define TIMER_TICKS_PER_SEC 1000
#define TIMER_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_TYPE "altera_avalon_timer"

#endif /* __SYSTEM_H_ */
