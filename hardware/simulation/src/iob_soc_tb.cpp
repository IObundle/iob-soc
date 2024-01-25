#include <stdio.h>
#include <stdlib.h>

#include "Viob_soc_sim_wrapper.h"
#include "bsp.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "iob_soc_conf.h"
#include "iob_uart_swreg.h"

// other macros
#define CLK_PERIOD 1000000000 / FREQ // 1/100MHz*10^9 = 10 ns

vluint64_t main_time = 0;
VerilatedVcdC *tfp = NULL;
Viob_soc_sim_wrapper *dut = NULL;

double sc_time_stamp() { return main_time; }

void Timer(unsigned int ns) {
  for (int i = 0; i < ns; i++) {
    if (!(main_time % (CLK_PERIOD / 2))) {
      dut->clk_i = !(dut->clk_i);
      dut->eval();
    }
    // To add a new clk follow the example
    // if(!(main_time%(EXAMPLE_CLK_PERIOD/2))){
    //  dut->example_clk_in = !(dut->example_clk_in);
    //}
    main_time += 1;
  }
}

// 1-cycle write
void uartwrite(unsigned int cpu_address, unsigned int cpu_data,
               unsigned int nbytes) {
  char wstrb_int = 0;
  switch (nbytes) {
  case 1:
    wstrb_int = 0b01;
    break;
  case 2:
    wstrb_int = 0b011;
    break;
  default:
    wstrb_int = 0b01111;
    break;
  }
  dut->uart_addr_i = cpu_address;
  dut->uart_valid_i = 1;
  dut->uart_wstrb_i = wstrb_int << (cpu_address & 0b011);
  dut->uart_wdata_i = cpu_data
                      << ((cpu_address & 0b011) * 8); // align data to 32 bits
  if (!dut->uart_ready_o) {
    Timer(CLK_PERIOD);
  }
  Timer(CLK_PERIOD);
  dut->uart_wstrb_i = 0;
  dut->uart_valid_i = 0;
}

void uartread(unsigned int cpu_address, char *read_reg) {
  dut->uart_addr_i = cpu_address;
  dut->uart_valid_i = 1;
  if (!dut->uart_ready_o) {
    Timer(CLK_PERIOD);
  }
  Timer(CLK_PERIOD);
  dut->uart_valid_i = 0;
  if (!dut->uart_rvalid_o) {
    Timer(CLK_PERIOD);
  }
  Timer(CLK_PERIOD);
  *read_reg =
      (dut->uart_rdata_o) >> ((cpu_address & 0b011) * 8); // align to 32 bits
}

void inituart() {
  // pulse reset uart
  uartwrite(IOB_UART_SOFTRESET_ADDR, 1, IOB_UART_SOFTRESET_W / 8);
  uartwrite(IOB_UART_SOFTRESET_ADDR, 0, IOB_UART_SOFTRESET_W / 8);
  // config uart div factor
  uartwrite(IOB_UART_DIV_ADDR, int(FREQ / BAUD), IOB_UART_DIV_W / 8);
  // enable uart for receiving
  uartwrite(IOB_UART_RXEN_ADDR, 1, IOB_UART_RXEN_W / 8);
  uartwrite(IOB_UART_TXEN_ADDR, 1, IOB_UART_TXEN_W / 8);
}

int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  dut = new Viob_soc_sim_wrapper;

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

  dut->uart_valid_i = 0;
  dut->uart_wstrb_i = 0;
  inituart();

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
      uartread(IOB_UART_RXREADY_ADDR, &rxread_reg);
      uartread(IOB_UART_TXREADY_ADDR, &txread_reg);
    }
    if (rxread_reg) {
      uartread(IOB_UART_RXDATA_ADDR, &cpu_char);
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
        uartwrite(IOB_UART_TXDATA_ADDR, cpu_char, IOB_UART_TXDATA_W / 8);
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
