
#get from command line arg
set LIBDIR /tria/apps/libs/arm/tsmc/cln28hpc 

set_db lib_search_path [list     $LIBDIR/sc9mcpp140_base_svt_c35/r0p0/lib     \
                                 $LIBDIR/sc9mcpp140_base_svt_c35/r0p0/lef     \
                                 $LIBDIR/arm_tech/r0p1/lef/1p10m_5x2y2z  \
                               ]

set_db library {sc9mcpp140_cln28hpc_base_svt_c35_ss_cworst_max_0p81v_m40c.lib sc9mcpp140_cln28hpc_base_svt_c35_ss_cworst_max_0p81v_125c.lib }

set_db lef_library {sc9mcpp140_tech.lef sc9mcpp140_tech_dfm.lef sc9mcpp140_cln28hpc_base_svt_c35.lef }

set_db cap_table_file "$LIBDIR/arm_tech/r0p1/cadence_captable/1p10m_5x2y2z/rcworst.captbl"

set_db lib_lef_consistency_check_enable true 
set_db interconnect_mode ple


