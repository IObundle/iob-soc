quartus_map --read_settings_files=on --write_settings_files=off spi -c spi

quartus_cdb --read_settings_files=off --write_settings_files=off spi -c spi --merge=on

quartus_cdb spi -c spi --incremental_compilation_export=spi_master-spi_m.qxp --incremental_compilation_export_partition_name=spi_master:spi_m --incremental_compilation_export_post_synth=on --incremental_compilation_export_post_fit=off --incremental_compilation_export_routing=on --incremental_compilation_export_flatten=on

quartus_cdb spi -c spi --incremental_compilation_export=spi_slave-spi_s.qxp --incremental_compilation_export_partition_name=spi_slave:spi_s --incremental_compilation_export_post_synth=on --incremental_compilation_export_post_fit=off --incremental_compilation_export_routing=on --incremental_compilation_export_flatten=on

cp spi_master-spi_m.qxp ../../../../../iob-2es-mp3-e/hardware/cyclone_v_gt/netlists/
cp spi_slave-spi_s.qxp ../../../../../iob-2es-mp3-e/hardware/cyclone_v_gt/netlists/

quartus_sh --clean spi

rm *.qarlog

rm -rf db


