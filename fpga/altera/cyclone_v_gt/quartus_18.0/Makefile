VSRC := \
../../../../rtl/src/simpleuart.v

INCLUDE := \
../../../../rtl/include/iob_uart_defs.vh\

all: $(VSRC) $(INCLUDE) iob_eth-iob_uart.qxp

iob_eth-iob_uart.qxp: top
	quartus_cdb iob_eth -c iob_eth --incremental_compilation_export=iob_eth.qxp --incremental_compilation_export_partition_name=Top --incremental_compilation_export_post_synth=on --incremental_compilation_export_post_fit=off --incremental_compilation_export_routing=on --incremental_compilation_export_flatten=on
	cp iob_eth.qxp ../../../../../iob-2es-mp3-e/hardware/cyclone_v_gt/netlists/

top:
	quartus_map --read_settings_files=on --write_settings_files=off iob_eth -c iob_eth
	quartus_cdb --read_settings_files=off --write_settings_files=off iob_eth -c iob_eth --merge=on

clean: 
	quartus_sh --clean iob_eth
	@rm -f *.qarlog *.qws *.qxp *~
	@rm -rf db incremental_db output_files

.PHONY: all top clean
