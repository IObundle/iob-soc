
#get from command line arg
set LIBDIR /tria/apps/libs/arm/tsmc/cln07ff41001

set_db lib_search_path [list     $LIBDIR/sch240mc_base_svt_c11/r12p0/lib     \
                                 $LIBDIR/sch240mc_base_svt_c11/r12p0/lef     \
                                 $LIBDIR/arm_tech/r5p2/lef/1p13m_1x1xa1ya5y2yy2z \
                               ]

set_db library {sch240mc_cln07ff41001_base_svt_c11_ssgnp_cworstccworstt_max_0p765v_m40c.lib sch240mc_cln07ff41001_base_svt_c11_ssgnp_cworstccworstt_max_0p765v_125c.lib}

set_db lef_library {sch240mc_tech.lef sch240mc_cln07ff41001_base_svt_c11.lef}

#set_db cap_table_file "$LIBDIR/arm_tech/r5p2/lef/1p13m_1x1xa1ya5y2yy2z/sch240mc_tech.lef"

set_db lib_lef_consistency_check_enable true 
set_db interconnect_mode ple

