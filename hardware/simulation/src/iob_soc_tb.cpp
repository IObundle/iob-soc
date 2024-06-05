#include <stdio.h>
#include <stdlib.h>

#include "Viob_soc_sim_wrapper.h"
#include "bsp.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "iob_tasks.h"

#include "iob_soc_conf.h"
#include "iob_uart_swreg.h"

// other macros
#define CLK_PERIOD 1000000000 / FREQ // 1/100MHz*10^9 = 10 ns

VerilatedVcdC *tfp = NULL;
Viob_soc_sim_wrapper *dut = NULL;

double sc_time_stamp() { return main_time; }

void inituart(iob_native_t *uart_if) {
  // pulse reset uart
  iob_write(IOB_UART_SOFTRESET_ADDR, 1, IOB_UART_SOFTRESET_W / 8, uart_if);
  iob_write(IOB_UART_SOFTRESET_ADDR, 0, IOB_UART_SOFTRESET_W / 8, uart_if);
  // config uart div factor
  iob_write(IOB_UART_DIV_ADDR, int(FREQ / BAUD), IOB_UART_DIV_W / 8, uart_if);
  // enable uart for receiving
  iob_write(IOB_UART_RXEN_ADDR, 1, IOB_UART_RXEN_W / 8, uart_if);
  iob_write(IOB_UART_TXEN_ADDR, 1, IOB_UART_TXEN_W / 8, uart_if);
}

int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  dut = new Viob_soc_sim_wrapper;
  timer_settings.clk = &dut->clk_i;
  timer_settings.eval = &dut->eval;

  iob_native_t uart_if = {
    &dut->uart_valid_i,
    &dut->uart_addr_i,
    &dut->uart_wdata_i,
    &dut->uart_wstrb_i,
    &dut->uart_rdata_o,
    &dut->uart_rvalid_o,
    &dut->uart_ready_o
  }

  iob_native_t eth_if = {
    &dut->ethernet_valid_i,
    &dut->ethernet_addr_i,
    &dut->ethernet_wdata_i,
    &dut->ethernet_wstrb_i,
    &dut->ethernet_rdata_o,
    &dut->ethernet_rvalid_o,
    &dut->ethernet_ready_o
  }

#ifdef VCD
  tfp = new VerilatedVcdC;

  dut->trace(tfp, 1);
  tfp->open("uut.vcd");
#endif

  dut->clk_i = 0;
  dut->arst_i = 0;

  // Reset sequence
  Timer(100);
  dut->arst_i = 1;
  Timer(100);
  dut->arst_i = 0;

  *(uart_if.iob_valid) = 0;
  *(uart_if.iob_wstrb) = 0;
  inituart(&uart_if);
  // TODO: Launch parallel ethernet driver

  FILE *soc2cnsl_fd;
  FILE *cnsl2soc_fd;
  char cpu_char = 0;
  char rxread_reg = 0, txread_reg = 0;
  int able2write = 0, able2read = 0;

  while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL)
    ;
  fclose(cnsl2soc_fd);
  soc2cnsl_fd = fopen("./soc2cnsl", "wb");

  while (1) {
    if (dut->trap_o > 0) {
      printf("\nTESTBENCH: force cpu trap exit\n");
      cpu_char = 4;
      fwrite(&cpu_char, sizeof(char), 1, soc2cnsl_fd);
      fclose(soc2cnsl_fd);
      break;
    }
    while (!rxread_reg && !txread_reg) {
      rxread_reg = iob_read(IOB_UART_RXREADY_ADDR, &uart_if);
      txread_reg = iob_read(IOB_UART_TXREADY_ADDR, &uart_if);
    }
    if (rxread_reg) {
      cpu_char = iob_read(IOB_UART_RXDATA_ADDR, &uart_if);
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
        iob_write(IOB_UART_TXDATA_ADDR, cpu_char, IOB_UART_TXDATA_W / 8, &uart_if);
        fclose(cnsl2soc_fd);
        cnsl2soc_fd = fopen("./cnsl2soc", "w");
      }
      fclose(cnsl2soc_fd);
      txread_reg = 0;
    }
  }

  dut->final();
#ifdef VCD
  tfp->close();
#endif
  delete dut;
  dut = NULL;
  exit(0);
}
