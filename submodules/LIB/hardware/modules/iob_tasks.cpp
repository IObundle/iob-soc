#include "iob_tasks.h"

// Keep track of simulation time
vluint64_t main_time = 0;

// Store timer related settings (clk and eval)
timer_settings_t task_timer_settings;

// Set a signal value with correct data type
static void set_signal(void *signal, signal_datatype_t data_type, unsigned int data){
  switch(data_type){
    case USINT:
      *(unsigned short int*)signal = data;
      break;
    case UCHAR:
      *(unsigned char*)signal = data;
      break;
    default:
      *(unsigned int*)signal = data;
  }
}

//
// Verilator functions to drive the IOb Native protocol
//

// Write data to IOb Native slave
// 1-cycle write
void iob_write(unsigned int cpu_address, unsigned int cpu_data,
               unsigned int nbytes, iob_native_t *native_if) {
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
  set_signal(native_if->iob_addr, native_if->iob_addr_type, cpu_address);
  *(native_if->iob_valid) = 1;
  *(native_if->iob_wstrb) = wstrb_int << (cpu_address & 0b011);
  *(native_if->iob_wdata) = cpu_data
                      << ((cpu_address & 0b011) * 8); // align data to 32 bits
  Timer(CLK_PERIOD);
  *(native_if->iob_wstrb) = 0;
  *(native_if->iob_valid) = 0;
}

// Read data from IOb Native slave
// 2-cycle read
char iob_read(unsigned int cpu_address, iob_native_t *native_if) {
  char read_reg = 0;
  set_signal(native_if->iob_addr, native_if->iob_addr_type, cpu_address);
  *(native_if->iob_valid) = 1;
  Timer(CLK_PERIOD);
  read_reg =
      *(native_if->iob_rdata) >> ((cpu_address & 0b011) * 8); // align to 32 bits
  *(native_if->iob_valid) = 0;
  return read_reg;
}

// Delay
void Timer(unsigned int ns) {
  for (int i = 0; i < ns; i++) {
    if (!(main_time % (CLK_PERIOD / 2))) {
      *(task_timer_settings.clk) = !*(task_timer_settings.clk);
      (*task_timer_settings.eval)();
    // To add a new clk follow the example
    // if(!(main_time%(EXAMPLE_CLK_PERIOD/2))){
    //   *(task_timer_settings.example_clk) = !*(task_timer_settings.example_clk);

    // Also eval 1ns after edge
    } else if (!((main_time-1) % (CLK_PERIOD / 2))) {
      (*task_timer_settings.eval)();
    }
#if (VM_TRACE == 1)
    (*task_timer_settings.dump)(main_time); // Dump values into tracing file
#endif
    main_time += 1;
  }
}

