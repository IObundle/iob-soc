// (C) 2001-2012 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/12.1/ip/merlin/altera_merlin_master_translator/altera_merlin_master_translator.sv#1 $
// $Revision: #1 $
// $Date: 2012/08/12 $
// $Author: swbranch $

// --------------------------------------
// Merlin Master Translator
//
// Converts Avalon-MM Master Interfaces into
// Avalon-MM Universal Master Interfaces
// --------------------------------------

`timescale 1 ns / 1 ns



module altera_merlin_master_translator #(
    parameter
					 AV_ADDRESS_W                      = 32,
					 AV_DATA_W                         = 32,
					 AV_BURSTCOUNT_W                   = 4,
					 AV_BYTEENABLE_W                   = 4,
	     
					 //Optional Port Declarations
					 
					 USE_BURSTCOUNT                    = 1,
					 USE_BEGINBURSTTRANSFER            = 0,
					 USE_BEGINTRANSFER                 = 0,
					 USE_CHIPSELECT                    = 0,
					 USE_READ                          = 1,
					 USE_READDATAVALID                 = 1,
					 USE_WRITE                         = 1,
					 USE_WAITREQUEST                   = 1,

                                         AV_REGISTERINCOMINGSIGNALS        = 0,
					 AV_SYMBOLS_PER_WORD               = 4,
					 AV_ADDRESS_SYMBOLS                = 0,
					 AV_CONSTANT_BURST_BEHAVIOR        = 1, 
					 AV_BURSTCOUNT_SYMBOLS             = 0,
					 AV_LINEWRAPBURSTS                 = 0, 
					 UAV_ADDRESS_W                     = 38,
					 UAV_BURSTCOUNT_W                  = 10,
                                         UAV_CONSTANT_BURST_BEHAVIOR       = 0
					 )(
					    //Universal Avalon Master
					    input   wire                                                  clk,
					    input   wire                                                  reset,
                                            output  reg                                                   uav_write,
					    output  reg                                                   uav_read,
                                            output  reg  [UAV_ADDRESS_W    -1 : 0]             		  uav_address,	 
                                            output  reg  [UAV_BURSTCOUNT_W -1 : 0]                    	  uav_burstcount,					    
                                            output  wire [AV_BYTEENABLE_W  -1 : 0]                        uav_byteenable,
                                            output  wire [AV_DATA_W        -1 : 0]                        uav_writedata,
					    output  wire                                                  uav_lock,
                                            output  wire                                                  uav_debugaccess,
                                            output  wire                                                  uav_clken,
					    
					    input wire   [ AV_DATA_W       -1 : 0]                        uav_readdata,
					    input wire                                                    uav_readdatavalid,
					    input wire                                                    uav_waitrequest,
					  					    
					    //Avalon-MM !Master
					    input reg                                                     av_write,
					    input reg                                                     av_read,
					    input wire   [AV_ADDRESS_W    -1 : 0]                         av_address,
					    input wire   [AV_BYTEENABLE_W -1 : 0]                         av_byteenable,
					    input wire   [AV_BURSTCOUNT_W -1 : 0]                         av_burstcount,
					    input wire   [AV_DATA_W       -1 : 0]                         av_writedata,
					    input wire                                                    av_begintransfer,
					    input wire                                                    av_beginbursttransfer,
					    input wire                                                    av_lock,
					    input wire                                                    av_chipselect,
                                            input wire                                                    av_debugaccess,
                                            input wire                                                    av_clken,
					    
					    output wire  [AV_DATA_W       -1 : 0]                         av_readdata,
					    output wire                                                   av_readdatavalid,
					    output reg                                                    av_waitrequest
					    );


   localparam BITS_PER_WORD       = clog2(AV_SYMBOLS_PER_WORD - 1);   
   localparam AV_MAX_SYMBOL_BURST = flog2( pow2(AV_BURSTCOUNT_W - 1) * (AV_BURSTCOUNT_SYMBOLS ? 1 : (AV_SYMBOLS_PER_WORD)) );
   localparam AV_MAX_SYMBOL_BURST_MINUS_ONE = AV_MAX_SYMBOL_BURST ? AV_MAX_SYMBOL_BURST - 1 : 0 ;

   localparam UAV_BURSTCOUNT_W_OR_32 = UAV_BURSTCOUNT_W > 32 ? 31 : UAV_BURSTCOUNT_W -1;
   localparam UAV_ADDRESS_W_OR_32   = UAV_ADDRESS_W    > 32 ? 31 : UAV_ADDRESS_W -1;
   
   
   // -1 for burstcount restriction 2^(n-1)

   localparam BITS_PER_WORD_BURSTCOUNT = UAV_BURSTCOUNT_W == 1 ? 0 : BITS_PER_WORD;
   localparam BITS_PER_WORD_ADDRESS    = UAV_ADDRESS_W    == 1 ? 0 : BITS_PER_WORD;
   
   localparam ADDRESS_LOW     = AV_ADDRESS_SYMBOLS ? 0 : BITS_PER_WORD_ADDRESS;
   localparam BURSTCOUNT_LOW  = AV_BURSTCOUNT_SYMBOLS ? 0 : BITS_PER_WORD_BURSTCOUNT;
   
   localparam ADDRESS_HIGH    = UAV_ADDRESS_W >    AV_ADDRESS_W    + ADDRESS_LOW    ? AV_ADDRESS_W    : UAV_ADDRESS_W    - ADDRESS_LOW;
   localparam BURSTCOUNT_HIGH = UAV_BURSTCOUNT_W > AV_BURSTCOUNT_W + BURSTCOUNT_LOW ? AV_BURSTCOUNT_W : UAV_BURSTCOUNT_W - BURSTCOUNT_LOW;
   
   function integer flog2;
      input [31:0] Depth;
      integer 	   i;
      begin
         i = Depth;
	 if ( i <= 0 ) flog2 = 0;
	 else begin
            for(flog2 = -1; i > 0; flog2 = flog2 + 1)
              i = i >> 1;
	 end
      end    
      
   endfunction // flog2   

   function integer clog2;
      input [31:0] Depth;
      integer i;
      begin
         i = Depth;        
         for(clog2 = 0; i > 0; clog2 = clog2 + 1)
           i = i >> 1;
      end
 
   endfunction 
   
   function integer pow2;
      input [31:0] toShift;
      begin
	 pow2=1;
	 pow2= pow2 << toShift;
      end
   endfunction // pow2

   // -------------------------------------------------
   // Assign some constants to appropriately-sized signals to
   // avoid synthesis warnings. This also helps some simulators
   // with their inferred sensitivity lists.
   // -------------------------------------------------
   // Calculate the symbols per word as the power of 2 extended symbols per word
   wire [31:0] symbols_per_word_int = 2**(clog2(AV_SYMBOLS_PER_WORD[UAV_BURSTCOUNT_W_OR_32 : 0] - 1));
   wire [UAV_BURSTCOUNT_W_OR_32 : 0] symbols_per_word = symbols_per_word_int[UAV_BURSTCOUNT_W_OR_32 : 0];

   
   reg  	                         internal_beginbursttransfer;
   reg 		                         internal_begintransfer;
   reg [UAV_ADDRESS_W - 1: 0 ] 		 uav_address_pre;
   reg [UAV_BURSTCOUNT_W - 1 : 0 ]	 uav_burstcount_pre;
 		 
 		 
   
   reg uav_read_pre;
   reg uav_write_pre;
   reg read_accepted;   
    
   //Passthru assignmenst
   
   assign     uav_writedata       = av_writedata;
   assign     av_readdata         = uav_readdata;
   assign     uav_byteenable      = av_byteenable;
   assign     uav_lock            = av_lock;
   assign     av_readdatavalid    = uav_readdatavalid;
   assign     uav_debugaccess     = av_debugaccess;
   assign     uav_clken           = av_clken;
   
   //address + burstcount assignment

   reg [UAV_ADDRESS_W - 1 : 0] address_register;
   reg [UAV_BURSTCOUNT_W - 1 : 0] burstcount_register;

   always @* begin
      uav_address=uav_address_pre;
      uav_burstcount=uav_burstcount_pre;
      
      if(AV_CONSTANT_BURST_BEHAVIOR && !UAV_CONSTANT_BURST_BEHAVIOR && ~internal_beginbursttransfer) begin
	 uav_address=address_register;
	 uav_burstcount=burstcount_register;
      end
   end

   reg first_burst_stalled;
   reg burst_stalled;

     
   wire[UAV_ADDRESS_W-1:0] combi_burst_addr_reg;
   wire [UAV_ADDRESS_W-1:0] combi_addr_reg;
   generate
      if(AV_LINEWRAPBURSTS && AV_MAX_SYMBOL_BURST!=0) begin
         if(AV_MAX_SYMBOL_BURST > UAV_ADDRESS_W - 1) begin
            assign combi_burst_addr_reg = { uav_address_pre[UAV_ADDRESS_W-1:0] + AV_SYMBOLS_PER_WORD[UAV_ADDRESS_W-1:0] };
            assign combi_addr_reg = { address_register[UAV_ADDRESS_W-1:0] + AV_SYMBOLS_PER_WORD[UAV_ADDRESS_W-1:0] };
         end
         else begin
            assign combi_burst_addr_reg = { uav_address_pre[UAV_ADDRESS_W - 1 : AV_MAX_SYMBOL_BURST], uav_address_pre[AV_MAX_SYMBOL_BURST_MINUS_ONE:0] + AV_SYMBOLS_PER_WORD[AV_MAX_SYMBOL_BURST_MINUS_ONE:0] };
            assign combi_addr_reg = { address_register[UAV_ADDRESS_W - 1 : AV_MAX_SYMBOL_BURST], address_register[AV_MAX_SYMBOL_BURST_MINUS_ONE:0] + AV_SYMBOLS_PER_WORD[AV_MAX_SYMBOL_BURST_MINUS_ONE:0] };
         end
      end
      else begin
         assign combi_burst_addr_reg =
           uav_address_pre + AV_SYMBOLS_PER_WORD[UAV_ADDRESS_W_OR_32:0];
         assign combi_addr_reg =
           address_register + AV_SYMBOLS_PER_WORD[UAV_ADDRESS_W_OR_32:0];
      end
   endgenerate
   
   always@(posedge clk, posedge reset) begin
      
      if(reset) begin
	 address_register    <= '0;
	 burstcount_register <= '0;
	 first_burst_stalled <= 1'b0;
	 burst_stalled       <= 1'b0;
      end
      else begin
	 address_register    <= address_register;
	 burstcount_register <= burstcount_register;
	 
	 if(internal_beginbursttransfer||first_burst_stalled) begin

	    if(av_waitrequest) begin
	       first_burst_stalled <= 1'b1;
	       address_register    <= uav_address_pre;
	       burstcount_register <= uav_burstcount_pre;
	    end else begin
	       first_burst_stalled <= 1'b0;
	       address_register    <= combi_burst_addr_reg;
	       burstcount_register <= uav_burstcount_pre - symbols_per_word;
	    end
	 end
	 
	 else if(internal_begintransfer || burst_stalled) begin
	    if(~av_waitrequest) begin
	       burst_stalled       <= 1'b0;
	       address_register    <= combi_addr_reg;
	       burstcount_register <= burstcount_register - symbols_per_word;
	    end else
	      burst_stalled<=1'b1;   
	 end
      end
   
   end
	
   //Address
   always @* begin
      uav_address_pre = '0;
      
      if(AV_ADDRESS_SYMBOLS)
	 uav_address_pre=av_address[ ( ADDRESS_HIGH ? ADDRESS_HIGH - 1 : 0 ) : 0 ];
      else begin  
	    uav_address_pre[ UAV_ADDRESS_W - 1 : ADDRESS_LOW ] = av_address[( ADDRESS_HIGH ? ADDRESS_HIGH - 1 : 0) : 0 ];
      end
   end

   //Burstcount
   always@* begin
      uav_burstcount_pre = symbols_per_word;  // default to a single transfer
      
      if(USE_BURSTCOUNT) begin
	 uav_burstcount_pre = '0;
	 
	 if(AV_BURSTCOUNT_SYMBOLS)
	    uav_burstcount_pre = av_burstcount[( BURSTCOUNT_HIGH ? BURSTCOUNT_HIGH - 1 : 0 ) :0 ];
	 else begin
	    uav_burstcount_pre[ UAV_BURSTCOUNT_W - 1 : BURSTCOUNT_LOW] = av_burstcount[( BURSTCOUNT_HIGH ? BURSTCOUNT_HIGH - 1 : 0 ) : 0 ];
	 end
	 
      end
      
   end

   
   //waitrequest translation
   
   always@(posedge clk, posedge reset) begin
      if(reset)
	read_accepted  <= 1'b0;
      else begin
	 read_accepted <= read_accepted;
	 
	 if(read_accepted == 1 && uav_readdatavalid == 1)  // reset acceptance only when rdv arrives
	   read_accepted <= 1'b0;
	 
	 if(read_accepted == 0)
	   read_accepted<=av_waitrequest ? uav_read_pre & ~uav_waitrequest : 1'b0;
      end
      
   end
   
   reg write_accepted = 0;   
   generate if (AV_REGISTERINCOMINGSIGNALS) begin
      always@(posedge clk, posedge reset) begin
          if(reset)
            write_accepted <= 1'b0;
          else begin
            write_accepted <= 
              ~av_waitrequest ? 1'b0 : 
              uav_write & ~uav_waitrequest? 1'b1 :
              write_accepted;
          end
      end
   end endgenerate

   always@* begin
      av_waitrequest = uav_waitrequest;
      
      if(USE_READDATAVALID == 0 ) begin
	 av_waitrequest = uav_read_pre ? ~uav_readdatavalid : uav_waitrequest;
      end

      if (AV_REGISTERINCOMINGSIGNALS) begin
         av_waitrequest = 
            uav_read_pre  ? ~uav_readdatavalid : 
            uav_write_pre ? (internal_begintransfer | uav_waitrequest) & ~write_accepted :
            1'b1;
      end

      if(USE_WAITREQUEST == 0) begin
         av_waitrequest = 0;
      end
   end

   //read/write generation
   always@* begin
      
      uav_write           =  1'b0;
      uav_write_pre       =  1'b0;
      uav_read            =  1'b0;
      uav_read_pre        =  1'b0;

      if(!USE_CHIPSELECT) begin
	 if (USE_READ) begin
	    uav_read_pre=av_read;
	 end
      
	 if (USE_WRITE) begin
	    uav_write_pre=av_write;
	 end
      end
      else begin
	 if(!USE_WRITE && USE_READ) begin
	    uav_read_pre=av_read;
	    uav_write_pre=av_chipselect & ~av_read;
	 end
	 else if(!USE_READ && USE_WRITE) begin
	    uav_write_pre=av_write;
	    uav_read_pre = av_chipselect & ~av_write;
	 end
	 else if (USE_READ && USE_WRITE) begin
	    uav_write_pre=av_write;
	    uav_read_pre=av_read;
	 end
      end
      
      if(USE_READDATAVALID == 0)
	uav_read = uav_read_pre & ~read_accepted;
      else
        uav_read = uav_read_pre;
      
      if(AV_REGISTERINCOMINGSIGNALS == 0)
        uav_write=uav_write_pre;
      else
        uav_write=uav_write_pre & ~write_accepted;

      
   end

   // -------------------
   // Begintransfer Assigment
   // -------------------
    		   
   reg       end_begintransfer;
   
   always@* begin
      if(USE_BEGINTRANSFER) begin
	 internal_begintransfer = av_begintransfer;
      end else begin
	 internal_begintransfer = ( uav_write | uav_read ) & ~end_begintransfer;
      end
   end
   
   always@ ( posedge clk or posedge reset ) begin
      
      if(reset) begin
	 end_begintransfer <= 1'b0;
      end 
      else begin
	 
	 if(internal_begintransfer == 1 && uav_waitrequest)
	   end_begintransfer <= 1'b1;
	 else if(uav_waitrequest) 
	   end_begintransfer <= end_begintransfer;
	 else 
	   end_begintransfer <= 1'b0;
	 
      end
      
   end
   
   // -------------------
   // Beginbursttransfer Assigment
   // -------------------
   
   reg 							   end_beginbursttransfer;
   wire                                                    last_burst_transfer_pre;
   wire                                                    last_burst_transfer_reg;
   wire                                                    last_burst_transfer;

   // compare values before the mux to shorten critical path; benchmark before changing
   assign last_burst_transfer_pre = (uav_burstcount_pre == symbols_per_word);
   assign last_burst_transfer_reg = (burstcount_register == symbols_per_word);
   assign last_burst_transfer     = (internal_beginbursttransfer) ? last_burst_transfer_pre : last_burst_transfer_reg;     
      
   always@* begin
      if(USE_BEGINBURSTTRANSFER) begin
	 internal_beginbursttransfer = av_beginbursttransfer;
      end else begin
	 internal_beginbursttransfer = uav_read ? internal_begintransfer : internal_begintransfer && ~end_beginbursttransfer;
      end
   end
   
   always@ ( posedge clk or posedge reset ) begin
      
      if(reset) begin
	 end_beginbursttransfer <= 1'b0;
      end
      else begin
	 end_beginbursttransfer <= end_beginbursttransfer;
	 if( last_burst_transfer && internal_begintransfer || uav_read ) begin
	    end_beginbursttransfer <= 1'b0;
	 end
	 else if(uav_write && internal_begintransfer) begin
	    end_beginbursttransfer <= 1'b1;
	 end
      end
      
   end	
	     
 endmodule
