#include <stdio.h>
#include <stdlib.h>

#include "Vsystem_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "iob_uart_swreg.h"

// other macros
#define CLK_PERIOD 1000000000/FREQ // 1/100MHz*10^9 = 10 ns

vluint64_t main_time = 0;
VerilatedVcdC* tfp = NULL;
Vsystem_top* dut = NULL;

double sc_time_stamp () {
  return main_time;
}

void Timer(unsigned int ns){
  for(int i = 0; i<ns; i++){
    if(!(main_time%(CLK_PERIOD/2))){
      dut->clk = !(dut->clk);
      dut->eval();
    }
    // To add a new clk follow the example
    //if(!(main_time%(EXAMPLE_CLK_PERIOD/2))){
    //  dut->example_clk_in = !(dut->example_clk_in);
    //}
    main_time += 1;
  }
}

// 1-cycle write
void uartwrite(unsigned int cpu_address, unsigned int cpu_data, unsigned int nbytes){
    char wstrb_int = 0;
    switch (nbytes) {
        case 1:  wstrb_int = 0b01; break;
        case 2:  wstrb_int = 0b011; break;
        default: wstrb_int = 0b01111; break;
    }
    dut->uart_addr = cpu_address >> 2; // 32 bit address (ignore 2 LSBs)
    dut->uart_valid = 1;
    dut->uart_wstrb = wstrb_int << (cpu_address & 0b011);
    dut->uart_wdata = cpu_data << ((cpu_address & 0b011)*8); // align data to 32 bits
    Timer(CLK_PERIOD);
    dut->uart_wstrb = 0;
    dut->uart_valid = 0;
}

// 2-cycle read
void uartread(unsigned int cpu_address, char *read_reg){
    dut->uart_addr = cpu_address >> 2; // 32 bit address (ignore 2 LSBs)
    dut->uart_valid = 1;
    Timer(CLK_PERIOD);
    *read_reg = (dut->uart_rdata) >> ((cpu_address & 0b011)*8); // align to 32 bits
    dut->uart_valid = 0;
}

void inituart(){
  //pulse reset uart
  uartwrite(UART_SOFTRESET, 1, UART_SOFTRESET_W/8);
  uartwrite(UART_SOFTRESET, 0, UART_SOFTRESET_W/8);
  //config uart div factor
  uartwrite(UART_DIV, int(FREQ/BAUD), UART_DIV_W/8);
  //enable uart for receiving
  uartwrite(UART_RXEN, 1, UART_RXEN_W/8);
  uartwrite(UART_TXEN, 1, UART_TXEN_W/8);
}

int main(int argc, char **argv, char **env){
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  dut = new Vsystem_top;

#ifdef VCD
  tfp = new VerilatedVcdC;

  dut->trace(tfp, 1);
  tfp->open("system.vcd");
#endif

  dut->clk = 0;
  dut->rst = 0;

  // Reset sequence
  Timer(100);
  dut->rst = 1;
  Timer(100);
  dut->rst = 0;

  dut->uart_valid = 0;
  dut->uart_wstrb = 0;
  inituart();

  FILE *soc2cnsl_fd;
  FILE *cnsl2soc_fd;
  char cpu_char = 0;
  char rxread_reg = 0, txread_reg = 0;
  int able2write = 0, able2read = 0;

  while ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL);
  fclose(cnsl2soc_fd);

  while(1){
    if(dut->trap > 0){
        printf("\nTESTBENCH: force cpu trap exit\n");
        soc2cnsl_fd = fopen("./soc2cnsl", "wb");
        cpu_char = 4;
        fwrite(&cpu_char, sizeof(char), 1, soc2cnsl_fd);
        fclose(soc2cnsl_fd);
        break;
    }
    while(!rxread_reg && !txread_reg){
      uartread(UART_RXREADY, &rxread_reg);
      uartread(UART_TXREADY, &txread_reg);
    }
    if(rxread_reg){
      if((soc2cnsl_fd = fopen("./soc2cnsl", "rb")) != NULL){
        able2read = fread(&cpu_char, sizeof(char), 1, soc2cnsl_fd);
        if(able2read == 0){
          fclose(soc2cnsl_fd);
          uartread(UART_RXDATA, &cpu_char);
          soc2cnsl_fd = fopen("./soc2cnsl", "wb");
          fwrite(&cpu_char, sizeof(char), 1, soc2cnsl_fd);
          rxread_reg = 0;
        }
        fclose(soc2cnsl_fd);
      }
    }
    if(txread_reg){
      if ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL){
        break;
      }
      able2write = fread(&cpu_char, sizeof(char), 1, cnsl2soc_fd);
      if (able2write > 0){
        uartwrite(UART_TXDATA, cpu_char, UART_TXDATA_W/8);
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
