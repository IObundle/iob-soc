`timescale 1ns / 1ps

module mm2ss_interconnect
  #(
    parameter N_MASTERS = 2,
    parameter ADDR_W = 32,
    parameter DATA_W = 32
    )
   (
    //  input                             clk,
    //  input                             rst,

    //front-end 
    input [N_MASTERS*(1+ADDR_W+DATA_W+DATA_W/8)-1:0] cat_bus_fe_in, //n*(valid+addr+wdata+wstrb)
    output [N_MASTERS*(1+DATA_W)-1:0]                cat_bus_fe_out, //n*(ready+rdata)


    //back-end 
    input [DATA_W:0]                                 cat_bus_be_in, //ready+rdata
    output [ADDR_W+DATA_W+DATA_W/8:0]                cat_bus_be_out //valid+addr+wdata+wstrb
    );

   //parameter N_MASTERS_W = $clog2(N_MASTERS);

   parameter BUS_IN_LEN = 1+ADDR_W+DATA_W+DATA_W/8;
   parameter BUS_OUT_LEN = 1+DATA_W;
   
   //extract valid bit mask;
   wire [N_MASTERS-1:0]                              m_valid;
   genvar                                            i;
   generate for (i=0; i<N_MASTERS; i=i+1) begin: vb_loop
      assign m_valid[i] = cat_bus_in[(i+1)*BUS_IN_LEN-1];
   end
   endgenerate

   //PRIORITY ENCODE CAT BUS
   wire [BUS_IN_LEN-1:0]  pe_out;
   priority_enc 
     #(
       .N(N_MASTERS), .M(BUS_IN_LEN)
       ) 
   pe (
       .valid(m_valid),
       .word_in({cat_bus_fe_in}),
       .word_out(cat_bus_be_out)
       );


   //GET RESPONSE CAT WORD 

   //compute leading 1 mask of valid bit mask
   wire [N_MASTERS-1:0]               l1me;    
   leading1_mask_enc #(.N(N_MASTERS)) l1mencoder (.valid(m_valid), .l1me(l1me));

   //expand back-end input bus using leading 1 mask
   expand_word
     #(
       .N(N_MASTERS), .M(BUS_OUT_LEN)
       ) 
   word_epander 
     (
       .valid(l1me),
       .word_in({cat_bus_be_in}),
       .word_out(cat_bus_fe_out)
       );

  /* 
   always @(posedge clk, posedge rst)
     if(rst)
       m_valid_reg <= {N_MASTERS{1'b0}};
     else
       m_valid_reg <= m_valid;
    */ 

                     
endmodule
