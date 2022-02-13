//
// CPU TASKS TO CONTROL THE TESTBENCH UART
//
//this is a temporary solution

//address macros
`define UART_SOFTRESET_ADDR 0
`define UART_DIV_ADDR 1
`define UART_TXDATA_ADDR 2
`define UART_TXEN_ADDR 3
`define UART_TXREADY_ADDR 4
`define UART_RXDATA_ADDR 5
`define UART_RXEN_ADDR 6
`define UART_RXREADY_ADDR 7

//file seek macros
`define SEEK_SET 0
`define SEEK_CUR 1
`define SEEK_END 2

// 1-cycle write
task cpu_uartwrite;
   input [3:0]  cpu_address;
   input [31:0] cpu_data;
   begin
      #1 uart_addr = cpu_address;
      uart_valid = 1;
      uart_wstrb = 4'hf;
      uart_wdata = cpu_data;
      @ (posedge clk) #1 uart_wstrb = 0;
      uart_valid = 0;
   end
endtask //cpu_uartwrite

// 2-cycle read
task cpu_uartread;
   input [3:0]   cpu_address;
   output [31:0] read_reg;
   begin
      #1 uart_addr = cpu_address;
      uart_valid = 1;
      @ (posedge clk) #1 read_reg = {24'd0, uart_rdata[7:0]};
      @ (posedge clk) #1 uart_valid = 0;
   end
endtask

task cpu_inituart;
   begin
      //pulse reset uart
      cpu_uartwrite(`UART_SOFTRESET_ADDR, 1);
      cpu_uartwrite(`UART_SOFTRESET_ADDR, 0);
      //config uart div factor
      cpu_uartwrite(`UART_DIV_ADDR, `FREQ/`BAUD);
      //enable uart for receiving
      cpu_uartwrite(`UART_RXEN_ADDR, 1);
      cpu_uartwrite(`UART_TXEN_ADDR, 1);
   end
endtask
