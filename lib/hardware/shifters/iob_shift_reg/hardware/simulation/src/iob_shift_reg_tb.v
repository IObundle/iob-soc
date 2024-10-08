// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_shift_reg_tb;

  localparam DATA_W = 8;
  localparam N = 10;
  localparam ADDR_W = $clog2(N);

  localparam TESTSIZE = 2 ** ADDR_W;

  reg               arst = 0;
  reg               clk = 0;
  reg               cke = 1;

  reg               rst = 0;
  reg               en = 0;
  reg               ld = 0;

  reg  [DATA_W-1:0] data_i;
  wire [DATA_W-1:0] data_o;


  parameter CLK_PER = 10;  // clk period = 10 timeticks
  always #(CLK_PER / 2) clk = ~clk;

  integer i, j;  //iterators
  integer                       fd;

  reg     [TESTSIZE*DATA_W-1:0] test_data;
  reg     [TESTSIZE*DATA_W-1:0] read_data;

  //FIFO memory
  wire                          ext_mem_clk;
  wire                          ext_mem_w_en;
  wire    [         DATA_W-1:0] ext_mem_w_data;
  wire    [         ADDR_W-1:0] ext_mem_w_addr;
  wire                          ext_mem_r_en;
  wire    [         ADDR_W-1:0] ext_mem_r_addr;
  wire    [         DATA_W-1:0] ext_mem_r_data;


  //WRITE
  initial begin
    //create the test data
    for (i = 0; i < TESTSIZE; i = i + 1) test_data[i*DATA_W+:DATA_W] = i[0+:DATA_W];

    // optional VCD
`ifdef VCD
    $dumpfile("uut.vcd");
    $dumpvars();
`endif
    repeat (4) @(posedge clk) #1;
    en = 0;

    #8 arst = 1;
    #CLK_PER @(posedge clk) #1;
    arst = 0;
    repeat (4) @(posedge clk) #1;
    ld = 1;
    @(posedge clk) #1;
    ld = 0;
    repeat (4) @(posedge clk) #1;

    for (i = 0; i < 2 ** (ADDR_W + 1); i = i + 1) begin
      en = 1;
      data_i = test_data[i*DATA_W+:DATA_W];
      if (i < N && data_o !== 0) begin
        $fatal(1, "ERROR: got %d, expected 0 while not full\n", data_o);
      end
      if (i >= N && data_o !== test_data[(i-N)*DATA_W+:DATA_W]) begin
        $fatal(1, "ERROR: got %d, expected %d", data_o, test_data[(i-N)*DATA_W+:DATA_W]);
      end
      @(posedge clk) #1;
    end
    en = 0;

    $display("%c[1;34m", 27);
    $display("Test completed successfully.");
    $display("%c[0m", 27);

    fd = $fopen("test.log", "w");
    $fdisplay(fd, "Test passed!");
    $fclose(fd);

    #1000 $finish();

  end

  // Instantiate the Unit Under Test (UUT)
  iob_shift_reg #(
      .DATA_W(DATA_W),
      .N(N)
  ) uut (
      .clk_i (clk),
      .arst_i(arst),
      .cke_i (cke),

      .en_i  (en),
      .rst_i (rst),
      .data_i(data_i),
      .data_o(data_o),

      .ext_mem_clk_o   (ext_mem_clk),
      .ext_mem_w_en_o  (ext_mem_w_en),
      .ext_mem_w_addr_o(ext_mem_w_addr),
      .ext_mem_w_data_o(ext_mem_w_data),
      .ext_mem_r_en_o  (ext_mem_r_en),
      .ext_mem_r_addr_o(ext_mem_r_addr),
      .ext_mem_r_data_i(ext_mem_r_data)
  );

  iob_ram_t2p #(
      .DATA_W(DATA_W),
      .ADDR_W(ADDR_W)
  ) iob_ram_t2p_inst (
      .clk_i   (ext_mem_clk),
      .w_en_i  (ext_mem_w_en),
      .w_addr_i(ext_mem_w_addr),
      .w_data_i(ext_mem_w_data),
      .r_en_i  (ext_mem_r_en),
      .r_addr_i(ext_mem_r_addr),
      .r_data_o(ext_mem_r_data)
  );

endmodule
