#include <stdio.h>
#include <stdlib.h>

#include "Vsystem.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

unsigned int main_time = 0; 

double sc_time_stamp () {
  return main_time;
}

int main(int argc, char **argv, char **env)
{
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  Vsystem* top = new Vsystem;
  VerilatedVcdC* tfp = new VerilatedVcdC;
  
  top->trace (tfp, 1);
  tfp->open ("waves.vcd");


  // Reset sequence 
  top->clk = 0;
  top->reset = 0;
  top->eval();
  tfp->dump(main_time);
  main_time++;
  
  top->clk=1;
  top->reset=0;
  top->eval();
  tfp->dump(main_time);
  main_time++;
        
  top->clk=0;
  top->reset=1;
  top->eval();
  tfp->dump(main_time);
  main_time++;        

  top->clk=1;
  top->reset=1;
  top->eval();
  tfp->dump(main_time);
  main_time++;        
  
  top->clk=0;
  top->reset=0;
  top->eval();
  tfp->dump(main_time);
  main_time++; 

  for (int i = 0; i<4000;i++){
  top->clk ^= 1UL << 0;
  top->eval();
  tfp->dump(main_time);
  main_time++; 
  }


  tfp->close();
  delete top;
  exit(0);

}
