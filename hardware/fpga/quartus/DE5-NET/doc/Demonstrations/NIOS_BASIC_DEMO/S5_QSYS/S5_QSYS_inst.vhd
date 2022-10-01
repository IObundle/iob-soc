	component S5_QSYS is
		port (
			clk_50                                    : in    std_logic                    := 'X';             -- clk
			in_port_to_the_button                     : in    std_logic_vector(3 downto 0) := (others => 'X'); -- export
			in_port_to_the_temp_int_n                 : in    std_logic                    := 'X';             -- export
			reset_n                                   : in    std_logic                    := 'X';             -- reset_n
			in_port_to_the_temp_overt_n               : in    std_logic                    := 'X';             -- export
			out_port_from_the_led                     : out   std_logic_vector(3 downto 0);                    -- export
			sw_external_connection_export             : in    std_logic_vector(3 downto 0) := (others => 'X'); -- export
			fan_external_connection_export            : out   std_logic;                                       -- export
			temp_scl_external_connection_export       : out   std_logic;                                       -- export
			temp_sda_external_connection_export       : inout std_logic                    := 'X';             -- export
			clk_i2c_scl_external_connection_export    : out   std_logic;                                       -- export
			clk_i2c_sda_external_connection_export    : inout std_logic                    := 'X';             -- export
			ref_clock_sata_count_clk_in_ref_export    : in    std_logic                    := 'X';             -- export
			ref_clock_sata_count_clk_in_target_export : in    std_logic                    := 'X';             -- export
			ref_clock_10g_count_clk_in_target_export  : in    std_logic                    := 'X';             -- export
			ref_clock_10g_count_clk_in_ref_export     : in    std_logic                    := 'X';             -- export
			cdcm_conduit_end_scl                      : out   std_logic;                                       -- scl
			cdcm_conduit_end_sda                      : inout std_logic                    := 'X'              -- sda
		);
	end component S5_QSYS;

	u0 : component S5_QSYS
		port map (
			clk_50                                    => CONNECTED_TO_clk_50,                                    --                      clk_50_clk_in.clk
			in_port_to_the_button                     => CONNECTED_TO_in_port_to_the_button,                     --         button_external_connection.export
			in_port_to_the_temp_int_n                 => CONNECTED_TO_in_port_to_the_temp_int_n,                 --     temp_int_n_external_connection.export
			reset_n                                   => CONNECTED_TO_reset_n,                                   --                clk_50_clk_in_reset.reset_n
			in_port_to_the_temp_overt_n               => CONNECTED_TO_in_port_to_the_temp_overt_n,               --   temp_overt_n_external_connection.export
			out_port_from_the_led                     => CONNECTED_TO_out_port_from_the_led,                     --            led_external_connection.export
			sw_external_connection_export             => CONNECTED_TO_sw_external_connection_export,             --             sw_external_connection.export
			fan_external_connection_export            => CONNECTED_TO_fan_external_connection_export,            --            fan_external_connection.export
			temp_scl_external_connection_export       => CONNECTED_TO_temp_scl_external_connection_export,       --       temp_scl_external_connection.export
			temp_sda_external_connection_export       => CONNECTED_TO_temp_sda_external_connection_export,       --       temp_sda_external_connection.export
			clk_i2c_scl_external_connection_export    => CONNECTED_TO_clk_i2c_scl_external_connection_export,    --    clk_i2c_scl_external_connection.export
			clk_i2c_sda_external_connection_export    => CONNECTED_TO_clk_i2c_sda_external_connection_export,    --    clk_i2c_sda_external_connection.export
			ref_clock_sata_count_clk_in_ref_export    => CONNECTED_TO_ref_clock_sata_count_clk_in_ref_export,    --    ref_clock_sata_count_clk_in_ref.export
			ref_clock_sata_count_clk_in_target_export => CONNECTED_TO_ref_clock_sata_count_clk_in_target_export, -- ref_clock_sata_count_clk_in_target.export
			ref_clock_10g_count_clk_in_target_export  => CONNECTED_TO_ref_clock_10g_count_clk_in_target_export,  --  ref_clock_10g_count_clk_in_target.export
			ref_clock_10g_count_clk_in_ref_export     => CONNECTED_TO_ref_clock_10g_count_clk_in_ref_export,     --     ref_clock_10g_count_clk_in_ref.export
			cdcm_conduit_end_scl                      => CONNECTED_TO_cdcm_conduit_end_scl,                      --                   cdcm_conduit_end.scl
			cdcm_conduit_end_sda                      => CONNECTED_TO_cdcm_conduit_end_sda                       --                                   .sda
		);

