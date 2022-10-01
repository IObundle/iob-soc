	S5_DDR3_QSYS u0 (
		.clk_clk                                   (<connected-to-clk_clk>),                                   //                             clk.clk
		.reset_reset_n                             (<connected-to-reset_reset_n>),                             //                           reset.reset_n
		.memory_mem_a                              (<connected-to-memory_mem_a>),                              //                          memory.mem_a
		.memory_mem_ba                             (<connected-to-memory_mem_ba>),                             //                                .mem_ba
		.memory_mem_ck                             (<connected-to-memory_mem_ck>),                             //                                .mem_ck
		.memory_mem_ck_n                           (<connected-to-memory_mem_ck_n>),                           //                                .mem_ck_n
		.memory_mem_cke                            (<connected-to-memory_mem_cke>),                            //                                .mem_cke
		.memory_mem_cs_n                           (<connected-to-memory_mem_cs_n>),                           //                                .mem_cs_n
		.memory_mem_dm                             (<connected-to-memory_mem_dm>),                             //                                .mem_dm
		.memory_mem_ras_n                          (<connected-to-memory_mem_ras_n>),                          //                                .mem_ras_n
		.memory_mem_cas_n                          (<connected-to-memory_mem_cas_n>),                          //                                .mem_cas_n
		.memory_mem_we_n                           (<connected-to-memory_mem_we_n>),                           //                                .mem_we_n
		.memory_mem_reset_n                        (<connected-to-memory_mem_reset_n>),                        //                                .mem_reset_n
		.memory_mem_dq                             (<connected-to-memory_mem_dq>),                             //                                .mem_dq
		.memory_mem_dqs                            (<connected-to-memory_mem_dqs>),                            //                                .mem_dqs
		.memory_mem_dqs_n                          (<connected-to-memory_mem_dqs_n>),                          //                                .mem_dqs_n
		.memory_mem_odt                            (<connected-to-memory_mem_odt>),                            //                                .mem_odt
		.oct_rzqin                                 (<connected-to-oct_rzqin>),                                 //                             oct.rzqin
		.mem_if_ddr3_emif_status_local_init_done   (<connected-to-mem_if_ddr3_emif_status_local_init_done>),   //         mem_if_ddr3_emif_status.local_init_done
		.mem_if_ddr3_emif_status_local_cal_success (<connected-to-mem_if_ddr3_emif_status_local_cal_success>), //                                .local_cal_success
		.mem_if_ddr3_emif_status_local_cal_fail    (<connected-to-mem_if_ddr3_emif_status_local_cal_fail>),    //                                .local_cal_fail
		.button_external_connection_export         (<connected-to-button_external_connection_export>),         //      button_external_connection.export
		.ddr3_status_external_connection_export    (<connected-to-ddr3_status_external_connection_export>)     // ddr3_status_external_connection.export
	);

