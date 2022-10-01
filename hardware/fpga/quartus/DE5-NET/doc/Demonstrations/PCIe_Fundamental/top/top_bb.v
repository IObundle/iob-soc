
module top (
	clk_clk,
	hip_ctrl_test_in,
	hip_ctrl_simu_mode_pipe,
	hip_pipe_sim_pipe_pclk_in,
	hip_pipe_sim_pipe_rate,
	hip_pipe_sim_ltssmstate,
	hip_pipe_eidleinfersel0,
	hip_pipe_eidleinfersel1,
	hip_pipe_eidleinfersel2,
	hip_pipe_eidleinfersel3,
	hip_pipe_eidleinfersel4,
	hip_pipe_eidleinfersel5,
	hip_pipe_eidleinfersel6,
	hip_pipe_eidleinfersel7,
	hip_pipe_powerdown0,
	hip_pipe_powerdown1,
	hip_pipe_powerdown2,
	hip_pipe_powerdown3,
	hip_pipe_powerdown4,
	hip_pipe_powerdown5,
	hip_pipe_powerdown6,
	hip_pipe_powerdown7,
	hip_pipe_rxpolarity0,
	hip_pipe_rxpolarity1,
	hip_pipe_rxpolarity2,
	hip_pipe_rxpolarity3,
	hip_pipe_rxpolarity4,
	hip_pipe_rxpolarity5,
	hip_pipe_rxpolarity6,
	hip_pipe_rxpolarity7,
	hip_pipe_txcompl0,
	hip_pipe_txcompl1,
	hip_pipe_txcompl2,
	hip_pipe_txcompl3,
	hip_pipe_txcompl4,
	hip_pipe_txcompl5,
	hip_pipe_txcompl6,
	hip_pipe_txcompl7,
	hip_pipe_txdata0,
	hip_pipe_txdata1,
	hip_pipe_txdata2,
	hip_pipe_txdata3,
	hip_pipe_txdata4,
	hip_pipe_txdata5,
	hip_pipe_txdata6,
	hip_pipe_txdata7,
	hip_pipe_txdatak0,
	hip_pipe_txdatak1,
	hip_pipe_txdatak2,
	hip_pipe_txdatak3,
	hip_pipe_txdatak4,
	hip_pipe_txdatak5,
	hip_pipe_txdatak6,
	hip_pipe_txdatak7,
	hip_pipe_txdetectrx0,
	hip_pipe_txdetectrx1,
	hip_pipe_txdetectrx2,
	hip_pipe_txdetectrx3,
	hip_pipe_txdetectrx4,
	hip_pipe_txdetectrx5,
	hip_pipe_txdetectrx6,
	hip_pipe_txdetectrx7,
	hip_pipe_txelecidle0,
	hip_pipe_txelecidle1,
	hip_pipe_txelecidle2,
	hip_pipe_txelecidle3,
	hip_pipe_txelecidle4,
	hip_pipe_txelecidle5,
	hip_pipe_txelecidle6,
	hip_pipe_txelecidle7,
	hip_pipe_txdeemph0,
	hip_pipe_txdeemph1,
	hip_pipe_txdeemph2,
	hip_pipe_txdeemph3,
	hip_pipe_txdeemph4,
	hip_pipe_txdeemph5,
	hip_pipe_txdeemph6,
	hip_pipe_txdeemph7,
	hip_pipe_txmargin0,
	hip_pipe_txmargin1,
	hip_pipe_txmargin2,
	hip_pipe_txmargin3,
	hip_pipe_txmargin4,
	hip_pipe_txmargin5,
	hip_pipe_txmargin6,
	hip_pipe_txmargin7,
	hip_pipe_txswing0,
	hip_pipe_txswing1,
	hip_pipe_txswing2,
	hip_pipe_txswing3,
	hip_pipe_txswing4,
	hip_pipe_txswing5,
	hip_pipe_txswing6,
	hip_pipe_txswing7,
	hip_pipe_phystatus0,
	hip_pipe_phystatus1,
	hip_pipe_phystatus2,
	hip_pipe_phystatus3,
	hip_pipe_phystatus4,
	hip_pipe_phystatus5,
	hip_pipe_phystatus6,
	hip_pipe_phystatus7,
	hip_pipe_rxdata0,
	hip_pipe_rxdata1,
	hip_pipe_rxdata2,
	hip_pipe_rxdata3,
	hip_pipe_rxdata4,
	hip_pipe_rxdata5,
	hip_pipe_rxdata6,
	hip_pipe_rxdata7,
	hip_pipe_rxdatak0,
	hip_pipe_rxdatak1,
	hip_pipe_rxdatak2,
	hip_pipe_rxdatak3,
	hip_pipe_rxdatak4,
	hip_pipe_rxdatak5,
	hip_pipe_rxdatak6,
	hip_pipe_rxdatak7,
	hip_pipe_rxelecidle0,
	hip_pipe_rxelecidle1,
	hip_pipe_rxelecidle2,
	hip_pipe_rxelecidle3,
	hip_pipe_rxelecidle4,
	hip_pipe_rxelecidle5,
	hip_pipe_rxelecidle6,
	hip_pipe_rxelecidle7,
	hip_pipe_rxstatus0,
	hip_pipe_rxstatus1,
	hip_pipe_rxstatus2,
	hip_pipe_rxstatus3,
	hip_pipe_rxstatus4,
	hip_pipe_rxstatus5,
	hip_pipe_rxstatus6,
	hip_pipe_rxstatus7,
	hip_pipe_rxvalid0,
	hip_pipe_rxvalid1,
	hip_pipe_rxvalid2,
	hip_pipe_rxvalid3,
	hip_pipe_rxvalid4,
	hip_pipe_rxvalid5,
	hip_pipe_rxvalid6,
	hip_pipe_rxvalid7,
	hip_serial_rx_in0,
	hip_serial_rx_in1,
	hip_serial_rx_in2,
	hip_serial_rx_in3,
	hip_serial_rx_in4,
	hip_serial_rx_in5,
	hip_serial_rx_in6,
	hip_serial_rx_in7,
	hip_serial_tx_out0,
	hip_serial_tx_out1,
	hip_serial_tx_out2,
	hip_serial_tx_out3,
	hip_serial_tx_out4,
	hip_serial_tx_out5,
	hip_serial_tx_out6,
	hip_serial_tx_out7,
	pcie_256_hip_avmm_0_reconfig_clk_locked_fixedclk_locked,
	pcie_rstn_npor,
	pcie_rstn_pin_perst,
	pio_button_external_connection_export,
	pio_led_external_connection_export,
	refclk_clk,
	reset_reset_n);	

	input		clk_clk;
	input	[31:0]	hip_ctrl_test_in;
	input		hip_ctrl_simu_mode_pipe;
	input		hip_pipe_sim_pipe_pclk_in;
	output	[1:0]	hip_pipe_sim_pipe_rate;
	output	[4:0]	hip_pipe_sim_ltssmstate;
	output	[2:0]	hip_pipe_eidleinfersel0;
	output	[2:0]	hip_pipe_eidleinfersel1;
	output	[2:0]	hip_pipe_eidleinfersel2;
	output	[2:0]	hip_pipe_eidleinfersel3;
	output	[2:0]	hip_pipe_eidleinfersel4;
	output	[2:0]	hip_pipe_eidleinfersel5;
	output	[2:0]	hip_pipe_eidleinfersel6;
	output	[2:0]	hip_pipe_eidleinfersel7;
	output	[1:0]	hip_pipe_powerdown0;
	output	[1:0]	hip_pipe_powerdown1;
	output	[1:0]	hip_pipe_powerdown2;
	output	[1:0]	hip_pipe_powerdown3;
	output	[1:0]	hip_pipe_powerdown4;
	output	[1:0]	hip_pipe_powerdown5;
	output	[1:0]	hip_pipe_powerdown6;
	output	[1:0]	hip_pipe_powerdown7;
	output		hip_pipe_rxpolarity0;
	output		hip_pipe_rxpolarity1;
	output		hip_pipe_rxpolarity2;
	output		hip_pipe_rxpolarity3;
	output		hip_pipe_rxpolarity4;
	output		hip_pipe_rxpolarity5;
	output		hip_pipe_rxpolarity6;
	output		hip_pipe_rxpolarity7;
	output		hip_pipe_txcompl0;
	output		hip_pipe_txcompl1;
	output		hip_pipe_txcompl2;
	output		hip_pipe_txcompl3;
	output		hip_pipe_txcompl4;
	output		hip_pipe_txcompl5;
	output		hip_pipe_txcompl6;
	output		hip_pipe_txcompl7;
	output	[7:0]	hip_pipe_txdata0;
	output	[7:0]	hip_pipe_txdata1;
	output	[7:0]	hip_pipe_txdata2;
	output	[7:0]	hip_pipe_txdata3;
	output	[7:0]	hip_pipe_txdata4;
	output	[7:0]	hip_pipe_txdata5;
	output	[7:0]	hip_pipe_txdata6;
	output	[7:0]	hip_pipe_txdata7;
	output		hip_pipe_txdatak0;
	output		hip_pipe_txdatak1;
	output		hip_pipe_txdatak2;
	output		hip_pipe_txdatak3;
	output		hip_pipe_txdatak4;
	output		hip_pipe_txdatak5;
	output		hip_pipe_txdatak6;
	output		hip_pipe_txdatak7;
	output		hip_pipe_txdetectrx0;
	output		hip_pipe_txdetectrx1;
	output		hip_pipe_txdetectrx2;
	output		hip_pipe_txdetectrx3;
	output		hip_pipe_txdetectrx4;
	output		hip_pipe_txdetectrx5;
	output		hip_pipe_txdetectrx6;
	output		hip_pipe_txdetectrx7;
	output		hip_pipe_txelecidle0;
	output		hip_pipe_txelecidle1;
	output		hip_pipe_txelecidle2;
	output		hip_pipe_txelecidle3;
	output		hip_pipe_txelecidle4;
	output		hip_pipe_txelecidle5;
	output		hip_pipe_txelecidle6;
	output		hip_pipe_txelecidle7;
	output		hip_pipe_txdeemph0;
	output		hip_pipe_txdeemph1;
	output		hip_pipe_txdeemph2;
	output		hip_pipe_txdeemph3;
	output		hip_pipe_txdeemph4;
	output		hip_pipe_txdeemph5;
	output		hip_pipe_txdeemph6;
	output		hip_pipe_txdeemph7;
	output	[2:0]	hip_pipe_txmargin0;
	output	[2:0]	hip_pipe_txmargin1;
	output	[2:0]	hip_pipe_txmargin2;
	output	[2:0]	hip_pipe_txmargin3;
	output	[2:0]	hip_pipe_txmargin4;
	output	[2:0]	hip_pipe_txmargin5;
	output	[2:0]	hip_pipe_txmargin6;
	output	[2:0]	hip_pipe_txmargin7;
	output		hip_pipe_txswing0;
	output		hip_pipe_txswing1;
	output		hip_pipe_txswing2;
	output		hip_pipe_txswing3;
	output		hip_pipe_txswing4;
	output		hip_pipe_txswing5;
	output		hip_pipe_txswing6;
	output		hip_pipe_txswing7;
	input		hip_pipe_phystatus0;
	input		hip_pipe_phystatus1;
	input		hip_pipe_phystatus2;
	input		hip_pipe_phystatus3;
	input		hip_pipe_phystatus4;
	input		hip_pipe_phystatus5;
	input		hip_pipe_phystatus6;
	input		hip_pipe_phystatus7;
	input	[7:0]	hip_pipe_rxdata0;
	input	[7:0]	hip_pipe_rxdata1;
	input	[7:0]	hip_pipe_rxdata2;
	input	[7:0]	hip_pipe_rxdata3;
	input	[7:0]	hip_pipe_rxdata4;
	input	[7:0]	hip_pipe_rxdata5;
	input	[7:0]	hip_pipe_rxdata6;
	input	[7:0]	hip_pipe_rxdata7;
	input		hip_pipe_rxdatak0;
	input		hip_pipe_rxdatak1;
	input		hip_pipe_rxdatak2;
	input		hip_pipe_rxdatak3;
	input		hip_pipe_rxdatak4;
	input		hip_pipe_rxdatak5;
	input		hip_pipe_rxdatak6;
	input		hip_pipe_rxdatak7;
	input		hip_pipe_rxelecidle0;
	input		hip_pipe_rxelecidle1;
	input		hip_pipe_rxelecidle2;
	input		hip_pipe_rxelecidle3;
	input		hip_pipe_rxelecidle4;
	input		hip_pipe_rxelecidle5;
	input		hip_pipe_rxelecidle6;
	input		hip_pipe_rxelecidle7;
	input	[2:0]	hip_pipe_rxstatus0;
	input	[2:0]	hip_pipe_rxstatus1;
	input	[2:0]	hip_pipe_rxstatus2;
	input	[2:0]	hip_pipe_rxstatus3;
	input	[2:0]	hip_pipe_rxstatus4;
	input	[2:0]	hip_pipe_rxstatus5;
	input	[2:0]	hip_pipe_rxstatus6;
	input	[2:0]	hip_pipe_rxstatus7;
	input		hip_pipe_rxvalid0;
	input		hip_pipe_rxvalid1;
	input		hip_pipe_rxvalid2;
	input		hip_pipe_rxvalid3;
	input		hip_pipe_rxvalid4;
	input		hip_pipe_rxvalid5;
	input		hip_pipe_rxvalid6;
	input		hip_pipe_rxvalid7;
	input		hip_serial_rx_in0;
	input		hip_serial_rx_in1;
	input		hip_serial_rx_in2;
	input		hip_serial_rx_in3;
	input		hip_serial_rx_in4;
	input		hip_serial_rx_in5;
	input		hip_serial_rx_in6;
	input		hip_serial_rx_in7;
	output		hip_serial_tx_out0;
	output		hip_serial_tx_out1;
	output		hip_serial_tx_out2;
	output		hip_serial_tx_out3;
	output		hip_serial_tx_out4;
	output		hip_serial_tx_out5;
	output		hip_serial_tx_out6;
	output		hip_serial_tx_out7;
	output		pcie_256_hip_avmm_0_reconfig_clk_locked_fixedclk_locked;
	input		pcie_rstn_npor;
	input		pcie_rstn_pin_perst;
	input	[3:0]	pio_button_external_connection_export;
	output	[3:0]	pio_led_external_connection_export;
	input		refclk_clk;
	input		reset_reset_n;
endmodule
