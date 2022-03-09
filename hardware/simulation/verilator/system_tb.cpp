#include <stdio.h>
#include <stdlib.h>

#include "Vsystem_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

// address macros
#define UART_SOFTRESET_ADDR 0
#define UART_DIV_ADDR 1
#define UART_TXDATA_ADDR 2
#define UART_TXEN_ADDR 3
#define UART_TXREADY_ADDR 4
#define UART_RXDATA_ADDR 5
#define UART_RXEN_ADDR 6
#define UART_RXREADY_ADDR 7

// other macros
#define FREQ 100000000
#define BAUD 5000000
#define CLK_PERIOD 10000 // 20 ns

vluint64_t main_time = 0;
VerilatedVcdC* tfp = NULL;
Vsystem_top* dut = NULL;

double sc_time_stamp () {
  return main_time;
}

void Timer(unsigned int half_cycles){
  for(int i = 0; i<half_cycles; i++){
    dut->clk = !(dut->clk);
    dut->eval();
    tfp->dump(main_time);
    main_time += CLK_PERIOD/2;
  }
}

// 1-cycle write
void uartwrite(unsigned int cpu_address, char cpu_data){

    dut->uart_addr = cpu_address;
    dut->uart_valid = 1;
    dut->uart_wstrb = -1;
    dut->uart_wdata = cpu_data;
    Timer(2);
    dut->uart_wstrb = 0;
    dut->uart_valid = 0;

}

// 2-cycle read
void uartread(unsigned int cpu_address, char *read_reg){
    dut->uart_addr = cpu_address;
    dut->uart_valid = 1;
    Timer(2);
    *read_reg = dut->uart_rdata;
    Timer(2);
    dut->uart_valid = 0;
}

void inituart(){
  //pulse reset uart
  uartwrite(UART_SOFTRESET_ADDR, 1);
  uartwrite(UART_SOFTRESET_ADDR, 0);
  //config uart div factor
  uartwrite(UART_DIV_ADDR, int(FREQ/BAUD));
  //enable uart for receiving
  uartwrite(UART_RXEN_ADDR, 1);
  uartwrite(UART_TXEN_ADDR, 1);
}

int main(int argc, char **argv, char **env){
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  dut = new Vsystem_top;
  tfp = new VerilatedVcdC;

  dut->trace(tfp, 1);
  tfp->open("waves.vcd");

  dut->clk = 0;
  dut->reset = 0;
  dut->eval();
  tfp->dump(main_time);

  // Reset sequence
  for(int i = 0; i<5; i++){
    dut->clk = !(dut->clk);
    if(i==2 || i==4) dut->reset = !(dut->reset);
    dut->eval();
    tfp->dump(main_time);
    main_time += CLK_PERIOD/2;
  }
  dut->uart_valid = 0;
  dut->uart_wstrb = 0;
  inituart();

  FILE *soc2cnsl_fd;
  FILE *cnsl2soc_fd;
  char cpu_char = 0;
  char rxread_reg = 0, txread_reg = 0;
  int n = 0;

  while ((soc2cnsl_fd = fopen("./soc2cnsl", "rb+")) == NULL){
    //printf("Could not open \"soc2cnsl\"\n");
  }

  printf("TESTBENCH: connecting\n");
  while(1){
    if(dut->trap > 0){
        printf("\nTESTBENCH: force cpu trap exit\n");
        fclose(soc2cnsl_fd);
        soc2cnsl_fd = fopen("./soc2cnsl", "wb");
        cpu_char = 4;
        fwrite(&cpu_char, sizeof(char), 1, soc2cnsl_fd);
        break;
    }
    while(!rxread_reg && !txread_reg){
      //$write("Loop %d: RX = %x; TX = %x\n", i, rxread_reg[0], txread_reg[0]);
      uartread(UART_RXREADY_ADDR, &rxread_reg);
      uartread(UART_TXREADY_ADDR, &txread_reg);
    }
    if(rxread_reg){
      n = fread(&cpu_char, sizeof(char), 1, soc2cnsl_fd);
      if(n == 0){
        uartread(UART_RXDATA_ADDR, &cpu_char);
        //printf("Test 1! %x\n", cpu_char);
        //$display("%x", cpu_char);
        n = fwrite(&cpu_char, sizeof(char), 1, soc2cnsl_fd);
        while(n != 0)
          n = fseek(soc2cnsl_fd, 0, 0);
        rxread_reg = 0;
      }
    }
    if(txread_reg){
      //$write("Enter TX\n");
      if ((cnsl2soc_fd = fopen("./cnsl2soc", "rb")) == NULL){
        //printf("Could not open file cnsl2soc!\n");
        break;
      }
      n = fread(&cpu_char, sizeof(char), 1, cnsl2soc_fd);
      //printf("Test 2! %x\n", cpu_char);
      if (n > 0){
        uartwrite(UART_TXDATA_ADDR, cpu_char);
        fclose(cnsl2soc_fd);
        cnsl2soc_fd = fopen("./cnsl2soc", "w");
      }
      fclose(cnsl2soc_fd);
      txread_reg = 0;
    }
  }
  fclose(soc2cnsl_fd);
  printf("TESTBENCH: finished\n\n");

  dut->final();
  tfp->close();
  delete dut;
  dut = NULL;
  exit(0);

}
