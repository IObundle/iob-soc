	component top is
		port (
			clk_clk                                                 : in    std_logic                     := 'X';             -- clk
			ddr3a_status_external_connection_export                 : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- export
			ddr3b_status_external_connection_export                 : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- export
			hip_ctrl_test_in                                        : in    std_logic_vector(31 downto 0) := (others => 'X'); -- test_in
			hip_ctrl_simu_mode_pipe                                 : in    std_logic                     := 'X';             -- simu_mode_pipe
			hip_pipe_sim_pipe_pclk_in                               : in    std_logic                     := 'X';             -- sim_pipe_pclk_in
			hip_pipe_sim_pipe_rate                                  : out   std_logic_vector(1 downto 0);                     -- sim_pipe_rate
			hip_pipe_sim_ltssmstate                                 : out   std_logic_vector(4 downto 0);                     -- sim_ltssmstate
			hip_pipe_eidleinfersel0                                 : out   std_logic_vector(2 downto 0);                     -- eidleinfersel0
			hip_pipe_eidleinfersel1                                 : out   std_logic_vector(2 downto 0);                     -- eidleinfersel1
			hip_pipe_eidleinfersel2                                 : out   std_logic_vector(2 downto 0);                     -- eidleinfersel2
			hip_pipe_eidleinfersel3                                 : out   std_logic_vector(2 downto 0);                     -- eidleinfersel3
			hip_pipe_eidleinfersel4                                 : out   std_logic_vector(2 downto 0);                     -- eidleinfersel4
			hip_pipe_eidleinfersel5                                 : out   std_logic_vector(2 downto 0);                     -- eidleinfersel5
			hip_pipe_eidleinfersel6                                 : out   std_logic_vector(2 downto 0);                     -- eidleinfersel6
			hip_pipe_eidleinfersel7                                 : out   std_logic_vector(2 downto 0);                     -- eidleinfersel7
			hip_pipe_powerdown0                                     : out   std_logic_vector(1 downto 0);                     -- powerdown0
			hip_pipe_powerdown1                                     : out   std_logic_vector(1 downto 0);                     -- powerdown1
			hip_pipe_powerdown2                                     : out   std_logic_vector(1 downto 0);                     -- powerdown2
			hip_pipe_powerdown3                                     : out   std_logic_vector(1 downto 0);                     -- powerdown3
			hip_pipe_powerdown4                                     : out   std_logic_vector(1 downto 0);                     -- powerdown4
			hip_pipe_powerdown5                                     : out   std_logic_vector(1 downto 0);                     -- powerdown5
			hip_pipe_powerdown6                                     : out   std_logic_vector(1 downto 0);                     -- powerdown6
			hip_pipe_powerdown7                                     : out   std_logic_vector(1 downto 0);                     -- powerdown7
			hip_pipe_rxpolarity0                                    : out   std_logic;                                        -- rxpolarity0
			hip_pipe_rxpolarity1                                    : out   std_logic;                                        -- rxpolarity1
			hip_pipe_rxpolarity2                                    : out   std_logic;                                        -- rxpolarity2
			hip_pipe_rxpolarity3                                    : out   std_logic;                                        -- rxpolarity3
			hip_pipe_rxpolarity4                                    : out   std_logic;                                        -- rxpolarity4
			hip_pipe_rxpolarity5                                    : out   std_logic;                                        -- rxpolarity5
			hip_pipe_rxpolarity6                                    : out   std_logic;                                        -- rxpolarity6
			hip_pipe_rxpolarity7                                    : out   std_logic;                                        -- rxpolarity7
			hip_pipe_txcompl0                                       : out   std_logic;                                        -- txcompl0
			hip_pipe_txcompl1                                       : out   std_logic;                                        -- txcompl1
			hip_pipe_txcompl2                                       : out   std_logic;                                        -- txcompl2
			hip_pipe_txcompl3                                       : out   std_logic;                                        -- txcompl3
			hip_pipe_txcompl4                                       : out   std_logic;                                        -- txcompl4
			hip_pipe_txcompl5                                       : out   std_logic;                                        -- txcompl5
			hip_pipe_txcompl6                                       : out   std_logic;                                        -- txcompl6
			hip_pipe_txcompl7                                       : out   std_logic;                                        -- txcompl7
			hip_pipe_txdata0                                        : out   std_logic_vector(7 downto 0);                     -- txdata0
			hip_pipe_txdata1                                        : out   std_logic_vector(7 downto 0);                     -- txdata1
			hip_pipe_txdata2                                        : out   std_logic_vector(7 downto 0);                     -- txdata2
			hip_pipe_txdata3                                        : out   std_logic_vector(7 downto 0);                     -- txdata3
			hip_pipe_txdata4                                        : out   std_logic_vector(7 downto 0);                     -- txdata4
			hip_pipe_txdata5                                        : out   std_logic_vector(7 downto 0);                     -- txdata5
			hip_pipe_txdata6                                        : out   std_logic_vector(7 downto 0);                     -- txdata6
			hip_pipe_txdata7                                        : out   std_logic_vector(7 downto 0);                     -- txdata7
			hip_pipe_txdatak0                                       : out   std_logic;                                        -- txdatak0
			hip_pipe_txdatak1                                       : out   std_logic;                                        -- txdatak1
			hip_pipe_txdatak2                                       : out   std_logic;                                        -- txdatak2
			hip_pipe_txdatak3                                       : out   std_logic;                                        -- txdatak3
			hip_pipe_txdatak4                                       : out   std_logic;                                        -- txdatak4
			hip_pipe_txdatak5                                       : out   std_logic;                                        -- txdatak5
			hip_pipe_txdatak6                                       : out   std_logic;                                        -- txdatak6
			hip_pipe_txdatak7                                       : out   std_logic;                                        -- txdatak7
			hip_pipe_txdetectrx0                                    : out   std_logic;                                        -- txdetectrx0
			hip_pipe_txdetectrx1                                    : out   std_logic;                                        -- txdetectrx1
			hip_pipe_txdetectrx2                                    : out   std_logic;                                        -- txdetectrx2
			hip_pipe_txdetectrx3                                    : out   std_logic;                                        -- txdetectrx3
			hip_pipe_txdetectrx4                                    : out   std_logic;                                        -- txdetectrx4
			hip_pipe_txdetectrx5                                    : out   std_logic;                                        -- txdetectrx5
			hip_pipe_txdetectrx6                                    : out   std_logic;                                        -- txdetectrx6
			hip_pipe_txdetectrx7                                    : out   std_logic;                                        -- txdetectrx7
			hip_pipe_txelecidle0                                    : out   std_logic;                                        -- txelecidle0
			hip_pipe_txelecidle1                                    : out   std_logic;                                        -- txelecidle1
			hip_pipe_txelecidle2                                    : out   std_logic;                                        -- txelecidle2
			hip_pipe_txelecidle3                                    : out   std_logic;                                        -- txelecidle3
			hip_pipe_txelecidle4                                    : out   std_logic;                                        -- txelecidle4
			hip_pipe_txelecidle5                                    : out   std_logic;                                        -- txelecidle5
			hip_pipe_txelecidle6                                    : out   std_logic;                                        -- txelecidle6
			hip_pipe_txelecidle7                                    : out   std_logic;                                        -- txelecidle7
			hip_pipe_txdeemph0                                      : out   std_logic;                                        -- txdeemph0
			hip_pipe_txdeemph1                                      : out   std_logic;                                        -- txdeemph1
			hip_pipe_txdeemph2                                      : out   std_logic;                                        -- txdeemph2
			hip_pipe_txdeemph3                                      : out   std_logic;                                        -- txdeemph3
			hip_pipe_txdeemph4                                      : out   std_logic;                                        -- txdeemph4
			hip_pipe_txdeemph5                                      : out   std_logic;                                        -- txdeemph5
			hip_pipe_txdeemph6                                      : out   std_logic;                                        -- txdeemph6
			hip_pipe_txdeemph7                                      : out   std_logic;                                        -- txdeemph7
			hip_pipe_txmargin0                                      : out   std_logic_vector(2 downto 0);                     -- txmargin0
			hip_pipe_txmargin1                                      : out   std_logic_vector(2 downto 0);                     -- txmargin1
			hip_pipe_txmargin2                                      : out   std_logic_vector(2 downto 0);                     -- txmargin2
			hip_pipe_txmargin3                                      : out   std_logic_vector(2 downto 0);                     -- txmargin3
			hip_pipe_txmargin4                                      : out   std_logic_vector(2 downto 0);                     -- txmargin4
			hip_pipe_txmargin5                                      : out   std_logic_vector(2 downto 0);                     -- txmargin5
			hip_pipe_txmargin6                                      : out   std_logic_vector(2 downto 0);                     -- txmargin6
			hip_pipe_txmargin7                                      : out   std_logic_vector(2 downto 0);                     -- txmargin7
			hip_pipe_txswing0                                       : out   std_logic;                                        -- txswing0
			hip_pipe_txswing1                                       : out   std_logic;                                        -- txswing1
			hip_pipe_txswing2                                       : out   std_logic;                                        -- txswing2
			hip_pipe_txswing3                                       : out   std_logic;                                        -- txswing3
			hip_pipe_txswing4                                       : out   std_logic;                                        -- txswing4
			hip_pipe_txswing5                                       : out   std_logic;                                        -- txswing5
			hip_pipe_txswing6                                       : out   std_logic;                                        -- txswing6
			hip_pipe_txswing7                                       : out   std_logic;                                        -- txswing7
			hip_pipe_phystatus0                                     : in    std_logic                     := 'X';             -- phystatus0
			hip_pipe_phystatus1                                     : in    std_logic                     := 'X';             -- phystatus1
			hip_pipe_phystatus2                                     : in    std_logic                     := 'X';             -- phystatus2
			hip_pipe_phystatus3                                     : in    std_logic                     := 'X';             -- phystatus3
			hip_pipe_phystatus4                                     : in    std_logic                     := 'X';             -- phystatus4
			hip_pipe_phystatus5                                     : in    std_logic                     := 'X';             -- phystatus5
			hip_pipe_phystatus6                                     : in    std_logic                     := 'X';             -- phystatus6
			hip_pipe_phystatus7                                     : in    std_logic                     := 'X';             -- phystatus7
			hip_pipe_rxdata0                                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata0
			hip_pipe_rxdata1                                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata1
			hip_pipe_rxdata2                                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata2
			hip_pipe_rxdata3                                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata3
			hip_pipe_rxdata4                                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata4
			hip_pipe_rxdata5                                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata5
			hip_pipe_rxdata6                                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata6
			hip_pipe_rxdata7                                        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- rxdata7
			hip_pipe_rxdatak0                                       : in    std_logic                     := 'X';             -- rxdatak0
			hip_pipe_rxdatak1                                       : in    std_logic                     := 'X';             -- rxdatak1
			hip_pipe_rxdatak2                                       : in    std_logic                     := 'X';             -- rxdatak2
			hip_pipe_rxdatak3                                       : in    std_logic                     := 'X';             -- rxdatak3
			hip_pipe_rxdatak4                                       : in    std_logic                     := 'X';             -- rxdatak4
			hip_pipe_rxdatak5                                       : in    std_logic                     := 'X';             -- rxdatak5
			hip_pipe_rxdatak6                                       : in    std_logic                     := 'X';             -- rxdatak6
			hip_pipe_rxdatak7                                       : in    std_logic                     := 'X';             -- rxdatak7
			hip_pipe_rxelecidle0                                    : in    std_logic                     := 'X';             -- rxelecidle0
			hip_pipe_rxelecidle1                                    : in    std_logic                     := 'X';             -- rxelecidle1
			hip_pipe_rxelecidle2                                    : in    std_logic                     := 'X';             -- rxelecidle2
			hip_pipe_rxelecidle3                                    : in    std_logic                     := 'X';             -- rxelecidle3
			hip_pipe_rxelecidle4                                    : in    std_logic                     := 'X';             -- rxelecidle4
			hip_pipe_rxelecidle5                                    : in    std_logic                     := 'X';             -- rxelecidle5
			hip_pipe_rxelecidle6                                    : in    std_logic                     := 'X';             -- rxelecidle6
			hip_pipe_rxelecidle7                                    : in    std_logic                     := 'X';             -- rxelecidle7
			hip_pipe_rxstatus0                                      : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus0
			hip_pipe_rxstatus1                                      : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus1
			hip_pipe_rxstatus2                                      : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus2
			hip_pipe_rxstatus3                                      : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus3
			hip_pipe_rxstatus4                                      : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus4
			hip_pipe_rxstatus5                                      : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus5
			hip_pipe_rxstatus6                                      : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus6
			hip_pipe_rxstatus7                                      : in    std_logic_vector(2 downto 0)  := (others => 'X'); -- rxstatus7
			hip_pipe_rxvalid0                                       : in    std_logic                     := 'X';             -- rxvalid0
			hip_pipe_rxvalid1                                       : in    std_logic                     := 'X';             -- rxvalid1
			hip_pipe_rxvalid2                                       : in    std_logic                     := 'X';             -- rxvalid2
			hip_pipe_rxvalid3                                       : in    std_logic                     := 'X';             -- rxvalid3
			hip_pipe_rxvalid4                                       : in    std_logic                     := 'X';             -- rxvalid4
			hip_pipe_rxvalid5                                       : in    std_logic                     := 'X';             -- rxvalid5
			hip_pipe_rxvalid6                                       : in    std_logic                     := 'X';             -- rxvalid6
			hip_pipe_rxvalid7                                       : in    std_logic                     := 'X';             -- rxvalid7
			hip_serial_rx_in0                                       : in    std_logic                     := 'X';             -- rx_in0
			hip_serial_rx_in1                                       : in    std_logic                     := 'X';             -- rx_in1
			hip_serial_rx_in2                                       : in    std_logic                     := 'X';             -- rx_in2
			hip_serial_rx_in3                                       : in    std_logic                     := 'X';             -- rx_in3
			hip_serial_rx_in4                                       : in    std_logic                     := 'X';             -- rx_in4
			hip_serial_rx_in5                                       : in    std_logic                     := 'X';             -- rx_in5
			hip_serial_rx_in6                                       : in    std_logic                     := 'X';             -- rx_in6
			hip_serial_rx_in7                                       : in    std_logic                     := 'X';             -- rx_in7
			hip_serial_tx_out0                                      : out   std_logic;                                        -- tx_out0
			hip_serial_tx_out1                                      : out   std_logic;                                        -- tx_out1
			hip_serial_tx_out2                                      : out   std_logic;                                        -- tx_out2
			hip_serial_tx_out3                                      : out   std_logic;                                        -- tx_out3
			hip_serial_tx_out4                                      : out   std_logic;                                        -- tx_out4
			hip_serial_tx_out5                                      : out   std_logic;                                        -- tx_out5
			hip_serial_tx_out6                                      : out   std_logic;                                        -- tx_out6
			hip_serial_tx_out7                                      : out   std_logic;                                        -- tx_out7
			mem_if_ddr3a_mem_mem_a                                  : out   std_logic_vector(14 downto 0);                    -- mem_a
			mem_if_ddr3a_mem_mem_ba                                 : out   std_logic_vector(2 downto 0);                     -- mem_ba
			mem_if_ddr3a_mem_mem_ck                                 : out   std_logic_vector(0 downto 0);                     -- mem_ck
			mem_if_ddr3a_mem_mem_ck_n                               : out   std_logic_vector(0 downto 0);                     -- mem_ck_n
			mem_if_ddr3a_mem_mem_cke                                : out   std_logic_vector(0 downto 0);                     -- mem_cke
			mem_if_ddr3a_mem_mem_cs_n                               : out   std_logic_vector(0 downto 0);                     -- mem_cs_n
			mem_if_ddr3a_mem_mem_dm                                 : out   std_logic_vector(7 downto 0);                     -- mem_dm
			mem_if_ddr3a_mem_mem_ras_n                              : out   std_logic_vector(0 downto 0);                     -- mem_ras_n
			mem_if_ddr3a_mem_mem_cas_n                              : out   std_logic_vector(0 downto 0);                     -- mem_cas_n
			mem_if_ddr3a_mem_mem_we_n                               : out   std_logic_vector(0 downto 0);                     -- mem_we_n
			mem_if_ddr3a_mem_mem_reset_n                            : out   std_logic;                                        -- mem_reset_n
			mem_if_ddr3a_mem_mem_dq                                 : inout std_logic_vector(63 downto 0) := (others => 'X'); -- mem_dq
			mem_if_ddr3a_mem_mem_dqs                                : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dqs
			mem_if_ddr3a_mem_mem_dqs_n                              : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dqs_n
			mem_if_ddr3a_mem_mem_odt                                : out   std_logic_vector(0 downto 0);                     -- mem_odt
			mem_if_ddr3a_oct_rzqin                                  : in    std_logic                     := 'X';             -- rzqin
			mem_if_ddr3a_pll_ref_clk_clk                            : in    std_logic                     := 'X';             -- clk
			mem_if_ddr3a_status_local_init_done                     : out   std_logic;                                        -- local_init_done
			mem_if_ddr3a_status_local_cal_success                   : out   std_logic;                                        -- local_cal_success
			mem_if_ddr3a_status_local_cal_fail                      : out   std_logic;                                        -- local_cal_fail
			mem_if_ddr3b_mem_mem_a                                  : out   std_logic_vector(14 downto 0);                    -- mem_a
			mem_if_ddr3b_mem_mem_ba                                 : out   std_logic_vector(2 downto 0);                     -- mem_ba
			mem_if_ddr3b_mem_mem_ck                                 : out   std_logic_vector(0 downto 0);                     -- mem_ck
			mem_if_ddr3b_mem_mem_ck_n                               : out   std_logic_vector(0 downto 0);                     -- mem_ck_n
			mem_if_ddr3b_mem_mem_cke                                : out   std_logic_vector(0 downto 0);                     -- mem_cke
			mem_if_ddr3b_mem_mem_cs_n                               : out   std_logic_vector(0 downto 0);                     -- mem_cs_n
			mem_if_ddr3b_mem_mem_dm                                 : out   std_logic_vector(7 downto 0);                     -- mem_dm
			mem_if_ddr3b_mem_mem_ras_n                              : out   std_logic_vector(0 downto 0);                     -- mem_ras_n
			mem_if_ddr3b_mem_mem_cas_n                              : out   std_logic_vector(0 downto 0);                     -- mem_cas_n
			mem_if_ddr3b_mem_mem_we_n                               : out   std_logic_vector(0 downto 0);                     -- mem_we_n
			mem_if_ddr3b_mem_mem_reset_n                            : out   std_logic;                                        -- mem_reset_n
			mem_if_ddr3b_mem_mem_dq                                 : inout std_logic_vector(63 downto 0) := (others => 'X'); -- mem_dq
			mem_if_ddr3b_mem_mem_dqs                                : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dqs
			mem_if_ddr3b_mem_mem_dqs_n                              : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dqs_n
			mem_if_ddr3b_mem_mem_odt                                : out   std_logic_vector(0 downto 0);                     -- mem_odt
			mem_if_ddr3b_oct_rzqin                                  : in    std_logic                     := 'X';             -- rzqin
			mem_if_ddr3b_pll_ref_clk_clk                            : in    std_logic                     := 'X';             -- clk
			mem_if_ddr3b_status_local_init_done                     : out   std_logic;                                        -- local_init_done
			mem_if_ddr3b_status_local_cal_success                   : out   std_logic;                                        -- local_cal_success
			mem_if_ddr3b_status_local_cal_fail                      : out   std_logic;                                        -- local_cal_fail
			pcie_256_hip_avmm_0_reconfig_clk_locked_fixedclk_locked : out   std_logic;                                        -- fixedclk_locked
			pcie_rstn_npor                                          : in    std_logic                     := 'X';             -- npor
			pcie_rstn_pin_perst                                     : in    std_logic                     := 'X';             -- pin_perst
			pio_button_external_connection_export                   : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			pio_led_external_connection_export                      : out   std_logic_vector(3 downto 0);                     -- export
			refclk_clk                                              : in    std_logic                     := 'X';             -- clk
			reset_reset_n                                           : in    std_logic                     := 'X'              -- reset_n
		);
	end component top;

	u0 : component top
		port map (
			clk_clk                                                 => CONNECTED_TO_clk_clk,                                                 --                                     clk.clk
			ddr3a_status_external_connection_export                 => CONNECTED_TO_ddr3a_status_external_connection_export,                 --        ddr3a_status_external_connection.export
			ddr3b_status_external_connection_export                 => CONNECTED_TO_ddr3b_status_external_connection_export,                 --        ddr3b_status_external_connection.export
			hip_ctrl_test_in                                        => CONNECTED_TO_hip_ctrl_test_in,                                        --                                hip_ctrl.test_in
			hip_ctrl_simu_mode_pipe                                 => CONNECTED_TO_hip_ctrl_simu_mode_pipe,                                 --                                        .simu_mode_pipe
			hip_pipe_sim_pipe_pclk_in                               => CONNECTED_TO_hip_pipe_sim_pipe_pclk_in,                               --                                hip_pipe.sim_pipe_pclk_in
			hip_pipe_sim_pipe_rate                                  => CONNECTED_TO_hip_pipe_sim_pipe_rate,                                  --                                        .sim_pipe_rate
			hip_pipe_sim_ltssmstate                                 => CONNECTED_TO_hip_pipe_sim_ltssmstate,                                 --                                        .sim_ltssmstate
			hip_pipe_eidleinfersel0                                 => CONNECTED_TO_hip_pipe_eidleinfersel0,                                 --                                        .eidleinfersel0
			hip_pipe_eidleinfersel1                                 => CONNECTED_TO_hip_pipe_eidleinfersel1,                                 --                                        .eidleinfersel1
			hip_pipe_eidleinfersel2                                 => CONNECTED_TO_hip_pipe_eidleinfersel2,                                 --                                        .eidleinfersel2
			hip_pipe_eidleinfersel3                                 => CONNECTED_TO_hip_pipe_eidleinfersel3,                                 --                                        .eidleinfersel3
			hip_pipe_eidleinfersel4                                 => CONNECTED_TO_hip_pipe_eidleinfersel4,                                 --                                        .eidleinfersel4
			hip_pipe_eidleinfersel5                                 => CONNECTED_TO_hip_pipe_eidleinfersel5,                                 --                                        .eidleinfersel5
			hip_pipe_eidleinfersel6                                 => CONNECTED_TO_hip_pipe_eidleinfersel6,                                 --                                        .eidleinfersel6
			hip_pipe_eidleinfersel7                                 => CONNECTED_TO_hip_pipe_eidleinfersel7,                                 --                                        .eidleinfersel7
			hip_pipe_powerdown0                                     => CONNECTED_TO_hip_pipe_powerdown0,                                     --                                        .powerdown0
			hip_pipe_powerdown1                                     => CONNECTED_TO_hip_pipe_powerdown1,                                     --                                        .powerdown1
			hip_pipe_powerdown2                                     => CONNECTED_TO_hip_pipe_powerdown2,                                     --                                        .powerdown2
			hip_pipe_powerdown3                                     => CONNECTED_TO_hip_pipe_powerdown3,                                     --                                        .powerdown3
			hip_pipe_powerdown4                                     => CONNECTED_TO_hip_pipe_powerdown4,                                     --                                        .powerdown4
			hip_pipe_powerdown5                                     => CONNECTED_TO_hip_pipe_powerdown5,                                     --                                        .powerdown5
			hip_pipe_powerdown6                                     => CONNECTED_TO_hip_pipe_powerdown6,                                     --                                        .powerdown6
			hip_pipe_powerdown7                                     => CONNECTED_TO_hip_pipe_powerdown7,                                     --                                        .powerdown7
			hip_pipe_rxpolarity0                                    => CONNECTED_TO_hip_pipe_rxpolarity0,                                    --                                        .rxpolarity0
			hip_pipe_rxpolarity1                                    => CONNECTED_TO_hip_pipe_rxpolarity1,                                    --                                        .rxpolarity1
			hip_pipe_rxpolarity2                                    => CONNECTED_TO_hip_pipe_rxpolarity2,                                    --                                        .rxpolarity2
			hip_pipe_rxpolarity3                                    => CONNECTED_TO_hip_pipe_rxpolarity3,                                    --                                        .rxpolarity3
			hip_pipe_rxpolarity4                                    => CONNECTED_TO_hip_pipe_rxpolarity4,                                    --                                        .rxpolarity4
			hip_pipe_rxpolarity5                                    => CONNECTED_TO_hip_pipe_rxpolarity5,                                    --                                        .rxpolarity5
			hip_pipe_rxpolarity6                                    => CONNECTED_TO_hip_pipe_rxpolarity6,                                    --                                        .rxpolarity6
			hip_pipe_rxpolarity7                                    => CONNECTED_TO_hip_pipe_rxpolarity7,                                    --                                        .rxpolarity7
			hip_pipe_txcompl0                                       => CONNECTED_TO_hip_pipe_txcompl0,                                       --                                        .txcompl0
			hip_pipe_txcompl1                                       => CONNECTED_TO_hip_pipe_txcompl1,                                       --                                        .txcompl1
			hip_pipe_txcompl2                                       => CONNECTED_TO_hip_pipe_txcompl2,                                       --                                        .txcompl2
			hip_pipe_txcompl3                                       => CONNECTED_TO_hip_pipe_txcompl3,                                       --                                        .txcompl3
			hip_pipe_txcompl4                                       => CONNECTED_TO_hip_pipe_txcompl4,                                       --                                        .txcompl4
			hip_pipe_txcompl5                                       => CONNECTED_TO_hip_pipe_txcompl5,                                       --                                        .txcompl5
			hip_pipe_txcompl6                                       => CONNECTED_TO_hip_pipe_txcompl6,                                       --                                        .txcompl6
			hip_pipe_txcompl7                                       => CONNECTED_TO_hip_pipe_txcompl7,                                       --                                        .txcompl7
			hip_pipe_txdata0                                        => CONNECTED_TO_hip_pipe_txdata0,                                        --                                        .txdata0
			hip_pipe_txdata1                                        => CONNECTED_TO_hip_pipe_txdata1,                                        --                                        .txdata1
			hip_pipe_txdata2                                        => CONNECTED_TO_hip_pipe_txdata2,                                        --                                        .txdata2
			hip_pipe_txdata3                                        => CONNECTED_TO_hip_pipe_txdata3,                                        --                                        .txdata3
			hip_pipe_txdata4                                        => CONNECTED_TO_hip_pipe_txdata4,                                        --                                        .txdata4
			hip_pipe_txdata5                                        => CONNECTED_TO_hip_pipe_txdata5,                                        --                                        .txdata5
			hip_pipe_txdata6                                        => CONNECTED_TO_hip_pipe_txdata6,                                        --                                        .txdata6
			hip_pipe_txdata7                                        => CONNECTED_TO_hip_pipe_txdata7,                                        --                                        .txdata7
			hip_pipe_txdatak0                                       => CONNECTED_TO_hip_pipe_txdatak0,                                       --                                        .txdatak0
			hip_pipe_txdatak1                                       => CONNECTED_TO_hip_pipe_txdatak1,                                       --                                        .txdatak1
			hip_pipe_txdatak2                                       => CONNECTED_TO_hip_pipe_txdatak2,                                       --                                        .txdatak2
			hip_pipe_txdatak3                                       => CONNECTED_TO_hip_pipe_txdatak3,                                       --                                        .txdatak3
			hip_pipe_txdatak4                                       => CONNECTED_TO_hip_pipe_txdatak4,                                       --                                        .txdatak4
			hip_pipe_txdatak5                                       => CONNECTED_TO_hip_pipe_txdatak5,                                       --                                        .txdatak5
			hip_pipe_txdatak6                                       => CONNECTED_TO_hip_pipe_txdatak6,                                       --                                        .txdatak6
			hip_pipe_txdatak7                                       => CONNECTED_TO_hip_pipe_txdatak7,                                       --                                        .txdatak7
			hip_pipe_txdetectrx0                                    => CONNECTED_TO_hip_pipe_txdetectrx0,                                    --                                        .txdetectrx0
			hip_pipe_txdetectrx1                                    => CONNECTED_TO_hip_pipe_txdetectrx1,                                    --                                        .txdetectrx1
			hip_pipe_txdetectrx2                                    => CONNECTED_TO_hip_pipe_txdetectrx2,                                    --                                        .txdetectrx2
			hip_pipe_txdetectrx3                                    => CONNECTED_TO_hip_pipe_txdetectrx3,                                    --                                        .txdetectrx3
			hip_pipe_txdetectrx4                                    => CONNECTED_TO_hip_pipe_txdetectrx4,                                    --                                        .txdetectrx4
			hip_pipe_txdetectrx5                                    => CONNECTED_TO_hip_pipe_txdetectrx5,                                    --                                        .txdetectrx5
			hip_pipe_txdetectrx6                                    => CONNECTED_TO_hip_pipe_txdetectrx6,                                    --                                        .txdetectrx6
			hip_pipe_txdetectrx7                                    => CONNECTED_TO_hip_pipe_txdetectrx7,                                    --                                        .txdetectrx7
			hip_pipe_txelecidle0                                    => CONNECTED_TO_hip_pipe_txelecidle0,                                    --                                        .txelecidle0
			hip_pipe_txelecidle1                                    => CONNECTED_TO_hip_pipe_txelecidle1,                                    --                                        .txelecidle1
			hip_pipe_txelecidle2                                    => CONNECTED_TO_hip_pipe_txelecidle2,                                    --                                        .txelecidle2
			hip_pipe_txelecidle3                                    => CONNECTED_TO_hip_pipe_txelecidle3,                                    --                                        .txelecidle3
			hip_pipe_txelecidle4                                    => CONNECTED_TO_hip_pipe_txelecidle4,                                    --                                        .txelecidle4
			hip_pipe_txelecidle5                                    => CONNECTED_TO_hip_pipe_txelecidle5,                                    --                                        .txelecidle5
			hip_pipe_txelecidle6                                    => CONNECTED_TO_hip_pipe_txelecidle6,                                    --                                        .txelecidle6
			hip_pipe_txelecidle7                                    => CONNECTED_TO_hip_pipe_txelecidle7,                                    --                                        .txelecidle7
			hip_pipe_txdeemph0                                      => CONNECTED_TO_hip_pipe_txdeemph0,                                      --                                        .txdeemph0
			hip_pipe_txdeemph1                                      => CONNECTED_TO_hip_pipe_txdeemph1,                                      --                                        .txdeemph1
			hip_pipe_txdeemph2                                      => CONNECTED_TO_hip_pipe_txdeemph2,                                      --                                        .txdeemph2
			hip_pipe_txdeemph3                                      => CONNECTED_TO_hip_pipe_txdeemph3,                                      --                                        .txdeemph3
			hip_pipe_txdeemph4                                      => CONNECTED_TO_hip_pipe_txdeemph4,                                      --                                        .txdeemph4
			hip_pipe_txdeemph5                                      => CONNECTED_TO_hip_pipe_txdeemph5,                                      --                                        .txdeemph5
			hip_pipe_txdeemph6                                      => CONNECTED_TO_hip_pipe_txdeemph6,                                      --                                        .txdeemph6
			hip_pipe_txdeemph7                                      => CONNECTED_TO_hip_pipe_txdeemph7,                                      --                                        .txdeemph7
			hip_pipe_txmargin0                                      => CONNECTED_TO_hip_pipe_txmargin0,                                      --                                        .txmargin0
			hip_pipe_txmargin1                                      => CONNECTED_TO_hip_pipe_txmargin1,                                      --                                        .txmargin1
			hip_pipe_txmargin2                                      => CONNECTED_TO_hip_pipe_txmargin2,                                      --                                        .txmargin2
			hip_pipe_txmargin3                                      => CONNECTED_TO_hip_pipe_txmargin3,                                      --                                        .txmargin3
			hip_pipe_txmargin4                                      => CONNECTED_TO_hip_pipe_txmargin4,                                      --                                        .txmargin4
			hip_pipe_txmargin5                                      => CONNECTED_TO_hip_pipe_txmargin5,                                      --                                        .txmargin5
			hip_pipe_txmargin6                                      => CONNECTED_TO_hip_pipe_txmargin6,                                      --                                        .txmargin6
			hip_pipe_txmargin7                                      => CONNECTED_TO_hip_pipe_txmargin7,                                      --                                        .txmargin7
			hip_pipe_txswing0                                       => CONNECTED_TO_hip_pipe_txswing0,                                       --                                        .txswing0
			hip_pipe_txswing1                                       => CONNECTED_TO_hip_pipe_txswing1,                                       --                                        .txswing1
			hip_pipe_txswing2                                       => CONNECTED_TO_hip_pipe_txswing2,                                       --                                        .txswing2
			hip_pipe_txswing3                                       => CONNECTED_TO_hip_pipe_txswing3,                                       --                                        .txswing3
			hip_pipe_txswing4                                       => CONNECTED_TO_hip_pipe_txswing4,                                       --                                        .txswing4
			hip_pipe_txswing5                                       => CONNECTED_TO_hip_pipe_txswing5,                                       --                                        .txswing5
			hip_pipe_txswing6                                       => CONNECTED_TO_hip_pipe_txswing6,                                       --                                        .txswing6
			hip_pipe_txswing7                                       => CONNECTED_TO_hip_pipe_txswing7,                                       --                                        .txswing7
			hip_pipe_phystatus0                                     => CONNECTED_TO_hip_pipe_phystatus0,                                     --                                        .phystatus0
			hip_pipe_phystatus1                                     => CONNECTED_TO_hip_pipe_phystatus1,                                     --                                        .phystatus1
			hip_pipe_phystatus2                                     => CONNECTED_TO_hip_pipe_phystatus2,                                     --                                        .phystatus2
			hip_pipe_phystatus3                                     => CONNECTED_TO_hip_pipe_phystatus3,                                     --                                        .phystatus3
			hip_pipe_phystatus4                                     => CONNECTED_TO_hip_pipe_phystatus4,                                     --                                        .phystatus4
			hip_pipe_phystatus5                                     => CONNECTED_TO_hip_pipe_phystatus5,                                     --                                        .phystatus5
			hip_pipe_phystatus6                                     => CONNECTED_TO_hip_pipe_phystatus6,                                     --                                        .phystatus6
			hip_pipe_phystatus7                                     => CONNECTED_TO_hip_pipe_phystatus7,                                     --                                        .phystatus7
			hip_pipe_rxdata0                                        => CONNECTED_TO_hip_pipe_rxdata0,                                        --                                        .rxdata0
			hip_pipe_rxdata1                                        => CONNECTED_TO_hip_pipe_rxdata1,                                        --                                        .rxdata1
			hip_pipe_rxdata2                                        => CONNECTED_TO_hip_pipe_rxdata2,                                        --                                        .rxdata2
			hip_pipe_rxdata3                                        => CONNECTED_TO_hip_pipe_rxdata3,                                        --                                        .rxdata3
			hip_pipe_rxdata4                                        => CONNECTED_TO_hip_pipe_rxdata4,                                        --                                        .rxdata4
			hip_pipe_rxdata5                                        => CONNECTED_TO_hip_pipe_rxdata5,                                        --                                        .rxdata5
			hip_pipe_rxdata6                                        => CONNECTED_TO_hip_pipe_rxdata6,                                        --                                        .rxdata6
			hip_pipe_rxdata7                                        => CONNECTED_TO_hip_pipe_rxdata7,                                        --                                        .rxdata7
			hip_pipe_rxdatak0                                       => CONNECTED_TO_hip_pipe_rxdatak0,                                       --                                        .rxdatak0
			hip_pipe_rxdatak1                                       => CONNECTED_TO_hip_pipe_rxdatak1,                                       --                                        .rxdatak1
			hip_pipe_rxdatak2                                       => CONNECTED_TO_hip_pipe_rxdatak2,                                       --                                        .rxdatak2
			hip_pipe_rxdatak3                                       => CONNECTED_TO_hip_pipe_rxdatak3,                                       --                                        .rxdatak3
			hip_pipe_rxdatak4                                       => CONNECTED_TO_hip_pipe_rxdatak4,                                       --                                        .rxdatak4
			hip_pipe_rxdatak5                                       => CONNECTED_TO_hip_pipe_rxdatak5,                                       --                                        .rxdatak5
			hip_pipe_rxdatak6                                       => CONNECTED_TO_hip_pipe_rxdatak6,                                       --                                        .rxdatak6
			hip_pipe_rxdatak7                                       => CONNECTED_TO_hip_pipe_rxdatak7,                                       --                                        .rxdatak7
			hip_pipe_rxelecidle0                                    => CONNECTED_TO_hip_pipe_rxelecidle0,                                    --                                        .rxelecidle0
			hip_pipe_rxelecidle1                                    => CONNECTED_TO_hip_pipe_rxelecidle1,                                    --                                        .rxelecidle1
			hip_pipe_rxelecidle2                                    => CONNECTED_TO_hip_pipe_rxelecidle2,                                    --                                        .rxelecidle2
			hip_pipe_rxelecidle3                                    => CONNECTED_TO_hip_pipe_rxelecidle3,                                    --                                        .rxelecidle3
			hip_pipe_rxelecidle4                                    => CONNECTED_TO_hip_pipe_rxelecidle4,                                    --                                        .rxelecidle4
			hip_pipe_rxelecidle5                                    => CONNECTED_TO_hip_pipe_rxelecidle5,                                    --                                        .rxelecidle5
			hip_pipe_rxelecidle6                                    => CONNECTED_TO_hip_pipe_rxelecidle6,                                    --                                        .rxelecidle6
			hip_pipe_rxelecidle7                                    => CONNECTED_TO_hip_pipe_rxelecidle7,                                    --                                        .rxelecidle7
			hip_pipe_rxstatus0                                      => CONNECTED_TO_hip_pipe_rxstatus0,                                      --                                        .rxstatus0
			hip_pipe_rxstatus1                                      => CONNECTED_TO_hip_pipe_rxstatus1,                                      --                                        .rxstatus1
			hip_pipe_rxstatus2                                      => CONNECTED_TO_hip_pipe_rxstatus2,                                      --                                        .rxstatus2
			hip_pipe_rxstatus3                                      => CONNECTED_TO_hip_pipe_rxstatus3,                                      --                                        .rxstatus3
			hip_pipe_rxstatus4                                      => CONNECTED_TO_hip_pipe_rxstatus4,                                      --                                        .rxstatus4
			hip_pipe_rxstatus5                                      => CONNECTED_TO_hip_pipe_rxstatus5,                                      --                                        .rxstatus5
			hip_pipe_rxstatus6                                      => CONNECTED_TO_hip_pipe_rxstatus6,                                      --                                        .rxstatus6
			hip_pipe_rxstatus7                                      => CONNECTED_TO_hip_pipe_rxstatus7,                                      --                                        .rxstatus7
			hip_pipe_rxvalid0                                       => CONNECTED_TO_hip_pipe_rxvalid0,                                       --                                        .rxvalid0
			hip_pipe_rxvalid1                                       => CONNECTED_TO_hip_pipe_rxvalid1,                                       --                                        .rxvalid1
			hip_pipe_rxvalid2                                       => CONNECTED_TO_hip_pipe_rxvalid2,                                       --                                        .rxvalid2
			hip_pipe_rxvalid3                                       => CONNECTED_TO_hip_pipe_rxvalid3,                                       --                                        .rxvalid3
			hip_pipe_rxvalid4                                       => CONNECTED_TO_hip_pipe_rxvalid4,                                       --                                        .rxvalid4
			hip_pipe_rxvalid5                                       => CONNECTED_TO_hip_pipe_rxvalid5,                                       --                                        .rxvalid5
			hip_pipe_rxvalid6                                       => CONNECTED_TO_hip_pipe_rxvalid6,                                       --                                        .rxvalid6
			hip_pipe_rxvalid7                                       => CONNECTED_TO_hip_pipe_rxvalid7,                                       --                                        .rxvalid7
			hip_serial_rx_in0                                       => CONNECTED_TO_hip_serial_rx_in0,                                       --                              hip_serial.rx_in0
			hip_serial_rx_in1                                       => CONNECTED_TO_hip_serial_rx_in1,                                       --                                        .rx_in1
			hip_serial_rx_in2                                       => CONNECTED_TO_hip_serial_rx_in2,                                       --                                        .rx_in2
			hip_serial_rx_in3                                       => CONNECTED_TO_hip_serial_rx_in3,                                       --                                        .rx_in3
			hip_serial_rx_in4                                       => CONNECTED_TO_hip_serial_rx_in4,                                       --                                        .rx_in4
			hip_serial_rx_in5                                       => CONNECTED_TO_hip_serial_rx_in5,                                       --                                        .rx_in5
			hip_serial_rx_in6                                       => CONNECTED_TO_hip_serial_rx_in6,                                       --                                        .rx_in6
			hip_serial_rx_in7                                       => CONNECTED_TO_hip_serial_rx_in7,                                       --                                        .rx_in7
			hip_serial_tx_out0                                      => CONNECTED_TO_hip_serial_tx_out0,                                      --                                        .tx_out0
			hip_serial_tx_out1                                      => CONNECTED_TO_hip_serial_tx_out1,                                      --                                        .tx_out1
			hip_serial_tx_out2                                      => CONNECTED_TO_hip_serial_tx_out2,                                      --                                        .tx_out2
			hip_serial_tx_out3                                      => CONNECTED_TO_hip_serial_tx_out3,                                      --                                        .tx_out3
			hip_serial_tx_out4                                      => CONNECTED_TO_hip_serial_tx_out4,                                      --                                        .tx_out4
			hip_serial_tx_out5                                      => CONNECTED_TO_hip_serial_tx_out5,                                      --                                        .tx_out5
			hip_serial_tx_out6                                      => CONNECTED_TO_hip_serial_tx_out6,                                      --                                        .tx_out6
			hip_serial_tx_out7                                      => CONNECTED_TO_hip_serial_tx_out7,                                      --                                        .tx_out7
			mem_if_ddr3a_mem_mem_a                                  => CONNECTED_TO_mem_if_ddr3a_mem_mem_a,                                  --                        mem_if_ddr3a_mem.mem_a
			mem_if_ddr3a_mem_mem_ba                                 => CONNECTED_TO_mem_if_ddr3a_mem_mem_ba,                                 --                                        .mem_ba
			mem_if_ddr3a_mem_mem_ck                                 => CONNECTED_TO_mem_if_ddr3a_mem_mem_ck,                                 --                                        .mem_ck
			mem_if_ddr3a_mem_mem_ck_n                               => CONNECTED_TO_mem_if_ddr3a_mem_mem_ck_n,                               --                                        .mem_ck_n
			mem_if_ddr3a_mem_mem_cke                                => CONNECTED_TO_mem_if_ddr3a_mem_mem_cke,                                --                                        .mem_cke
			mem_if_ddr3a_mem_mem_cs_n                               => CONNECTED_TO_mem_if_ddr3a_mem_mem_cs_n,                               --                                        .mem_cs_n
			mem_if_ddr3a_mem_mem_dm                                 => CONNECTED_TO_mem_if_ddr3a_mem_mem_dm,                                 --                                        .mem_dm
			mem_if_ddr3a_mem_mem_ras_n                              => CONNECTED_TO_mem_if_ddr3a_mem_mem_ras_n,                              --                                        .mem_ras_n
			mem_if_ddr3a_mem_mem_cas_n                              => CONNECTED_TO_mem_if_ddr3a_mem_mem_cas_n,                              --                                        .mem_cas_n
			mem_if_ddr3a_mem_mem_we_n                               => CONNECTED_TO_mem_if_ddr3a_mem_mem_we_n,                               --                                        .mem_we_n
			mem_if_ddr3a_mem_mem_reset_n                            => CONNECTED_TO_mem_if_ddr3a_mem_mem_reset_n,                            --                                        .mem_reset_n
			mem_if_ddr3a_mem_mem_dq                                 => CONNECTED_TO_mem_if_ddr3a_mem_mem_dq,                                 --                                        .mem_dq
			mem_if_ddr3a_mem_mem_dqs                                => CONNECTED_TO_mem_if_ddr3a_mem_mem_dqs,                                --                                        .mem_dqs
			mem_if_ddr3a_mem_mem_dqs_n                              => CONNECTED_TO_mem_if_ddr3a_mem_mem_dqs_n,                              --                                        .mem_dqs_n
			mem_if_ddr3a_mem_mem_odt                                => CONNECTED_TO_mem_if_ddr3a_mem_mem_odt,                                --                                        .mem_odt
			mem_if_ddr3a_oct_rzqin                                  => CONNECTED_TO_mem_if_ddr3a_oct_rzqin,                                  --                        mem_if_ddr3a_oct.rzqin
			mem_if_ddr3a_pll_ref_clk_clk                            => CONNECTED_TO_mem_if_ddr3a_pll_ref_clk_clk,                            --                mem_if_ddr3a_pll_ref_clk.clk
			mem_if_ddr3a_status_local_init_done                     => CONNECTED_TO_mem_if_ddr3a_status_local_init_done,                     --                     mem_if_ddr3a_status.local_init_done
			mem_if_ddr3a_status_local_cal_success                   => CONNECTED_TO_mem_if_ddr3a_status_local_cal_success,                   --                                        .local_cal_success
			mem_if_ddr3a_status_local_cal_fail                      => CONNECTED_TO_mem_if_ddr3a_status_local_cal_fail,                      --                                        .local_cal_fail
			mem_if_ddr3b_mem_mem_a                                  => CONNECTED_TO_mem_if_ddr3b_mem_mem_a,                                  --                        mem_if_ddr3b_mem.mem_a
			mem_if_ddr3b_mem_mem_ba                                 => CONNECTED_TO_mem_if_ddr3b_mem_mem_ba,                                 --                                        .mem_ba
			mem_if_ddr3b_mem_mem_ck                                 => CONNECTED_TO_mem_if_ddr3b_mem_mem_ck,                                 --                                        .mem_ck
			mem_if_ddr3b_mem_mem_ck_n                               => CONNECTED_TO_mem_if_ddr3b_mem_mem_ck_n,                               --                                        .mem_ck_n
			mem_if_ddr3b_mem_mem_cke                                => CONNECTED_TO_mem_if_ddr3b_mem_mem_cke,                                --                                        .mem_cke
			mem_if_ddr3b_mem_mem_cs_n                               => CONNECTED_TO_mem_if_ddr3b_mem_mem_cs_n,                               --                                        .mem_cs_n
			mem_if_ddr3b_mem_mem_dm                                 => CONNECTED_TO_mem_if_ddr3b_mem_mem_dm,                                 --                                        .mem_dm
			mem_if_ddr3b_mem_mem_ras_n                              => CONNECTED_TO_mem_if_ddr3b_mem_mem_ras_n,                              --                                        .mem_ras_n
			mem_if_ddr3b_mem_mem_cas_n                              => CONNECTED_TO_mem_if_ddr3b_mem_mem_cas_n,                              --                                        .mem_cas_n
			mem_if_ddr3b_mem_mem_we_n                               => CONNECTED_TO_mem_if_ddr3b_mem_mem_we_n,                               --                                        .mem_we_n
			mem_if_ddr3b_mem_mem_reset_n                            => CONNECTED_TO_mem_if_ddr3b_mem_mem_reset_n,                            --                                        .mem_reset_n
			mem_if_ddr3b_mem_mem_dq                                 => CONNECTED_TO_mem_if_ddr3b_mem_mem_dq,                                 --                                        .mem_dq
			mem_if_ddr3b_mem_mem_dqs                                => CONNECTED_TO_mem_if_ddr3b_mem_mem_dqs,                                --                                        .mem_dqs
			mem_if_ddr3b_mem_mem_dqs_n                              => CONNECTED_TO_mem_if_ddr3b_mem_mem_dqs_n,                              --                                        .mem_dqs_n
			mem_if_ddr3b_mem_mem_odt                                => CONNECTED_TO_mem_if_ddr3b_mem_mem_odt,                                --                                        .mem_odt
			mem_if_ddr3b_oct_rzqin                                  => CONNECTED_TO_mem_if_ddr3b_oct_rzqin,                                  --                        mem_if_ddr3b_oct.rzqin
			mem_if_ddr3b_pll_ref_clk_clk                            => CONNECTED_TO_mem_if_ddr3b_pll_ref_clk_clk,                            --                mem_if_ddr3b_pll_ref_clk.clk
			mem_if_ddr3b_status_local_init_done                     => CONNECTED_TO_mem_if_ddr3b_status_local_init_done,                     --                     mem_if_ddr3b_status.local_init_done
			mem_if_ddr3b_status_local_cal_success                   => CONNECTED_TO_mem_if_ddr3b_status_local_cal_success,                   --                                        .local_cal_success
			mem_if_ddr3b_status_local_cal_fail                      => CONNECTED_TO_mem_if_ddr3b_status_local_cal_fail,                      --                                        .local_cal_fail
			pcie_256_hip_avmm_0_reconfig_clk_locked_fixedclk_locked => CONNECTED_TO_pcie_256_hip_avmm_0_reconfig_clk_locked_fixedclk_locked, -- pcie_256_hip_avmm_0_reconfig_clk_locked.fixedclk_locked
			pcie_rstn_npor                                          => CONNECTED_TO_pcie_rstn_npor,                                          --                               pcie_rstn.npor
			pcie_rstn_pin_perst                                     => CONNECTED_TO_pcie_rstn_pin_perst,                                     --                                        .pin_perst
			pio_button_external_connection_export                   => CONNECTED_TO_pio_button_external_connection_export,                   --          pio_button_external_connection.export
			pio_led_external_connection_export                      => CONNECTED_TO_pio_led_external_connection_export,                      --             pio_led_external_connection.export
			refclk_clk                                              => CONNECTED_TO_refclk_clk,                                              --                                  refclk.clk
			reset_reset_n                                           => CONNECTED_TO_reset_reset_n                                            --                                   reset.reset_n
		);

