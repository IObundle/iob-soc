	component S5_PFL is
		port (
			sys_clk_clk                                     : in    std_logic                     := 'X';             -- clk
			cfi_flash_atb_bridge_0_out_tcm_address_out      : out   std_logic_vector(27 downto 0);                    -- tcm_address_out
			cfi_flash_atb_bridge_0_out_tcm_read_n_out       : out   std_logic_vector(0 downto 0);                     -- tcm_read_n_out
			cfi_flash_atb_bridge_0_out_tcm_write_n_out      : out   std_logic_vector(0 downto 0);                     -- tcm_write_n_out
			cfi_flash_atb_bridge_0_out_tcm_data_out         : inout std_logic_vector(31 downto 0) := (others => 'X'); -- tcm_data_out
			cfi_flash_atb_bridge_0_out_tcm_chipselect_n_out : out   std_logic_vector(0 downto 0);                     -- tcm_chipselect_n_out
			merged_resets_in_reset_reset_n                  : in    std_logic                     := 'X';             -- reset_n
			button_external_connection_export               : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			led_external_connection_export                  : out   std_logic_vector(3 downto 0);                     -- export
			hex1_external_connection_export                 : out   std_logic_vector(7 downto 0);                     -- export
			hex0_external_connection_export                 : out   std_logic_vector(7 downto 0);                     -- export
			temp_scl_external_connection_export             : out   std_logic;                                        -- export
			temp_sda_external_connection_export             : inout std_logic                     := 'X';             -- export
			led_rj45_external_connection_export             : out   std_logic_vector(1 downto 0);                     -- export
			led_bracket_external_connection_export          : out   std_logic_vector(3 downto 0)                      -- export
		);
	end component S5_PFL;

	u0 : component S5_PFL
		port map (
			sys_clk_clk                                     => CONNECTED_TO_sys_clk_clk,                                     --                         sys_clk.clk
			cfi_flash_atb_bridge_0_out_tcm_address_out      => CONNECTED_TO_cfi_flash_atb_bridge_0_out_tcm_address_out,      --      cfi_flash_atb_bridge_0_out.tcm_address_out
			cfi_flash_atb_bridge_0_out_tcm_read_n_out       => CONNECTED_TO_cfi_flash_atb_bridge_0_out_tcm_read_n_out,       --                                .tcm_read_n_out
			cfi_flash_atb_bridge_0_out_tcm_write_n_out      => CONNECTED_TO_cfi_flash_atb_bridge_0_out_tcm_write_n_out,      --                                .tcm_write_n_out
			cfi_flash_atb_bridge_0_out_tcm_data_out         => CONNECTED_TO_cfi_flash_atb_bridge_0_out_tcm_data_out,         --                                .tcm_data_out
			cfi_flash_atb_bridge_0_out_tcm_chipselect_n_out => CONNECTED_TO_cfi_flash_atb_bridge_0_out_tcm_chipselect_n_out, --                                .tcm_chipselect_n_out
			merged_resets_in_reset_reset_n                  => CONNECTED_TO_merged_resets_in_reset_reset_n,                  --          merged_resets_in_reset.reset_n
			button_external_connection_export               => CONNECTED_TO_button_external_connection_export,               --      button_external_connection.export
			led_external_connection_export                  => CONNECTED_TO_led_external_connection_export,                  --         led_external_connection.export
			hex1_external_connection_export                 => CONNECTED_TO_hex1_external_connection_export,                 --        hex1_external_connection.export
			hex0_external_connection_export                 => CONNECTED_TO_hex0_external_connection_export,                 --        hex0_external_connection.export
			temp_scl_external_connection_export             => CONNECTED_TO_temp_scl_external_connection_export,             --    temp_scl_external_connection.export
			temp_sda_external_connection_export             => CONNECTED_TO_temp_sda_external_connection_export,             --    temp_sda_external_connection.export
			led_rj45_external_connection_export             => CONNECTED_TO_led_rj45_external_connection_export,             --    led_rj45_external_connection.export
			led_bracket_external_connection_export          => CONNECTED_TO_led_bracket_external_connection_export           -- led_bracket_external_connection.export
		);

