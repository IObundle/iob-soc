`timescale 1ns / 1ps

module iob_reg #(
    parameter BITS = 32,
    parameter rst_val = {BITS{1'b0}}
)(
    input [BITS-1:0] data_i,
    input clk,
    input rst,
    output reg [BITS-1:0] data_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= rst_val;
        end 
        else begin
            data_out <= data_i;
    end
    end
endmodule

`default_nettype wire