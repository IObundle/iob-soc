   //
   // CPU TASKS
   //

   // 1-cycle write
   task cpu_uartwrite;
      input [3:0]  cpu_address;
      input [31:0] cpu_data;

      # 1 uart_addr = cpu_address;
      uart_valid = 1;
      uart_wstrb = 1;
      uart_wdata = cpu_data;
      @ (posedge clk) #1 uart_wstrb = 0;
      uart_valid = 0;
   endtask //cpu_uartwrite

   // 2-cycle read
   task cpu_uartread;
      input [3:0]   cpu_address;
      output [31:0] read_reg;

      # 1 uart_addr = cpu_address;
      uart_valid = 1;
      @ (posedge clk) #1 read_reg = uart_rdata;
      @ (posedge clk) #1 uart_valid = 0;
   endtask //cpu_uartread

   task cpu_sendfile;
      reg [`DATA_W-1:0] file_size;
      reg [7:0]         char;
      integer           fp;
      integer           res;
      integer           i, k;

      //signal target to expect data
      cpu_putchar(`FRX);

	  //print incoming messages
	  cpu_print();

	  //wait for target
	  do cpu_getchar(cpu_char);
      while (cpu_char != `FRX);

	  //open data file
      fp = $fopen("firmware.bin","rb");

      // Get file size
`define SEEK_SET 0
`define SEEK_CUR 1
`define SEEK_END 2

      res = $fseek(fp, 0, `SEEK_END);
      file_size = $ftell(fp);
      res = $rewind(fp);

	  //Signal target ACK
	  cpu_putchar(`ACK);

      $display("File size: %d bytes", file_size);

      //Send file size
      cpu_putchar(file_size[7:0]);
      cpu_putchar(file_size[15:8]);
      cpu_putchar(file_size[23:16]);
      cpu_putchar(file_size[31:24]);

	  //Send file
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

   endtask

   task cpu_receivefile;
      reg [`DATA_W-1:0] file_size;
      reg [7:0]         char;
      integer           fp;
      integer           i, k;

      //signal target to expect data
      cpu_putchar(`ETX);

      fp = $fopen("out.bin", "wb");

      cpu_print();

      // Send file size
      cpu_getchar(file_size[7:0]);
      cpu_getchar(file_size[15:8]);
      cpu_getchar(file_size[23:16]);
      cpu_getchar(file_size[31:24]);
      $display("File size: %d bytes", file_size);

      k = 0;
      for(i = 0; i < file_size; i++) begin
	     cpu_getchar(char);
         $fwrite(fp,"%c", char);

         if(i/4 == (file_size/4*k/100)) begin
            $write("%d%%\n", k);
            k=k+10;
         end
      end
      $write("%d%%\n", 100);

      $fclose(fp);

      cpu_print();

   endtask


   task cpu_inituart;
      //pulse reset uart
      cpu_uartwrite(`UART_SOFT_RESET, 1);
      cpu_uartwrite(`UART_SOFT_RESET, 0);
      //config uart div factor
      cpu_uartwrite(`UART_DIV, `FREQ/`BAUD);
      //enable uart for receiving
      cpu_uartwrite(`UART_RXEN, 1);
      cpu_uartwrite(`UART_TXEN, 1);
   endtask

   reg [7:0] rxread_reg = 8'b0;

   task cpu_getchar;
      output [7:0] rcv_char;

      //wait until something is received
      do
	    cpu_uartread(`UART_READ_VALID, rxread_reg);
      while(!rxread_reg);

      //read the data
      cpu_uartread(`UART_DATA, rxread_reg);

      rcv_char = rxread_reg[7:0];
   endtask


   task cpu_putchar;
      input [7:0] send_char;
      //wait until tx ready
      do begin
	 cpu_uartread(`UART_WRITE_WAIT, rxread_reg);
      end while(rxread_reg);
      //write the data
      cpu_uartwrite(`UART_DATA, send_char);

   endtask

   task cpu_getline;
      reg [7:0] char;
      do begin
         cpu_getchar(char);
         $write("%c", char);
      end while (char != "\n");
   endtask

   //connect with targe
   task cpu_connect;
      do cpu_getchar(cpu_char);
      while (cpu_char != `ENQ);
      cpu_putchar(`ACK);
   endtask

   task cpu_run;
      //do cpu_getchar(cpu_char);
      //while (cpu_char != `ENQ);
      cpu_putchar(`EOT);
      cpu_print();
   endtask

   task cpu_print;
      do cpu_getchar(cpu_char);
      while (cpu_char != `STX);

      cpu_getchar(cpu_char);
      while(cpu_char != `ETX && cpu_char != `ENQ) begin
         $write("%c", cpu_char);
         cpu_getchar(cpu_char);
      end

   endtask
