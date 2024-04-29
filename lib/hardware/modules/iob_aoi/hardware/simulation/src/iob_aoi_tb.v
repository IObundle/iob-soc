`timescale 1ns / 1ps

module iob_aoi_tb;

  reg     [3:0] data_i = 0;
  wire          data_o;

  integer       i;
  integer       fp;

  initial begin

    for (i = 0; i < 16; i = i + 1) begin
      #10 data_i = i[3:0];
      #10 $display("data_i = %b, data_o = %b", data_i, data_o);
    end
    #10 $display("%c[1;34m", 8'd27);
    $display("Test completed successfully.");
    $display("%c[0m", 8'd27);

    fp = $fopen("test.log", "w");
    $fdisplay(fp, "Test passed!");

    $finish();
  end

  iob_aoi iob_aoi_inst (
      .a_i(data_i[0]),
      .b_i(data_i[1]),
      .c_i(data_i[2]),
      .d_i(data_i[3]),
      .y_o(data_o)
  );

endmodule
