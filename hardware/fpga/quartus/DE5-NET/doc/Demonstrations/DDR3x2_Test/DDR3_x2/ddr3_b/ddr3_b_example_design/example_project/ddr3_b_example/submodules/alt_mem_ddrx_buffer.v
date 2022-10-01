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



`timescale 1 ps / 1 ps

(* message_disable = "14320" *) module alt_mem_ddrx_buffer
# (
    // module parameter port list
    parameter
        ADDR_WIDTH      =   3,
        DATA_WIDTH      =   8,
        REGISTER_OUTPUT =   0
)
(
    // port list
    ctl_clk,
    ctl_reset_n,

    // write interface
    write_valid,
    write_address,
    write_data,

    // read interface
    read_valid,
    read_address,
    read_data
);

    // -----------------------------
    // local parameter declaration
    // -----------------------------

    localparam  BUFFER_DEPTH            =  two_pow_N(ADDR_WIDTH);
    localparam  BUFFER_REGISTER_OUTPUT  = (REGISTER_OUTPUT) ? "CLOCK0" : "UNREGISTERED";

    // -----------------------------
    // port declaration
    // -----------------------------

    input                           ctl_clk;
    input                           ctl_reset_n;
    
    // write interface
    input                           write_valid;
    input   [ADDR_WIDTH-1:0]        write_address;
    input   [DATA_WIDTH-1:0]        write_data;

    // read interface
    input                           read_valid;
    input   [ADDR_WIDTH-1:0]        read_address;
    output  [DATA_WIDTH-1:0]        read_data;


    // -----------------------------
    // port type declaration
    // -----------------------------

    wire                            ctl_clk;
    wire                            ctl_reset_n;
                                                   
    // write interface                             
    wire                            write_valid;
    wire    [ADDR_WIDTH-1:0]        write_address;
    wire    [DATA_WIDTH-1:0]        write_data;
                                                   
    // read interface                              
    wire                            read_valid;
    wire    [ADDR_WIDTH-1:0]        read_address;
    wire    [DATA_WIDTH-1:0]        read_data;

    // -----------------------------
    // module definition
    // -----------------------------

	altsyncram	altsyncram_component 
    (
				.wren_a (write_valid),
				.clock0 (ctl_clk),
				.address_a (write_address),
				.address_b (read_address),
				.data_a (write_data),
				.q_b (read_data),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b ({DATA_WIDTH{1'b1}}),
				.eccstatus (),
				.q_a (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0)
    );
	defparam
		altsyncram_component.address_aclr_a = "NONE",
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.indata_aclr_a = "NONE",
		altsyncram_component.intended_device_family = "Stratix",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = BUFFER_DEPTH,
		altsyncram_component.numwords_b = BUFFER_DEPTH,
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = BUFFER_REGISTER_OUTPUT,
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = ADDR_WIDTH,
		altsyncram_component.widthad_b = ADDR_WIDTH,
		altsyncram_component.width_a = DATA_WIDTH,
		altsyncram_component.width_b = DATA_WIDTH,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.wrcontrol_aclr_a = "NONE";


    // alt_ddrx_ram_2port 
    // ram_inst
    // (
    //     .clock      (ctl_clk),
    //     .wren       (write_valid),
    //     .wraddress  (write_address),
    //     .data       (write_data),
    //     .rdaddress  (read_address),
    //     .q          (read_data)
    // );


    function integer two_pow_N;
        input integer value;
    begin
        two_pow_N = 2 << (value-1);
    end
    endfunction


endmodule
