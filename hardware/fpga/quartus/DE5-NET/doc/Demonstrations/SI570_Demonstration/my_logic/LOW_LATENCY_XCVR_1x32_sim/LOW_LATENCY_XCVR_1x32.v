// LOW_LATENCY_XCVR_1x32.v

// Generated using ACDS version 16.1 203

`timescale 1 ps / 1 ps
module LOW_LATENCY_XCVR_1x32 (
		input  wire         phy_mgmt_clk,         //       phy_mgmt_clk.clk
		input  wire         phy_mgmt_clk_reset,   // phy_mgmt_clk_reset.reset
		input  wire [8:0]   phy_mgmt_address,     //           phy_mgmt.address
		input  wire         phy_mgmt_read,        //                   .read
		output wire [31:0]  phy_mgmt_readdata,    //                   .readdata
		output wire         phy_mgmt_waitrequest, //                   .waitrequest
		input  wire         phy_mgmt_write,       //                   .write
		input  wire [31:0]  phy_mgmt_writedata,   //                   .writedata
		output wire         tx_ready,             //           tx_ready.export
		output wire         rx_ready,             //           rx_ready.export
		input  wire [0:0]   pll_ref_clk,          //        pll_ref_clk.clk
		output wire [0:0]   pll_locked,           //         pll_locked.export
		output wire [0:0]   tx_serial_data,       //     tx_serial_data.export
		input  wire [0:0]   rx_serial_data,       //     rx_serial_data.export
		output wire [0:0]   rx_is_lockedtoref,    //  rx_is_lockedtoref.export
		output wire [0:0]   rx_is_lockedtodata,   // rx_is_lockedtodata.export
		output wire [0:0]   tx_clkout,            //          tx_clkout.export
		output wire [0:0]   rx_clkout,            //          rx_clkout.export
		input  wire [31:0]  tx_parallel_data,     //   tx_parallel_data.export
		output wire [31:0]  rx_parallel_data,     //   rx_parallel_data.export
		output wire [91:0]  reconfig_from_xcvr,   // reconfig_from_xcvr.reconfig_from_xcvr
		input  wire [139:0] reconfig_to_xcvr      //   reconfig_to_xcvr.reconfig_to_xcvr
	);

	altera_xcvr_low_latency_phy #(
		.device_family               ("Stratix V"),
		.intended_device_variant     ("ANY"),
		.data_path_type              ("10G"),
		.operation_mode              ("DUPLEX"),
		.lanes                       (1),
		.bonded_mode                 ("xN"),
		.serialization_factor        (32),
		.pma_width                   (32),
		.data_rate                   ("10312.5 Mbps"),
		.base_data_rate              ("10312.5 Mbps"),
		.pll_refclk_freq             ("644.53125 MHz"),
		.bonded_group_size           (1),
		.select_10g_pcs              (1),
		.tx_use_coreclk              (0),
		.rx_use_coreclk              (0),
		.tx_bitslip_enable           (0),
		.tx_bitslip_width            (7),
		.rx_bitslip_enable           (0),
		.ppm_det_threshold           ("100"),
		.phase_comp_fifo_mode        ("NONE"),
		.loopback_mode               ("NONE"),
		.gxb_analog_power            ("AUTO"),
		.pll_lock_speed              ("AUTO"),
		.tx_analog_power             ("AUTO"),
		.tx_slew_rate                ("OFF"),
		.tx_termination              ("OCT_100_OHMS"),
		.tx_use_external_termination ("false"),
		.tx_preemp_pretap            (0),
		.tx_preemp_pretap_inv        ("false"),
		.tx_preemp_tap_1             (0),
		.tx_preemp_tap_2             (0),
		.tx_preemp_tap_2_inv         ("false"),
		.tx_vod_selection            (2),
		.tx_common_mode              ("0.65V"),
		.rx_pll_lock_speed           ("AUTO"),
		.rx_common_mode              ("0.82V"),
		.rx_termination              ("OCT_100_OHMS"),
		.rx_use_external_termination ("false"),
		.rx_eq_dc_gain               (1),
		.rx_eq_ctrl                  (16),
		.starting_channel_number     (0),
		.pll_refclk_cnt              (1),
		.en_synce_support            (0),
		.plls                        (1),
		.pll_refclk_select           ("0"),
		.cdr_refclk_select           (0),
		.pll_type                    ("CMU"),
		.pll_select                  (0),
		.pll_reconfig                (0),
		.channel_interface           (0),
		.pll_feedback_path           ("no_compensation"),
		.enable_fpll_clkdiv33        (1),
		.mgmt_clk_in_mhz             (150),
		.embedded_reset              (1)
	) low_latency_xcvr_1x32_inst (
		.phy_mgmt_clk         (phy_mgmt_clk),         //       phy_mgmt_clk.clk
		.phy_mgmt_clk_reset   (phy_mgmt_clk_reset),   // phy_mgmt_clk_reset.reset
		.phy_mgmt_address     (phy_mgmt_address),     //           phy_mgmt.address
		.phy_mgmt_read        (phy_mgmt_read),        //                   .read
		.phy_mgmt_readdata    (phy_mgmt_readdata),    //                   .readdata
		.phy_mgmt_waitrequest (phy_mgmt_waitrequest), //                   .waitrequest
		.phy_mgmt_write       (phy_mgmt_write),       //                   .write
		.phy_mgmt_writedata   (phy_mgmt_writedata),   //                   .writedata
		.tx_ready             (tx_ready),             //           tx_ready.export
		.rx_ready             (rx_ready),             //           rx_ready.export
		.pll_ref_clk          (pll_ref_clk),          //        pll_ref_clk.clk
		.pll_locked           (pll_locked),           //         pll_locked.export
		.tx_serial_data       (tx_serial_data),       //     tx_serial_data.export
		.rx_serial_data       (rx_serial_data),       //     rx_serial_data.export
		.rx_is_lockedtoref    (rx_is_lockedtoref),    //  rx_is_lockedtoref.export
		.rx_is_lockedtodata   (rx_is_lockedtodata),   // rx_is_lockedtodata.export
		.tx_clkout            (tx_clkout),            //          tx_clkout.export
		.rx_clkout            (rx_clkout),            //          rx_clkout.export
		.tx_parallel_data     (tx_parallel_data),     //   tx_parallel_data.export
		.rx_parallel_data     (rx_parallel_data),     //   rx_parallel_data.export
		.reconfig_from_xcvr   (reconfig_from_xcvr),   // reconfig_from_xcvr.reconfig_from_xcvr
		.reconfig_to_xcvr     (reconfig_to_xcvr),     //   reconfig_to_xcvr.reconfig_to_xcvr
		.tx_bitslip           (7'b0000000),           //        (terminated)
		.rx_bitslip           (1'b0),                 //        (terminated)
		.tx_coreclkin         (1'b0),                 //        (terminated)
		.rx_coreclkin         (1'b0),                 //        (terminated)
		.cdr_ref_clk          (1'b0),                 //        (terminated)
		.pll_powerdown        (1'b0),                 //        (terminated)
		.tx_digitalreset      (1'b0),                 //        (terminated)
		.tx_analogreset       (1'b0),                 //        (terminated)
		.tx_cal_busy          (),                     //        (terminated)
		.rx_digitalreset      (1'b0),                 //        (terminated)
		.rx_analogreset       (1'b0),                 //        (terminated)
		.rx_cal_busy          (),                     //        (terminated)
		.rx_cdr_reset_disable (1'b0)                  //        (terminated)
	);

endmodule
