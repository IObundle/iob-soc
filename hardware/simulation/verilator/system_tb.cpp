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
#define CLK_PERIOD 10 // 20 ns

#define CONSOLE_DIR "../../../software/console/"

unsigned int main_time = 0;
char = 0;

double sc_time_stamp () {
  return main_time;
}

void Timer(Vsystem_top* dut, unsigned int half_cycles){
  for(int i = 0; i<half_cycles; i++){
    dut->clk = !(dut->clk);
    dut->eval();
    tfp->dump(main_time);
    main_time++;
  }
}

// 1-cycle write
void uartwrite(Vsystem_top* dut, unsigned int cpu_address, char cpu_data){
    //Timer(1, units="ns")
    dut->uart_addr = cpu_address;
    dut->uart_valid = 1;
    dut->uart_wstrb = -1;
    dut->uart_wdata = cpu_data;
    Timer(dut, 2);
    //RisingEdge(dut->clk)
    //Timer(1, units="ns")
    dut->uart_wstrb = 0;
    dut->uart_valid = 0;

}

// 2-cycle read
void uartread(Vsystem_top* dut, unsigned int cpu_address){
    //Timer(1, units="ns");
    dut->uart_addr = cpu_address;
    dut->uart_valid = 1;
    //RisingEdge(dut->clk);
    Timer(dut, 2);
    //Timer(1, units="ns");
    //print(dut.uart_rdata)
    read_reg = dut->uart_rdata;
    Timer(dut, 2);
    //RisingEdge(dut->clk);
    //Timer(1, units="ns");
    dut->uart_valid = 0;
    return read_reg;

}

void inituart(Vsystem_top* dut){
  //pulse reset uart
  uartwrite(dut, UART_SOFTRESET_ADDR, 1);
  uartwrite(dut, UART_SOFTRESET_ADDR, 0);
  //config uart div factor
  uartwrite(dut, UART_DIV_ADDR, int(FREQ/BAUD));
  //enable uart for receiving
  uartwrite(dut, UART_RXEN_ADDR, 1);
  uartwrite(dut, UART_TXEN_ADDR, 1);
}

int main(int argc, char **argv, char **env)
{
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  Vsystem_top* dut = new Vsystem_top;
  VerilatedVcdC* tfp = new VerilatedVcdC;

  dut->trace (tfp, 1);
  tfp->open ("waves.vcd");

  dut->clk = 0;
  dut->reset = 0;

  // Reset sequence
  for(int i = 0; i<5; i++){
    dut->clk = !(dut->clk);
    if(i==2 || i==4) dut->reset = !(dut->reset);
    dut->eval();
    tfp->dump(main_time);
    main_time++;
  }
  dut->uart_valid = 0
  dut->uart_wstrb = 0
  inituart(dut);

  printf("\n\nTESTBENCH: connecting");
  while(1){
    break;
  }
  printf("\nTESTBENCH: finished\n\n");

  tfp->close();
  delete dut;
  exit(0);

}
