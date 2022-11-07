//
// CPU TASKS TO CONTROL THE TESTBENCH UART
//
//this is a temporary solution

`include "iob_uart_swreg_def.vh"

//file seek macros
`define SEEK_SET 0
`define SEEK_CUR 1
`define SEEK_END 2

// 1-cycle write
task cpu_uartwrite;
   input [2:0]  cpu_address;
   input [31:0] cpu_data;
   input [2:0] nbytes;
   reg [4:0] wstrb_int;
   begin
      #1 uart_addr = cpu_address[2]; // use 32 bit address
      uart_valid = 1;
      case (nbytes)
          1: wstrb_int = 4'b0001;
          2: wstrb_int = 4'b0011;
          default: wstrb_int = 4'b1111;
      endcase
      uart_wstrb = wstrb_int << (cpu_address[1:0]);
      uart_wdata = cpu_data << (cpu_address[1:0]*8);
      @ (posedge clk) #1 uart_wstrb = 0;
      uart_valid = 0;
   end
endtask //cpu_uartwrite

// 2-cycle read
task cpu_uartread;
   input [2:0]   cpu_address;
   output [31:0] read_reg;
   begin
      #1 uart_addr = cpu_address[2]; // use 32 bit address
      uart_valid = 1;
      @ (posedge clk) #1 
      read_reg = uart_rdata >> (cpu_address[1:0]*8);
      uart_valid = 0;
   end
endtask

task cpu_inituart;
   begin
      //pulse reset uart
      cpu_uartwrite(`UART_SOFTRESET_ADDR, 1, `UART_SOFTRESET_W/8);
      cpu_uartwrite(`UART_SOFTRESET_ADDR, 0, `UART_SOFTRESET_W/8);
      //config uart div factor
      cpu_uartwrite(`UART_DIV_ADDR, `FREQ/`BAUD, `UART_DIV_W/8);
      //enable uart for receiving
      cpu_uartwrite(`UART_RXEN_ADDR, 1, `UART_RXEN_W/8);
      cpu_uartwrite(`UART_TXEN_ADDR, 1, `UART_TXEN_W/8);
   end
endtask
