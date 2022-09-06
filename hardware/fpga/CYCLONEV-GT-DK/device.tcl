#
# SYNTHESIS AND IMPLEMENTATION SCRIPT
#

set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CGTFD9E5F35C7
set_global_assignment -name IOBANK_VCCIO 1.5V -section_id 4A

# Pin & Location Assignments
# ==========================

#System 

#DDR PLL ref clock 100MHz
#set_location_assignment PIN_H19 -to clk100
#set_instance_assignment -name IO_STANDARD LVDS -to clk100

#User clock 50MHz
#set_location_assignment PIN_V28 -to clk50
#set_instance_assignment -name IO_STANDARD "1.5 V" -to clk50
set_location_assignment PIN_V28 -to clk
set_instance_assignment -name IO_STANDARD "1.5 V" -to clk

#User reset
set_location_assignment PIN_AD29 -to resetn
set_instance_assignment -name IO_STANDARD "1.8 V" -to resetn


#Leds
#set_location_assignment  PIN_AM23 -to led
#set_instance_assignment -name IO_STANDARD "2.5-V" -to led

set_location_assignment  PIN_AE25 -to trap
set_instance_assignment -name IO_STANDARD "1.5-V" -to trap

set_instance_assignment -name SLEW_RATE 1 -to trap
set_instance_assignment -name CURRENT_STRENGTH_NEW DEFAULT -to trap

#Uart
set_location_assignment PIN_F10 -to uart_txd
set_instance_assignment -name IO_STANDARD "2.5-V" -to uart_txd
#set_instance_assignment -name SLEW_RATE 1 -to uart_txd
#set_instance_assignment -name CURRENT_STRENGTH_NEW DEFAULT -to uart_txd
set_location_assignment PIN_C12 -to uart_rxd
set_instance_assignment -name IO_STANDARD "2.5-V" -to uart_rxd


