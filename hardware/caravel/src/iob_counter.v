`timescale 1ns / 1ps

module iob_counter #(
    parameter BITS = 32,
    parameter rst_val = {BITS{1'b0}}
    ) (
    //`include "clk_en_rst_s_port.vs"
    input rst,
    input en_i,
    input clk,
    input [BITS-1:0] Data_write,
    input Data_write_enb,
    output [BITS-1:0] data_o
    );
    reg [BITS-1:0] data;
    always @(posedge clk)begin
        if(Data_write_enb ==1'b1)begin
            data <= Data_write;
        end
        else if (en_i == 1'b1) begin
            data <= data_o + 1'b1;
        end
        else begin
            data <= data_o;
        end
    end
    iob_reg #(
        .BITS(BITS),
        .rst_val(rst_val)
     ) reg0 (
        //`include "clk_en_rst_s_s_portmap.vs"
        .clk(clk),
        .rst(rst),
        .data_i(data),
        .data_out(data_o)
        );
endmodule