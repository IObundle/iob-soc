`timescale 1 ns / 1 ps

`include "iob_utils.vh"
`include "iob_soc_boot_conf.vh"
`include "iob_soc_boot_swreg_def.vh"
`include "iob_soc_conf.vh"

module iob_soc_boot #(
        `include "iob_soc_boot_params.vs"
    ) (
        input [ `REQ_W-1:0] boot_ctr_i_req_i,
        
        output [`RESP_W-1:0] boot_ctr_i_resp_o,
        output CTR_o,

        `include "iob_soc_boot_io.vs"
    );

    `include "iob_soc_boot_swreg_inst.vs"

    assign CTR_o = CTR;

    //
    //INSTANTIATE BOOT ROM
    //
    /*iob_rom_sp #(
        .DATA_W(DATA_W),
        .ADDR_W(10),
        .HEXFILE("iob_soc_preboot.hex") //todo iob_soc_rom.hex
    ) boot_rom (
        .clk_i(clk_i),

        //instruction memory interface
        .r_en_i(ROM_ren),
        .addr_i(iob_addr_i >> 2),
        .r_data_o(ROM)
    );*/
    iob_rom_dp #(
        .DATA_W(DATA_W),
        .ADDR_W(10),
        .HEXFILE("iob_soc_preboot.hex") //todo iob_soc_rom.hex
    ) boot_rom (
        .clk_i(clk_i),

        // instruction memory interface
        .r_en_a_i(boot_ctr_i_req_i[`AVALID(0)]),
        .addr_a_i(boot_ctr_i_req_i[`ADDRESS(0)]),
        .r_data_a_o(boot_ctr_i_resp_o[`RDATA(0)]),

        // data memory interface
        .r_en_b_i(ROM_ren),
        .addr_b_i(iob_addr_i >> 2),
        .r_data_b_o(ROM)
    );
    assign ROM_ready = 1'b1;

    iob_reg #(
        .DATA_W (1),
        .RST_VAL(1'd0)
    ) ROM_valid_reg (
        .clk_i (clk_i),
        .cke_i (boot_ctr_i_req_i[`AVALID(0)] == 0),
        .arst_i(arst_i),
        .data_i(iob_avalid_i),
        .data_o(ROM_rvalid)
    );

    iob_reg #(
        .DATA_W (1),
        .RST_VAL(1'd0)
    ) CPU_rvalid_reg (
        .clk_i (clk_i),
        .cke_i (boot_ctr_i_req_i[`AVALID(0)] != 0),
        .arst_i(arst_i),
        .data_i(iob_avalid_i),
        .data_o(boot_ctr_i_resp_o[`RVALID(0)])
    );







    //assign ROM_rvalid = iob_avalid_i & (iob_addr_i == `IOB_SOC_BOOTROM_ADDR) & ~(|iob_wstrb_i);
    /*reg ROM_rvalid_int;
    assign ROM_rvalid = ROM_rvalid_int;
    reg [3-1:0] counter;
    always @(posedge clk_i) begin
        if (iob_avalid_i == 1) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
        if (counter == 5) begin
            ROM_rvalid_int <= 1'b1;
            counter <= 0;
        end else begin
            ROM_rvalid_int <= 1'b0;
        end
    end*/

    



   
    /*//cpu interface: rdata, rvalid and ready
    assign iob_rdata_o = {{(DATA_W-1){1'b0}},boot_o};
    iob_reg #(
        1,
        0
    ) rvalid_reg (
        clk_i,
        arst_i,
        cke_i,
        iob_avalid_i & ~(|iob_wstrb_i),
        iob_rvalid_o
    );
    assign iob_ready_o = 1'b1;
        
    //boot control register: {cpu_reset, boot, preboot}
    wire                       bootctr_wr = iob_avalid_i & (iob_addr_i == `IOB_SOC_BOOT_CTR_ADDR) |iob_wstrb_i; 
    iob_reg_e #(
        2,
        1
    ) bootnxt (
        clk_i,
        arst_i,
        cke_i,
        boot_wr,
        iob_wdata_i[1:0],
        CTR
    );



    //create CPU reset pulse
    wire                       cpu_rst_req;
    assign cpu_rst_req = iob_avalid_i & (|iob_wstrb_i) & iob_wdata_i[2];
    
    iob_pulse_gen #(
        .START(0),
        .DURATION(100)
        ) 
    reset_pulse
      (
       .clk_i(clk_i),
       .arst_i(arst_i),
       .cke_i(cke_i),
       .start_i(cpu_rst_req),
       .pulse_o(cpu_rst_o)
       );
 
 
    //
    //INSTANTIATE ROM
    //
    iob_rom_dp #(
        .DATA_W(DATA_W),
        .ADDR_W(`IOB_SOC_BOOTROM_ADDR_W-1),
        .HEXFILE("iob_soc_boot.hex") //todo iob_soc_rom.hex
        )
    sp_rom0 
      (
       .clk_i(clk_i),
 
       //instruction memory interface
       .r_en_a_i(ibus_avalid_i),
       .addr_a_i(ibus_addr_i),
       .r_data_a_o(ibus_rdata_o),
 
       //data memory interface
       .r_en_b_i(dbus_avalid_i),
       .addr_b_i(iob_addr_i)
       .r_data_b_o(iob_rdata_o) //fixme
       
       );*/

endmodule
