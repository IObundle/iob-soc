// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// DESCRIPTION
//
// This is a single clock version of dcfifo_mlab. It is suitable for replacing smaller instances of LPM SCFIFO.
// The maximum depth is 31. The implementation follows dcfifo_mlab very closely, with the cross
// domain hardening removed.
//
// Where possible connect the "used words" outputs to create partial full and empty signals. These can be
// pipelined and facilitate easy timing closure better than the full and empty which have tighter functional
// requirements.
//
//
//
// Where possible set these parameters to 0 to improve read and write request speed.
//
//  parameter PREVENT_OVERFLOW = 1'b1, // ignore requests that would cause overflow
//
//  parameter PREVENT_UNDERFLOW = 1'b1, // ignore requests that would cause underflow
//
// With prevention disabled the FIFO will wrap during an underflow or overflow, and then resume
// coherent operation from that illegally entered state.
//
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on




// CONFIDENCE
// This has been used successfully in multiple Altera wireline projects
//

module altpcie_sv_gbfifo #(
        parameter TARGET_CHIP = 2, // 1 S4, 2 S5,
        parameter SIM_EMULATE = 1'b0,  // simulation equivalent, only for S5 right now
        parameter WIDTH = 80, // typical 20,40,60,80
        parameter PREVENT_OVERFLOW = 1'b1,      // ignore requests that would cause overflow
        parameter PREVENT_UNDERFLOW = 1'b1,     // ignore requests that would cause underflow
        parameter RAM_GROUPS = (WIDTH < 20) ? 1 : (WIDTH / 20), // min 1, WIDTH must be divisible by RAM_GROUPS
        parameter GROUP_RADDR = (WIDTH < 20) ? 1'b0 : 1'b1,  // 1 to duplicate RADDR per group as well as WADDR
        parameter FLAG_DUPES = 1, // if > 1 replicate full / empty flags for fanout balancing
        parameter ADDR_WIDTH = 5, // 4 or 5
        parameter DISABLE_USED = 1'b0
)(
        input clk,
        input sclr,

        input [WIDTH-1:0] wdata,
        input wreq,
        output [FLAG_DUPES-1:0] full,   // optional duplicates for loading

        output [WIDTH-1:0] rdata,
        input rreq,
        output [FLAG_DUPES-1:0] empty,  // optional duplicates for loading

        output [ADDR_WIDTH-1:0] used
);

// synthesis translate off
initial begin
        if (WIDTH > 20 && (RAM_GROUPS * 20 != WIDTH)) begin
                $display ("Error in scfifo_mlab parameters - the physical width is a multiple of 20, this needs to match");
                $stop();
        end
end
// synthesis translate on


////////////////////////////////////
// rereg sclr
////////////////////////////////////

reg sclr_int = 1'b1 /* synthesis preserve */;
always @(posedge clk) begin
        sclr_int <= sclr;
end

////////////////////////////////////
// addr pointers
////////////////////////////////////

wire winc;
wire rinc;