if { $USE_DDR >= 0 }  {

    #set_instance_assignment -name IO_STANDARD "1.5-V" -to rzqin
    #set_instance_assignment -name IO_STANDARD "1.5 V" -to rzqin_1_5v

    #DDR3 A
    # set_location_assignment PIN_AA16 -to ddr3a_csn
    # set_location_assignment PIN_AJ22 -to ddr3a_resetn
    # set_location_assignment PIN_AA18 -to ddr3a_clk_p
    # set_location_assignment PIN_AA17 -to ddr3a_clk_n
    # set_location_assignment PIN_AN12 -to ddr3a_wen
    # set_location_assignment PIN_AP14 -to ddr3a_rasn
    # set_location_assignment PIN_AP15 -to ddr3a_casn
    # set_location_assignment PIN_AP26 -to ddr3a_cke
    # set_location_assignment PIN_AN21 -to ddr3a_odt

    # set_location_assignment PIN_AK18 -to ddr3a_a[0]
    # set_location_assignment PIN_AL18 -to ddr3a_a[1]
    # set_location_assignment PIN_AM18 -to ddr3a_a[2]
    # set_location_assignment PIN_AN18 -to ddr3a_a[3]
    # set_location_assignment PIN_AH17 -to ddr3a_a[4]
    # set_location_assignment PIN_AJ17 -to ddr3a_a[5]
    # set_location_assignment PIN_AK17 -to ddr3a_a[6]
    # set_location_assignment PIN_AL17 -to ddr3a_a[7]
    # set_location_assignment PIN_AH16 -to ddr3a_a[8]
    # set_location_assignment PIN_AJ16 -to ddr3a_a[9]
    # set_location_assignment PIN_AL16 -to ddr3a_a[10]
    # set_location_assignment PIN_AM16 -to ddr3a_a[11]
    # set_location_assignment PIN_AM13 -to ddr3a_a[12]
    # set_location_assignment PIN_AN13 -to ddr3a_a[13]
    # set_location_assignment PIN_AN16 -to ddr3a_ba[0]
    # set_location_assignment PIN_AN17 -to ddr3a_ba[1]
    # set_location_assignment PIN_AP17 -to ddr3a_ba[2]

    # set_location_assignment PIN_AN19 -to ddr3a_dq[0]
    # set_location_assignment PIN_AM19 -to ddr3a_dq[1]
    # set_location_assignment PIN_AP20 -to ddr3a_dq[2]
    # set_location_assignment PIN_AP21 -to ddr3a_dq[3]
    # set_location_assignment PIN_AH19 -to ddr3a_dq[4]
    # set_location_assignment PIN_AG19 -to ddr3a_dq[5]
    # set_location_assignment PIN_AJ19 -to ddr3a_dq[6]
    # set_location_assignment PIN_AM21 -to ddr3a_dq[7]
    # set_location_assignment PIN_AM20 -to ddr3a_dq[8]
    # set_location_assignment PIN_AL20 -to ddr3a_dq[9]
    # set_location_assignment PIN_AN22 -to ddr3a_dq[10]
    # set_location_assignment PIN_AN23 -to ddr3a_dq[11]
    # set_location_assignment PIN_AP24 -to ddr3a_dq[12]
    # set_location_assignment PIN_AP25 -to ddr3a_dq[13]
    # set_location_assignment PIN_AN26 -to ddr3a_dq[14]
    # set_location_assignment PIN_AN24 -to ddr3a_dq[15]
    # # set_location_assignment PIN_AP27 -to ddr3a_dq[16]
    # # set_location_assignment PIN_AN27 -to ddr3a_dq[17]
    # # set_location_assignment PIN_AK22 -to ddr3a_dq[18]
    # # set_location_assignment PIN_AJ21 -to ddr3a_dq[19]
    # # set_location_assignment PIN_AH21 -to ddr3a_dq[20]
    # # set_location_assignment PIN_AH22 -to ddr3a_dq[21]
    # # set_location_assignment PIN_AP30 -to ddr3a_dq[22]
    # # set_location_assignment PIN_AN28 -to ddr3a_dq[23]
    # # set_location_assignment PIN_AL23 -to ddr3a_dq[24]
    # # set_location_assignment PIN_AK23 -to ddr3a_dq[25]
    # # set_location_assignment PIN_AL25 -to ddr3a_dq[26]
    # # set_location_assignment PIN_AM26 -to ddr3a_dq[27]
    # # set_location_assignment PIN_AK24 -to ddr3a_dq[28]
    # # set_location_assignment PIN_AJ24 -to ddr3a_dq[29]
    # # set_location_assignment PIN_AN31 -to ddr3a_dq[30]
    # # set_location_assignment PIN_AL28 -to ddr3a_dq[31]
    # # set_location_assignment PIN_AH23 -to ddr3a_dq[32]
    # # set_location_assignment PIN_AG23 -to ddr3a_dq[33]
    # # set_location_assignment PIN_AN32 -to ddr3a_dq[34]
    # # set_location_assignment PIN_AN29 -to ddr3a_dq[35]
    # # set_location_assignment PIN_AK25 -to ddr3a_dq[36]
    # # set_location_assignment PIN_AJ25 -to ddr3a_dq[37]
    # # set_location_assignment PIN_AK28 -to ddr3a_dq[38]
    # # set_location_assignment PIN_AM30 -to ddr3a_dq[39]

    # set_location_assignment PIN_AL21 -to ddr3a_dm[0]
    # set_location_assignment PIN_AM24 -to ddr3a_dm[1]
    # # set_location_assignment PIN_AM28 -to ddr3a_dm[2]
    # # set_location_assignment PIN_AL27 -to ddr3a_dm[3]
    # # set_location_assignment PIN_AL30 -to ddr3a_dm[4]

    # set_location_assignment PIN_AB19 -to ddr3a_dqs_p[0]
    # set_location_assignment PIN_AD19 -to ddr3a_dqs_p[1]
    # # set_location_assignment PIN_AJ20 -to ddr3a_dqs_p[2]
    # # set_location_assignment PIN_Y20 -to ddr3a_dqs_p[3]
    # # set_location_assignment PIN_AC21 -to ddr3a_dqs_p[4]

    # set_location_assignment PIN_AC19 -to ddr3a_dqs_n[0]
    # set_location_assignment PIN_AE19 -to ddr3a_dqs_n[1]
    # # set_location_assignment PIN_AK20 -to ddr3a_dqs_n[2]
    # # set_location_assignment PIN_AA20 -to ddr3a_dqs_n[3]
    # # set_location_assignment PIN_AD21 -to ddr3a_dqs_n[4]


    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_csn
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_resetn
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_clk_p
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_clk_n
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_cke
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_wen
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_rasn
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_casn
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_odt

    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[0]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[1]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[2]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[3]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[4]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[5]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[6]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[7]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[8]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[9]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[10]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[11]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[12]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_a[13]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_ba[0]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_ba[1]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_ba[2]

    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[0]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[1]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[2]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[3]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[4]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[5]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[6]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[7]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[8]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[9]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[10]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[11]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[12]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[13]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[14]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[15]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[16]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[17]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[18]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[19]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[20]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[21]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[22]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[23]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[24]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[25]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[26]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[27]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[28]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[29]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[30]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[31]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[32]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[33]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[34]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[35]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[36]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[37]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[38]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dq[39]

    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dm[0]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dm[1]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dm[2]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dm[3]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dm[4]

    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_p[0]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_p[1]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_p[2]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_p[3]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_p[4]

    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_n[0]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_n[1]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_n[2]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_n[3]
    # # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3a_dqs_n[4]


    #DDR B

    set_location_assignment PIN_V27 -to ddr3b_csn
    set_location_assignment PIN_R29 -to ddr3b_clk_n
    set_location_assignment PIN_R30 -to ddr3b_clk_p
    set_location_assignment PIN_AF32 -to ddr3b_cke
    set_location_assignment PIN_AG31 -to ddr3b_resetn
    set_location_assignment PIN_AA32 -to ddr3b_odt
    set_location_assignment PIN_Y32 -to ddr3b_rasn
    set_location_assignment PIN_N27 -to ddr3b_casn
    set_location_assignment PIN_AM34 -to ddr3b_wen

    set_location_assignment PIN_H29 -to ddr3b_a[0]
    set_location_assignment PIN_K28 -to ddr3b_a[1]
    set_location_assignment PIN_K34 -to ddr3b_a[2]
    set_location_assignment PIN_L32 -to ddr3b_a[3]
    set_location_assignment PIN_R32 -to ddr3b_a[4]
    set_location_assignment PIN_R33 -to ddr3b_a[5]
    set_location_assignment PIN_N32 -to ddr3b_a[6]
    set_location_assignment PIN_G33 -to ddr3b_a[7]
    set_location_assignment PIN_AE34 -to ddr3b_a[8]
    set_location_assignment PIN_L27 -to ddr3b_a[9]
    set_location_assignment PIN_V33 -to ddr3b_a[10]
    set_location_assignment PIN_U33 -to ddr3b_a[11]
    set_location_assignment PIN_T31 -to ddr3b_a[12]
    set_location_assignment PIN_T30 -to ddr3b_a[13]
    set_location_assignment PIN_J31 -to ddr3b_ba[0]
    set_location_assignment PIN_N29 -to ddr3b_ba[1]
    set_location_assignment PIN_P27 -to ddr3b_ba[2]

    set_location_assignment PIN_AF31 -to ddr3b_dq[0]
    set_location_assignment PIN_AD30 -to ddr3b_dq[1]
    set_location_assignment PIN_AJ32 -to ddr3b_dq[2]
    set_location_assignment PIN_AC31 -to ddr3b_dq[3]
    set_location_assignment PIN_AH32 -to ddr3b_dq[4]
    set_location_assignment PIN_Y28 -to ddr3b_dq[5]
    set_location_assignment PIN_AN34 -to ddr3b_dq[6]
    set_location_assignment PIN_Y27 -to ddr3b_dq[7]
    set_location_assignment PIN_AD32 -to ddr3b_dq[8]
    set_location_assignment PIN_AH33 -to ddr3b_dq[9]
    set_location_assignment PIN_AB31 -to ddr3b_dq[10]
    set_location_assignment PIN_AJ34 -to ddr3b_dq[11]
    set_location_assignment PIN_AA31 -to ddr3b_dq[12]
    set_location_assignment PIN_AK34 -to ddr3b_dq[13]
    set_location_assignment PIN_W31 -to ddr3b_dq[14]
    set_location_assignment PIN_AG33 -to ddr3b_dq[15]
    # set_location_assignment PIN_AD34 -to ddr3b_dq[16]
    # set_location_assignment PIN_AC33 -to ddr3b_dq[17]
    # set_location_assignment PIN_AG34 -to ddr3b_dq[18]
    # set_location_assignment PIN_AB33 -to ddr3b_dq[19]
    # set_location_assignment PIN_AE33 -to ddr3b_dq[20]
    # set_location_assignment PIN_V32 -to ddr3b_dq[21]
    # set_location_assignment PIN_AH34 -to ddr3b_dq[22]
    # set_location_assignment PIN_W32 -to ddr3b_dq[23]
    # set_location_assignment PIN_U29 -to ddr3b_dq[24]
    # set_location_assignment PIN_V34 -to ddr3b_dq[25]
    # set_location_assignment PIN_U34 -to ddr3b_dq[26]
    # set_location_assignment PIN_AA33 -to ddr3b_dq[27]
    # set_location_assignment PIN_R34 -to ddr3b_dq[28]
    # set_location_assignment PIN_Y33 -to ddr3b_dq[29]
    # set_location_assignment PIN_P34 -to ddr3b_dq[30]
    # set_location_assignment PIN_U28 -to ddr3b_dq[31]
    # set_location_assignment PIN_T32 -to ddr3b_dq[32]
    # set_location_assignment PIN_N33 -to ddr3b_dq[33]
    # set_location_assignment PIN_T33 -to ddr3b_dq[34]
    # set_location_assignment PIN_L33 -to ddr3b_dq[35]
    # set_location_assignment PIN_T28 -to ddr3b_dq[36]
    # set_location_assignment PIN_J34 -to ddr3b_dq[37]
    # set_location_assignment PIN_T27 -to ddr3b_dq[38]
    # set_location_assignment PIN_M34 -to ddr3b_dq[39]
    # set_location_assignment PIN_K33 -to ddr3b_dq[40]
    # set_location_assignment PIN_N31 -to ddr3b_dq[41]
    # set_location_assignment PIN_G34 -to ddr3b_dq[42]
    # set_location_assignment PIN_R28 -to ddr3b_dq[43]
    # set_location_assignment PIN_H33 -to ddr3b_dq[44]
    # set_location_assignment PIN_P32 -to ddr3b_dq[45]
    # set_location_assignment PIN_H34 -to ddr3b_dq[46]
    # set_location_assignment PIN_R27 -to ddr3b_dq[47]
    # set_location_assignment PIN_N28 -to ddr3b_dq[48]
    # set_location_assignment PIN_L30 -to ddr3b_dq[49]
    # set_location_assignment PIN_P30 -to ddr3b_dq[50]
    # set_location_assignment PIN_K30 -to ddr3b_dq[51]
    # set_location_assignment PIN_J32 -to ddr3b_dq[52]
    # set_location_assignment PIN_H32 -to ddr3b_dq[53]
    # set_location_assignment PIN_M31 -to ddr3b_dq[54]
    # set_location_assignment PIN_H31 -to ddr3b_dq[55]
    # set_location_assignment PIN_G30 -to ddr3b_dq[56]
    # set_location_assignment PIN_K29 -to ddr3b_dq[57]
    # set_location_assignment PIN_G31 -to ddr3b_dq[58]
    # set_location_assignment PIN_M30 -to ddr3b_dq[59]
    # set_location_assignment PIN_J30 -to ddr3b_dq[60]
    # set_location_assignment PIN_M29 -to ddr3b_dq[61]
    # set_location_assignment PIN_J29 -to ddr3b_dq[62]
    # set_location_assignment PIN_L28 -to ddr3b_dq[63]


    set_location_assignment PIN_AE30 -to ddr3b_dm[0]
    set_location_assignment PIN_AE32 -to ddr3b_dm[1]
    # set_location_assignment PIN_AC34 -to ddr3b_dm[2]
    # set_location_assignment PIN_W34 -to ddr3b_dm[3]
    # set_location_assignment PIN_M33 -to ddr3b_dm[4]
    # set_location_assignment PIN_K32 -to ddr3b_dm[5]
    # set_location_assignment PIN_L31 -to ddr3b_dm[6]
    # set_location_assignment PIN_H28 -to ddr3b_dm[7]

    set_location_assignment PIN_Y29 -to ddr3b_dqs_p[0]
    set_location_assignment PIN_W29 -to ddr3b_dqs_p[1]
    # set_location_assignment PIN_V24 -to ddr3b_dqs_p[2]
    # set_location_assignment PIN_U24 -to ddr3b_dqs_p[3]
    # set_location_assignment PIN_U23 -to ddr3b_dqs_p[4]
    # set_location_assignment PIN_T25 -to ddr3b_dqs_p[5]
    # set_location_assignment PIN_R23 -to ddr3b_dqs_p[6]
    # set_location_assignment PIN_P24 -to ddr3b_dqs_p[7]
    set_location_assignment PIN_Y30 -to ddr3b_dqs_n[0]
    set_location_assignment PIN_W30 -to ddr3b_dqs_n[1]
    # set_location_assignment PIN_V23 -to ddr3b_dqs_n[2]
    # set_location_assignment PIN_U25 -to ddr3b_dqs_n[3]
    # set_location_assignment PIN_T23 -to ddr3b_dqs_n[4]
    # set_location_assignment PIN_R25 -to ddr3b_dqs_n[5]
    # set_location_assignment PIN_R24 -to ddr3b_dqs_n[6]
    # set_location_assignment PIN_P25 -to ddr3b_dqs_n[7]


    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_csn
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_resetn
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_clk_n
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_clk_p
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_cke
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_wen
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_rasn
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_casn
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_odt

    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[0]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[1]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[10]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[11]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[12]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[13]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[2]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[3]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[4]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[5]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[6]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[7]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[8]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_a[9]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_ba[0]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_ba[1]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_ba[2]


    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[0]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[1]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[2]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[3]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[4]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[5]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[6]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[7]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[8]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[9]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[10]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[11]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[12]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[13]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[14]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[15]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[16]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[17]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[18]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[19]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[20]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[21]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[22]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[23]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[24]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[25]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[26]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[27]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[28]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[29]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[30]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[31]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[32]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[33]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[34]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[35]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[36]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[37]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[38]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[39]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[40]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[41]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[42]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[43]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[44]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[45]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[46]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[47]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[48]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[49]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[50]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[51]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[52]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[53]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[54]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[55]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[56]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[57]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[58]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[59]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[60]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[61]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[62]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dq[63]

    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dm[0]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dm[1]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dm[2]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dm[3]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dm[4]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dm[5]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dm[6]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dm[7]

    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_p[0]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_p[1]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_p[2]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_p[3]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_p[4]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_p[5]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_p[6]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_p[7]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_n[0]
    set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_n[1]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_n[2]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_n[3]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_n[4]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_n[5]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_n[6]
    # set_instance_assignment -name IO_STANDARD "SSTL-15 CLASS I" -to ddr3b_dqs_n[7]
}
