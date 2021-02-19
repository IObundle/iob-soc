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
      # 1 uart_addr = cpu_address;
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
      # 1 uart_addr = cpu_address;
      uart_valid = 1;
      @ (posedge clk) #1 read_reg = uart_rdata;
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

task cpu_getchar;
   output [7:0] rcv_char;
   reg [31:0]   rxread_reg;
   begin 
      //wait until something is received
      do
        cpu_uartread(`UART_RXREADY_ADDR, rxread_reg);
      while(!rxread_reg);
      
      //read the data
      cpu_uartread(`UART_RXDATA_ADDR, rxread_reg);
   end
   rcv_char = rxread_reg[7:0];
   //$write("%c", rcv_char);
endtask

task cpu_putchar;
   input [7:0] send_char;
   reg [31:0]  rxread_reg;
   begin
      //wait until tx ready
      do begin
	 cpu_uartread(`UART_TXREADY_ADDR, rxread_reg);
      end while(!rxread_reg);
      //write the data
      cpu_uartwrite(`UART_TXDATA_ADDR, send_char);
   end
endtask

task cpu_recvstr;
   output [8*80-1:0] name;
   integer           k;
   reg [7:0]         rcv_char;
   
   begin
      name = {8*80{1'b0}};
      k=0;
      do begin
         cpu_getchar(rcv_char);
         name[8*80-(8*k)-1 -: 8] = rcv_char;          
         k = k + 1;          
      end while (rcv_char);
   end
endtask

task cpu_sendfile;
   reg [`DATA_W-1:0] file_size;
   reg [7:0]         char;
   integer           fp;
   integer           res;
   integer           i, j, k;
   reg [0:8*80-1]    name;
   string            name_str;
   
   begin

      //receive file name
      cpu_recvstr(name);
      name_str = name;
      $display("TESBENCH: sending file %s", name_str);

      //open data file
      fp = $fopen(name_str,"rb"); //to support icarus
      if(!fp)
        fp = $fopen(name,"rb"); //to support ncsim

      if(!fp)
        begin
           $display("TESTBENCH: can't open file to send\n");
           $finish;
        end
      
      //get file size
      res = $fseek(fp, 0, `SEEK_END);
      file_size = $ftell(fp);
      res = $rewind(fp);

      $display("File size: %d bytes", file_size);
      
      //send file size
      cpu_putchar(file_size[7:0]);
      cpu_putchar(file_size[15:8]);
      cpu_putchar(file_size[23:16]);
      cpu_putchar(file_size[31:24]);
      
      //send file
      k = 0;
      for(i = 0; i < file_size; i++) begin
         cpu_putchar($fgetc(fp));
         
         if(i/4 == (file_size/4*k/100)) begin
            $write("%d%%\n", k);
            k=k+10;
         end
      end
      $write("%d%%\n", 100);
      $fclose(fp);
   end
endtask

task cpu_recvfile;
   reg [`DATA_W-1:0] file_size;
   reg [7:0]         char;
   integer           fp;
   integer           i, k;
   reg [8*80-1:0]    name;
   string            name_str;

   begin
      //receive file name
      cpu_recvstr(name);
      name_str = name;
      
      $display("TESBENCH: receiving file %s", name_str);
        
      fp = $fopen(name_str, "wb"); //to support icarus

      if(!fp)
        fp = $fopen(name, "wb"); //to support ncsim

      if(!fp) begin
         $display("TESTBENCH: can't open file to store received data\n");
         $finish;
      end
      
      //receive file size
      cpu_getchar(file_size[7:0]);
      cpu_getchar(file_size[15:8]);
      cpu_getchar(file_size[23:16]);
      cpu_getchar(file_size[31:24]);
      $display("TESTBENCH: file size: %d bytes", file_size);

      k = 0;
      for(i = 0; i < file_size; i++) begin
	 cpu_getchar(char);
         $fwrite(fp, "%c", char);

         if(i/4 == (file_size/4*k/100)) begin
            $write("%d%%\n", k);
            k=k+10;
         end
      end
      $write("%d%%\n", 100);
      $fclose(fp);
   end
endtask