wire [RAM_GROUPS*ADDR_WIDTH-1:0] rptr;
reg [ADDR_WIDTH-1:0] wcntr = {ADDR_WIDTH{1'b0}} /* synthesis preserve */;
reg [ADDR_WIDTH-1:0] rcntr = {ADDR_WIDTH{1'b0}} /* synthesis preserve */;

always @(posedge clk) begin
        if (sclr_int) wcntr <= {ADDR_WIDTH{1'b0}} | 1'b1;
        else if (winc) wcntr <= wcntr + 1'b1;

        if (sclr_int) rcntr <= {ADDR_WIDTH{1'b0}} | (GROUP_RADDR ? 2'd2 : 2'd1);
        else if (rinc) rcntr <= rcntr + 1'b1;
end

// optional duplication of the read address
generate
        if (GROUP_RADDR) begin : gr
                reg [RAM_GROUPS*ADDR_WIDTH-1:0] rptr_r = {RAM_GROUPS{{ADDR_WIDTH{1'b0}} | 1'b1}}
                        /* synthesis preserve */;
                always @(posedge clk) begin
                        if (sclr_int) rptr_r <= {RAM_GROUPS{{ADDR_WIDTH{1'b0}} | 1'b1}} ;
                        else if (rinc) rptr_r <= {RAM_GROUPS{rcntr}};
                end
                assign rptr = rptr_r;
        end
        else begin : ngr
                assign rptr = {RAM_GROUPS{rcntr}};
        end
endgenerate

//////////////////////////////////////////////////
// adjust pointers for RAM latency
//////////////////////////////////////////////////

reg [ADDR_WIDTH-1:0] rptr_completed = {ADDR_WIDTH{1'b0}};

always @(posedge clk) begin
        if (sclr_int) begin
                rptr_completed <= {ADDR_WIDTH{1'b0}};
        end
        else begin
                if (rinc) rptr_completed <= rptr[ADDR_WIDTH-1:0];
        end
end

reg [ADDR_WIDTH-1:0] wptr_d = {ADDR_WIDTH{1'b0}};
reg [ADDR_WIDTH-1:0] wptr_completed = {ADDR_WIDTH{1'b0}};

wire [ADDR_WIDTH-1:0] wptr_d_w = winc ? wcntr : wptr_d /* synthesis keep */;

always @(posedge clk) begin
        if (sclr_int) begin
                wptr_d <= {ADDR_WIDTH{1'b0}};
                wptr_completed <= {ADDR_WIDTH{1'b0}};
        end
        else begin
                wptr_d <= wptr_d_w;
                wptr_completed <= wptr_d;
        end
end

//////////////////////////////////////////////////
// compare pointers
//////////////////////////////////////////////////

genvar i;
generate
        for (i=0; i<FLAG_DUPES; i=i+1) begin : fg

                //assign full[i] = ~|(rptr_completed ^ wcntr);
                //assign empty[i] = ~|(rptr_completed ^ wptr_completed);

                altpcie_sv_gbfifo_eq_5_ena eq0 (
                        .da(5'h0 | rptr_completed),
                        .db(5'h0 | wcntr),
                        .ena(1'b1),
                        .eq(full[i])
                );
                defparam eq0 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5

                altpcie_sv_gbfifo_eq_5_ena eq1 (
                        .da(5'h0 | rptr_completed),
                        .db(5'h0 | wptr_completed),
                        .ena(1'b1),
                        .eq(empty[i])
                );
                defparam eq1 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5

        end
endgenerate

//////////////////////////////////////////////////
// storage array - split in addr reg groups
//////////////////////////////////////////////////

reg [ADDR_WIDTH*RAM_GROUPS-1:0] waddr_reg = {(RAM_GROUPS*ADDR_WIDTH){1'b0}} /* synthesis preserve */;
reg [WIDTH-1:0] wdata_reg = {WIDTH{1'b0}} /* synthesis preserve */;
wire [WIDTH-1:0] ram_q;
reg [WIDTH-1:0] rdata_reg = {WIDTH{1'b0}};

wire [ADDR_WIDTH-1:0] wptr_inv = wcntr ^ 1'b1;
always @(posedge clk) begin
        waddr_reg <= {RAM_GROUPS{wptr_inv}};
        wdata_reg <= wdata;
end

generate
        for (i=0; i<RAM_GROUPS;i=i+1) begin : sm
                if (TARGET_CHIP == 1) begin : tc1
                        alt_s4mlab sm0 (
                                .wclk(clk),
                                .wena(1'b1),
                                .waddr_reg(waddr_reg[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH]),
                                .wdata_reg(wdata_reg[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)]),
                                .raddr(rptr[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH] ^ 1'b1),
                                .rdata(ram_q[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)])
                        );
                        defparam sm0 .WIDTH = WIDTH / RAM_GROUPS;
                        defparam sm0 .ADDR_WIDTH = ADDR_WIDTH;
                end
                else if (TARGET_CHIP == 2 || TARGET_CHIP == 0) begin : tc2
                        altpcie_sv_gbfifo_s5mlab sm0 (
                                .wclk(clk),
                                .wena(1'b1),
                                .waddr_reg(waddr_reg[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH]),
                                .wdata_reg(wdata_reg[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)]),
                                .raddr(rptr[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH] ^ 1'b1),
                                .rdata(ram_q[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)])
                        );
                        defparam sm0 .WIDTH = WIDTH / RAM_GROUPS;
                        defparam sm0 .ADDR_WIDTH = ADDR_WIDTH;
                        defparam sm0 .SIM_EMULATE = SIM_EMULATE;
                end
                else if (TARGET_CHIP == 5) begin : tc5
                        alt_a10mlab sm0 (
                                .wclk(clk),
                                .wena(1'b1),
                                .waddr_reg(waddr_reg[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH]),
                                .wdata_reg(wdata_reg[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)]),
                                .raddr(rptr[((i+1)*ADDR_WIDTH)-1:i*ADDR_WIDTH] ^ 1'b1),
                                .rdata(ram_q[(i+1)*(WIDTH/RAM_GROUPS)-1:i*(WIDTH/RAM_GROUPS)])
                        );
                        defparam sm0 .WIDTH = WIDTH / RAM_GROUPS;
                        defparam sm0 .ADDR_WIDTH = ADDR_WIDTH;
                        defparam sm0 .SIM_EMULATE = SIM_EMULATE;
                end
                else begin : tc66
                        // synthesis translate off
                        initial begin
                                $display ("Error - Unsure how to make mlab cells for this target chip");
                                $stop();
                        end
                        // synthesis translate on
                end
        end
endgenerate

// output reg - don't defeat clock enable (?) Works really well on S5
wire [WIDTH-1:0] rdata_mx = rinc ? ram_q: rdata_reg ;
always @(posedge clk) begin
        rdata_reg <= rdata_mx;
end
assign rdata = rdata_reg;

//////////////////////////////////////////////////
// used words
//////////////////////////////////////////////////

generate
        if (DISABLE_USED) begin : nwu
                assign used = {ADDR_WIDTH{1'b0}};
        end
        else begin : wu
                reg [ADDR_WIDTH-1:0] used_r = {ADDR_WIDTH{1'b0}} /* synthesis preserve */;
                always @(posedge clk) begin
                        used_r <= wptr_completed - rptr_completed;
                end
                assign used = used_r;
        end
endgenerate

////////////////////////////////////
// qualified requests
////////////////////////////////////

//wire winc = wreq & (~full[0] | ~PREVENT_OVERFLOW);
//wire rinc = rreq & (~empty[0] | ~PREVENT_UNDERFLOW);

generate
        if (PREVENT_OVERFLOW) begin
                altpcie_sv_gbfifo_neq_5_ena eq2 (
                        .da(5'h0 | rptr_completed),
                        .db(5'h0 | wcntr),
                        .ena(wreq),
                        .eq(winc)
                );
                defparam eq2 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5
        end
        else assign winc = wreq;
endgenerate

generate
        if (PREVENT_UNDERFLOW) begin
                altpcie_sv_gbfifo_neq_5_ena eq3 (
                        .da(5'h0 | rptr_completed),
                        .db(5'h0 | wptr_completed),
                        .ena(rreq),
                        .eq(rinc)
                );
                defparam eq3 .TARGET_CHIP = TARGET_CHIP;   // 0 generic, 1 S4, 2 S5
        end
        else assign rinc = rreq;
endgenerate

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_scfifo_mlab.v
// BENCHMARK INFO :  Uses helper file :  altpcie_sv_gbfifo_eq_5_ena.v
// BENCHMARK INFO :  Uses helper file :  altpcie_sv_gbfifo_wys_lut.v
// BENCHMARK INFO :  Uses helper file :  altpcie_sv_gbfifo_s5mlab.v
// BENCHMARK INFO :  Uses helper file :  altpcie_sv_gbfifo_neq_5_ena.v
// BENCHMARK INFO :  Max depth :  3.0 LUTs
// BENCHMARK INFO :  Total registers : 231
// BENCHMARK INFO :  Total pins : 171
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  38
// BENCHMARK INFO :  ALMs : 93 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.393 ns, From gr.rptr_r[19], To rdata_reg[73]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.101 ns, From rptr_completed[1], To altpcie_sv_gbfifo_s5mlab:sm[1].tc2.sm0|ml[0].lrm~ENA1REGOUT}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.453 ns, From rptr_completed[2], To rcntr[0]}
//
//
//
// baeckler - 01-25-2012
// force the decomposition of 5 bit FIFO pointer compare with enable

// DESCRIPTION
//
// This is a pipelined comparator for din_a != din_b with an enable AND gate at the output.
//


module altpcie_sv_gbfifo_neq_5_ena #(
        parameter TARGET_CHIP = 2   // 0 generic, 1 S4, 2 S5
)(
        input [4:0] da,
        input [4:0] db,
        input ena,
        output eq
);

wire w0_o;
altpcie_sv_gbfifo_wys_lut w0 (
        .a(da[0]),
        .b(da[1]),
        .c(da[2]),
        .d(db[0]),
        .e(db[1]),
        .f(db[2]),
        .out (w0_o)
);
defparam w0 .TARGET_CHIP = TARGET_CHIP;
defparam w0 .MASK = 64'h8040201008040201; // {a,b,c} == {d,e,f}

altpcie_sv_gbfifo_wys_lut w1 (
        .a(ena),
        .b(da[3]),
        .c(da[4]),
        .d(db[3]),
        .e(db[4]),
        .f(w0_o),
        .out (eq)
);
defparam w1 .TARGET_CHIP = TARGET_CHIP;
defparam w1 .MASK = 64'h2a8aa2a8aaaaaaaa; // (!({b,c} == {d,e}) || !f) && a;


endmodule

// baeckler - 01-16-2012

// DESCRIPTION
//
// This is a low level instantiation of the Stratix 5 MLAB. Note that the inputs with _reg in the name need to
// be directly driven by registers to pass legality checking.
//



// CONFIDENCE
// This is a key low level wrapper used in many places
//

module altpcie_sv_gbfifo_s5mlab #(
        parameter WIDTH = 20,
        parameter ADDR_WIDTH = 5,
        parameter SIM_EMULATE = 1'b0   // this may not be exactly the same at the fine grain timing level
)
(
        input wclk,
        input wena,
        input [ADDR_WIDTH-1:0] waddr_reg,
        input [WIDTH-1:0] wdata_reg,
        input [ADDR_WIDTH-1:0] raddr,
        output [WIDTH-1:0] rdata
);

localparam NUM_WORDS = (1 << ADDR_WIDTH);
genvar i;
generate
        if (!SIM_EMULATE) begin
                /////////////////////////////////////////////
                // hardware cells

                for (i=0; i<WIDTH; i=i+1)  begin : ml
                        wire wclk_w = wclk;  // workaround strange modelsim warning due to cell model tristate
                        stratixv_mlab_cell lrm (
                                .clk0(wclk_w),
                                .ena0(wena),

                                // synthesis translate off
                                .clk1(1'b0),
                                .ena1(1'b1),
                                .ena2(1'b1),
                                .clr(1'b0),
                                .devclrn(1'b1),
                                .devpor(1'b1),
                                // synthesis translate on

                                .portabyteenamasks(1'b1),
                                .portadatain(wdata_reg[i]),
                                .portaaddr(waddr_reg),
                                .portbaddr(raddr),
                                .portbdataout(rdata[i])

                        );

                        defparam lrm .mixed_port_feed_through_mode = "dont_care";
                        defparam lrm .logical_ram_name = "lrm";
                        defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
                        defparam lrm .logical_ram_width = WIDTH;
                        defparam lrm .first_address = 0;
                        defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
                        defparam lrm .first_bit_number = i;
                        defparam lrm .data_width = 1;
                        defparam lrm .address_width = ADDR_WIDTH;
                end
        end
        else begin
                /////////////////////////////////////////////
                // sim equivalent

                reg [WIDTH-1:0] storage [0:NUM_WORDS-1];
                integer k = 0;
                initial begin
                        for (k=0; k<NUM_WORDS; k=k+1) begin
                                storage[k] = 0;
                        end
                end

                always @(posedge wclk) begin
                        if (wena) storage [waddr_reg] <= wdata_reg;
                end

                reg [WIDTH-1:0] rdata_b = 0;
                always @(*) begin
                        rdata_b = storage[raddr];
                end

                assign rdata = rdata_b;
        end

endgenerate

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  altpcie_sv_gbfifo_s5mlab.v
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Total registers : 0
// BENCHMARK INFO :  Total pins : 52
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  1
// BENCHMARK INFO :  ALMs : 11 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From wclk~inputCLKENA0FMAX_CAP_FF0, To wclk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From wclk~inputCLKENA0FMAX_CAP_FF0, To wclk~inputCLKENA0FMAX_CAP_FF1}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 2.063 ns, From wclk~inputCLKENA0FMAX_CAP_FF0, To wclk~inputCLKENA0FMAX_CAP_FF1}

// baeckler - 01-25-2012
// force the decomposition of 5 bit FIFO pointer compare with enable

// DESCRIPTION
//
// This is a WYSIWYG cell implementation of equality comparison of two 5 bit busses with an enable signal.
//



// CONFIDENCE
// This is a small equality circuit.  Any problems should be easily spotted in simulation.
//

module altpcie_sv_gbfifo_eq_5_ena #(
        parameter TARGET_CHIP = 2   // 0 generic, 1 S4, 2 S5
)(
        input [4:0] da,
        input [4:0] db,
        input ena,
        output eq
);

wire w0_o;
altpcie_sv_gbfifo_wys_lut w0 (
        .a(da[0]),
        .b(da[1]),
        .c(da[2]),
        .d(db[0]),
        .e(db[1]),
        .f(db[2]),
        .out (w0_o)
);
defparam w0 .TARGET_CHIP = TARGET_CHIP;
defparam w0 .MASK = 64'h8040201008040201; // {a,b,c} == {d,e,f}

altpcie_sv_gbfifo_wys_lut w1 (
        .a(ena),
        .b(da[3]),
        .c(da[4]),
        .d(db[3]),
        .e(db[4]),
        .f(w0_o),
        .out (eq)
);
defparam w1 .TARGET_CHIP = TARGET_CHIP;
defparam w1 .MASK = 64'h8020080200000000; // ({b,c} == {d,e}) && a && f


endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  altpcie_sv_gbfifo_eq_5_ena.v
// BENCHMARK INFO :  Uses helper file :  altpcie_sv_gbfifo_wys_lut.v
// BENCHMARK INFO :  Max depth :  2.0 LUTs
// BENCHMARK INFO :  Total registers : 0
// BENCHMARK INFO :  Total pins : 12
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  3
// BENCHMARK INFO :  ALMs : 3 / 234,720 ( < 1 % )

// DESCRIPTION
//
//
// This is a multiple chip family WYSIWYG LUT. WYSIWYG cells are cumbersome, but the only way to
// guarantee that complex LUT decompositions are implemented exactly as desired. It has a generic mode
// for comparing against a simple truth table implementation.
//



// CONFIDENCE
// This component is simple, and used absolutely everywhere.
//

module altpcie_sv_gbfifo_wys_lut #(
        parameter MASK = 64'h6996966996696996, // xor6
        parameter TARGET_CHIP = 2 // 0 generic, 1=S4, 2=S5, 3=A5, 4=C5, 5=A10
)
(
        input a,b,c,d,e,f,
        output out
);

// Handy masks -
// 64'h8040201008040201 {a,b,c} == {d,e,f}
// 64'h6996966996696996 xor 6
// 64'h8020080200000000 ({b,c} == {d,e}) && a && f

generate
        if (TARGET_CHIP == 0) begin : c0
                // family neutral / simulation version
                wire [5:0] addr = {f,e,d,c,b,a};
                wire [63:0] tmp = MASK >> addr;
                assign out = tmp[0];
        end
        else if (TARGET_CHIP == 1) begin : c1
                stratixiv_lcell_comb s4c (
                  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
                  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
                  .combout(out));
                defparam s4c .lut_mask = MASK;
                defparam s4c .shared_arith = "off";
                defparam s4c .extended_lut = "off";

        end
        else if (TARGET_CHIP == 2) begin : c2
                stratixv_lcell_comb s5c (
                  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
                  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
                  .combout(out));
                defparam s5c .lut_mask = MASK;
                defparam s5c .shared_arith = "off";
                defparam s5c .extended_lut = "off";
        end
        else if (TARGET_CHIP == 3) begin : c3
                arriav_lcell_comb a5c (
                  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
                  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
                  .combout(out));
                defparam a5c .lut_mask = MASK;
                defparam a5c .shared_arith = "off";
                defparam a5c .extended_lut = "off";
        end
        else if (TARGET_CHIP == 4) begin : c4
                cyclonev_lcell_comb c5c (
                  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
                  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
                  .combout(out));
                defparam c5c .lut_mask = MASK;
                defparam c5c .shared_arith = "off";
                defparam c5c .extended_lut = "off";
        end
        else if (TARGET_CHIP == 5) begin : a10
                twentynm_lcell_comb a10c (
                  .dataa (a),.datab (b),.datac (c),.datad (d),.datae (e),.dataf (f),.datag(1'b1),
                  .cin(1'b1),.sharein(1'b0),.sumout(),.cout(),.shareout(),
                  .combout(out));
                defparam a10c .lut_mask = MASK;
                defparam a10c .shared_arith = "off";
                defparam a10c .extended_lut = "off";
        end
        else begin
                // synthesis translate off
                initial begin
                        $display ("ERROR: Illegal TARGET_CHIP");
                        $stop();
                end
                // synthesis translate on
                assign out = 1'b0;
        end
endgenerate


endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  altpcie_sv_gbfifo_wys_lut.v
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 0
// BENCHMARK INFO :  Total pins : 7
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  2
// BENCHMARK INFO :  ALMs : 2 / 234,720 ( < 1 % )
