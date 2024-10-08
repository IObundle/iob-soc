// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

#include <stdio.h>
#include <stdlib.h>
#include <verilated.h>

#include "Viob_system_sim_wrapper.h"
#include "bsp.h"
#include "iob_system_conf.h"
#include "iob_uart_csrs.h"

#include "iob_tasks.h"
#ifdef IOB_SYSTEM_USE_ETHERNET
#include "iob_eth_driver_tb.h"
#endif

#if (VM_TRACE == 1)     // If verilator was invoked with --trace
#if (VM_TRACE_FST == 1) // If verilator was invoked with --trace-fst
#include <verilated_fst_c.h>
#else
#include <verilated_vcd_c.h>
#endif
#endif

extern vluint64_t main_time;
extern timer_settings_t task_timer_settings;

void cpu_inituart(iob_native_t *uart_if);

Viob_system_sim_wrapper *dut = new Viob_system_sim_wrapper;

void call_eval() { dut->eval(); }

#if (VM_TRACE == 1)
#if (VM_TRACE_FST == 1)
VerilatedFstC *tfp = new VerilatedFstC; // Create tracing object
#else
VerilatedVcdC *tfp = new VerilatedVcdC; // Create tracing object
#endif

void call_dump(vluint64_t time) { tfp->dump(time); }
#endif

double sc_time_stamp() { // Called by $time in Verilog
  return main_time;
}

//
// Main program
//
int main(int argc, char **argv, char **env) {
  unsigned int i;

  Verilated::commandArgs(argc, argv);
  task_timer_settings.clk = &dut->clk_i;
  task_timer_settings.eval = call_eval;
#if (VM_TRACE == 1)
  task_timer_settings.dump = call_dump;
#endif

  iob_native_t uart_if = {
      &dut->uart_iob_valid_i,  &dut->uart_iob_addr_i,  UCHAR,
      &dut->uart_iob_wdata_i,  &dut->uart_iob_wstrb_i, &dut->uart_iob_rdata_o,
      &dut->uart_iob_rvalid_o, &dut->uart_iob_ready_o};

#ifdef IOB_SYSTEM_USE_ETHERNET
  iob_native_t eth_if = {&dut->ethernet_iob_valid_i,
                         &dut->ethernet_iob_addr_i,
                         USINT,
                         &dut->ethernet_iob_wdata_i,
                         &dut->ethernet_iob_wstrb_i,
                         &dut->ethernet_iob_rdata_o,
                         &dut->ethernet_iob_rvalid_o,
                         &dut->ethernet_iob_ready_o};
#endif

#if (VM_TRACE == 1)
  Verilated::traceEverOn(true); // Enable tracing
  dut->trace(tfp, 1);
  tfp->open("uut.vcd");
#endif

  dut->clk_i = 0;
  dut->cke_i = 1;

  // Reset sequence
  dut->arst_i = 0;
  for (i = 0; i < 100; i++)
    Timer(CLK_PERIOD);
  dut->arst_i = 1;
  for (i = 0; i < 100; i++)
    Timer(CLK_PERIOD);
  dut->arst_i = 0;

  *(uart_if.iob_valid) = 0;
  *(uart_if.iob_wstrb) = 0;
  cpu_inituart(&uart_if);

  FILE *soc2cnsl_fd;
  FILE *cnsl2soc_fd;
  char cpu_char = 0;
  char rxread_reg = 0, txread_reg = 0;
  int able2write = 0, able2read = 0;

  while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL)
    ;
  fclose(cnsl2soc_fd);
  soc2cnsl_fd = fopen("./soc2cnsl", "wb");

#ifdef IOB_SYSTEM_USE_ETHERNET
  eth_setup(&eth_if);
#endif

  while (1) {
    while (!rxread_reg && !txread_reg) {
      rxread_reg = (char)iob_read(IOB_UART_RXREADY_ADDR, &uart_if);
      txread_reg = (char)iob_read(IOB_UART_TXREADY_ADDR, &uart_if);
    }
    if (rxread_reg) {
      cpu_char = (char)iob_read(IOB_UART_RXDATA_ADDR, &uart_if);
      fwrite(&cpu_char, sizeof(char), 1, soc2cnsl_fd);
      fflush(soc2cnsl_fd);
      rxread_reg = 0;
    }
    if (txread_reg) {
      if ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL) {
        fclose(soc2cnsl_fd);
        break;
      }
      able2write = fread(&cpu_char, sizeof(char), 1, cnsl2soc_fd);
      if (able2write > 0) {
        iob_write(IOB_UART_TXDATA_ADDR, cpu_char, IOB_UART_TXDATA_W / 8,
                  &uart_if);
        fclose(cnsl2soc_fd);
        cnsl2soc_fd = fopen("./cnsl2soc", "w");
      }
      fclose(cnsl2soc_fd);
      txread_reg = 0;
    }

#ifdef IOB_SYSTEM_USE_ETHERNET
    eth_relay_frames(&eth_if);
#endif
  }

  dut->final();

#if (VM_TRACE == 1)
  tfp->dump(main_time); // Dump last values
  tfp->close();         // Close tracing file
  VL_PRINTF("Generated vcd file\n");
  delete tfp;
#endif

  delete dut;
  dut = NULL;

  exit(0);
}

void cpu_inituart(iob_native_t *uart_if) {
  // pulse reset uart
  iob_write(IOB_UART_SOFTRESET_ADDR, 1, IOB_UART_SOFTRESET_W / 8, uart_if);
  iob_write(IOB_UART_SOFTRESET_ADDR, 0, IOB_UART_SOFTRESET_W / 8, uart_if);
  // config uart div factor
  iob_write(IOB_UART_DIV_ADDR, int(FREQ / BAUD), IOB_UART_DIV_W / 8, uart_if);
  // enable uart for receiving
  iob_write(IOB_UART_RXEN_ADDR, 1, IOB_UART_RXEN_W / 8, uart_if);
  iob_write(IOB_UART_TXEN_ADDR, 1, IOB_UART_TXEN_W / 8, uart_if);
}
