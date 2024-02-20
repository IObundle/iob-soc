
#get from command line arg
set LIBDIR /tria/apps/libs/arm/tsmc/cln16fpll001

set_db lib_search_path [list     $LIBDIR/sc9mc_base_svt_c18/r3p1/lib \
                                 $LIBDIR/sc9mc_base_svt_c18/r3p1/lef \
                                 $LIBDIR/arm_tech/r5p0/lef/9m_2xa1xd3xe2z_utrdl \
                               ]

set_db library {sc9mc_cln16fpll001_base_svt_c18_ssgnp_cworstccworstt_max_0p72v_m40c.lib sc9mc_cln16fpll001_base_svt_c18_ssgnp_cworstccworstt_max_0p72v_125c.lib}

set_db lef_library {sc9mcpp96c_tech.lef sc9mc_cln16fpll001_base_svt_c18.lef}

set_db cap_table_file "$LIBDIR/arm_tech/r5p0/cadence_captable/9m_2xa1xd3xe2z_utrdl/cln16ff+_9m_2xa1xd3xe2z_utrdl_rcworst.captbl"

set_db lib_lef_consistency_check_enable true 
set_db interconnect_mode ple
