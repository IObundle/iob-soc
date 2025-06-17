`timescale 1ns / 1ps

module iob_axil2iob #(
   parameter AXIL_ADDR_W = 21,           // AXI Lite address bus width in bits
   parameter AXIL_DATA_W = 21,           // AXI Lite data bus width in bits
   parameter ADDR_W      = AXIL_ADDR_W,  // IOb address bus width in bits
   parameter DATA_W      = AXIL_DATA_W   // IOb data bus width in bits
) (
   // Global signals
   `include "clk_en_rst_s_port.vs"

   // AXI4 Lite slave interface
   input  [    AXIL_ADDR_W-1:0] axil_awaddr_i,
   input  [              1-1:0] axil_awvalid_i,
   output [              1-1:0] axil_awready_o,
   input  [    AXIL_DATA_W-1:0] axil_wdata_i,
   input  [(AXIL_DATA_W/8)-1:0] axil_wstrb_i,
   input  [              1-1:0] axil_wvalid_i,
   output [              1-1:0] axil_wready_o,
   output [              2-1:0] axil_bresp_o,
   output [              1-1:0] axil_bvalid_o,
   input  [              1-1:0] axil_bready_i,
   input  [    AXIL_ADDR_W-1:0] axil_araddr_i,
   input  [              1-1:0] axil_arvalid_i,
   output [              1-1:0] axil_arready_o,
   output [    AXIL_DATA_W-1:0] axil_rdata_o,
   output [              2-1:0] axil_rresp_o,
   output [              1-1:0] axil_rvalid_o,
   input  [              1-1:0] axil_rready_i,

   // IOb master interface
   `include "iob_m_port.vs"
);

   localparam WSTRB_W = DATA_W / 8;

   wire [2:0] pc;
   reg [2:0] pc_nxt;
   
   //axil response
   reg                 axil_awready_nxt;
   reg                 axil_wready_nxt;
   reg                 axil_arready_nxt;
   reg                 axil_rvalid_nxt;
   reg [DATA_W-1:0]    axil_rdata_nxt;
   reg                 axil_bvalid_nxt;       
   assign axil_bresp_o = 2'b0;
   assign axil_rresp_o = 2'b0;

   //iob command
   reg                 iob_valid_nxt;
   reg [ADDR_W-1:0]    iob_addr_nxt;
   reg [WSTRB_W-1:0]   iob_wstrb_nxt;
   reg [DATA_W-1:0]    iob_wdata_nxt;
   assign iob_rready_o = 1'b1;
   
   always @* begin

      pc_nxt = pc+1'b1;

      //axil response
      axil_arready_nxt = 0;
      axil_rvalid_nxt = axil_rvalid_o;
      axil_rdata_nxt = axil_rdata_o;
      axil_awready_nxt = 0;
      axil_wready_nxt = 0;
      axil_bvalid_nxt = axil_bvalid_o;

      //iob command
      iob_valid_nxt = iob_valid_o;
      iob_addr_nxt = iob_addr_o;
      iob_wstrb_nxt = iob_wstrb_o;
      iob_wdata_nxt = iob_wdata_o;

      case (pc)
        0: begin //init state
           axil_rvalid_nxt = 1'b0;
           if(axil_arvalid_i) begin
              axil_arready_nxt = 1'b1;
              iob_valid_nxt = 1'b1;
              iob_addr_nxt = axil_araddr_i;
              iob_wstrb_nxt = {WSTRB_W{1'b0}};
              pc_nxt = 3'd4; //go wait for iob_ready
           end else if(axil_awvalid_i) begin
              axil_awready_nxt = 1'b1;
              iob_addr_nxt = axil_awaddr_i;
              if(axil_wvalid_i) begin
                 axil_wready_nxt = 1'b1;
                 iob_valid_nxt = 1'b1;
                 iob_wdata_nxt = axil_wdata_i;
                 iob_wstrb_nxt = axil_wstrb_i;
                 pc_nxt = 3'd2; //go wait for iob_ready 
              end
           end else begin 
              pc_nxt = pc;
           end
        end 
        1: begin //write: wait axil_wvalid
           if(!axil_wvalid_i) begin
              pc_nxt = pc;
           end else begin
              axil_wready_nxt = 1'b1;
              iob_valid_nxt = 1'b1;
              iob_wdata_nxt = axil_wdata_i;
              iob_wstrb_nxt = axil_wstrb_i;
           end
        end
        2: begin //write: wait for iob_ready
           if(!iob_ready_i) begin
              pc_nxt = pc;
           end else begin
              axil_bvalid_nxt = 1'b1;
              iob_valid_nxt = 1'b0;
           end
        end
        3: begin //write: wait for bready
           if(!axil_bready_i) begin
             pc_nxt = pc;
           end else begin
              axil_bvalid_nxt = 1'b0;
              pc_nxt = 3'd0;
           end 
        end
        4: begin //read: wait for iob_ready
           if(!iob_ready_i) begin
              pc_nxt = pc;
           end else begin
              iob_valid_nxt = 1'b0;
           end
        end
        5: begin //read: wait for iob_rvalid
           if(!iob_rvalid_i) begin
              pc_nxt = pc;
           end else begin
              axil_rvalid_nxt = 1'b1;
              axil_rdata_nxt = iob_rdata_i;
              pc_nxt = 3'd0;
           end
        end
        default: begin //read: wait for axil_rready
           if(!axil_rready_i) begin
              pc_nxt = pc;
           end else begin
              axil_rvalid_nxt = 1'b0;
              pc_nxt = 3'd0;
           end
        end
      
      endcase
   end

   //iob command registers
   iob_reg #(
                .DATA_W (ADDR_W),
                .RST_VAL(0)
                ) iob_reg_addr (
                                .clk_i (clk_i),
                                .cke_i (cke_i),
                                .arst_i(arst_i),
                                .data_i(iob_addr_nxt),
                                .data_o(iob_addr_o)
                                );

   iob_reg #(
                 .DATA_W (DATA_W),
                 .RST_VAL(0)
                 ) iob_reg_wdata (
                                  .clk_i (clk_i),
                                  .cke_i (cke_i),
                                  .arst_i(arst_i),
                                  .data_i(iob_wdata_nxt),
                                  .data_o(iob_wdata_o)
                                  );

   iob_reg #(
                .DATA_W (WSTRB_W),
                .RST_VAL(0)
                ) iob_reg_wstrb (
                                 .clk_i (clk_i),
                                 .cke_i (cke_i),
                                 .arst_i(arst_i),
                                 .data_i(iob_wstrb_nxt),
                                 .data_o(iob_wstrb_o)
                                 );
   iob_reg #(
                .DATA_W (1),
                .RST_VAL(0)
                ) iob_reg_valid (
                                 .clk_i (clk_i),
                                 .cke_i (cke_i),
                                 .arst_i(arst_i),
                                 .data_i(iob_valid_nxt),
                                 .data_o(iob_valid_o)
                                 );

   iob_reg #(
                .DATA_W (1),
                .RST_VAL(0)
                ) iob_reg_ready (
                                 .clk_i (clk_i),
                                 .cke_i (cke_i),
                                 .arst_i(arst_i),
                                 .data_i(axil_awready_nxt),
                                 .data_o(axil_awready_o)
                                 );

   iob_reg #(
                .DATA_W (1),
                .RST_VAL(0)
                ) iob_reg_wready (
                                  .clk_i (clk_i),
                                  .cke_i (cke_i),
                                  .arst_i(arst_i),
                                  .data_i(axil_wready_nxt),
                                  .data_o(axil_wready_o)
                                  );
   iob_reg #(
                .DATA_W (1),
                .RST_VAL(0)
                ) iob_reg_arready (
                                  .clk_i (clk_i),
                                  .cke_i (cke_i),
                                  .arst_i(arst_i),
                                  .data_i(axil_arready_nxt),
                                  .data_o(axil_arready_o)
                                  );
   iob_reg #(
                .DATA_W (DATA_W),
                .RST_VAL(0)
                ) iob_reg_rdata (
                                 .clk_i (clk_i),
                                 .cke_i (cke_i),
                                 .arst_i(arst_i),
                                 .data_i(axil_rdata_nxt),
                                 .data_o(axil_rdata_o)
                                 );

   iob_reg #(
                .DATA_W (1),
                .RST_VAL(0)
                ) iob_reg_rvalid (
                                  .clk_i (clk_i),
                                  .cke_i (cke_i),
                                  .arst_i(arst_i),
                                  .data_i(axil_rvalid_nxt),
                                  .data_o(axil_rvalid_o)
                                  );

   iob_reg #(
                .DATA_W (1),
                .RST_VAL(0)
                ) iob_reg_bvalid (
                                  .clk_i (clk_i),
                                  .cke_i (cke_i),
                                  .arst_i(arst_i),
                                  .data_i(axil_bvalid_nxt),
                                  .data_o(axil_bvalid_o)
                                  );

   //state register
   iob_reg #(
                .DATA_W (3),
                .RST_VAL(0)
                ) iob_reg_pc (
                              .clk_i (clk_i),
                              .cke_i (cke_i),
                              .arst_i(arst_i),
                              .data_i(pc_nxt),
                              .data_o(pc)
                              );

endmodule
