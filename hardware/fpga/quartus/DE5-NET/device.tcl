#============================================================
# Build by Terasic System Builder
#============================================================

set FAMILY "Stratix V"
set DEVICE 5SGXEA7N2F45C2
# set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
# set_global_assignment -name DEVICE_FILTER_PIN_COUNT 1932
# set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 2_H2

#============================================================
# CLOCK
#============================================================
set_instance_assignment -name IO_STANDARD "2.5 V" -to clk     ; # OSC_50_B3B
# set_instance_assignment -name IO_STANDARD "1.8 V" -to OSC_50_B3D
# set_instance_assignment -name IO_STANDARD "1.8 V" -to OSC_50_B4A
# set_instance_assignment -name IO_STANDARD "1.8 V" -to OSC_50_B4D
# set_instance_assignment -name IO_STANDARD "1.5 V" -to OSC_50_B7A
# set_instance_assignment -name IO_STANDARD "1.5 V" -to OSC_50_B7D
# set_instance_assignment -name IO_STANDARD "1.5 V" -to OSC_50_B8A
# set_instance_assignment -name IO_STANDARD "1.8 V" -to OSC_50_B8D
set_location_assignment PIN_AW35 -to clk ; # OSC_50_B3B
# set_location_assignment PIN_BC28 -to OSC_50_B3D
# set_location_assignment PIN_AP10 -to OSC_50_B4A
# set_location_assignment PIN_AY18 -to OSC_50_B4D
# set_location_assignment PIN_M8 -to OSC_50_B7A
# set_location_assignment PIN_J18 -to OSC_50_B7D
# set_location_assignment PIN_R36 -to OSC_50_B8A
# set_location_assignment PIN_R25 -to OSC_50_B8D

#============================================================
# SMA
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to SMA_CLKIN
# set_instance_assignment -name IO_STANDARD "2.5 V" -to phy_clk_out_clk ; # SMA_CLKOUT
# set_location_assignment PIN_BB33 -to SMA_CLKIN
# set_location_assignment PIN_AV34 -to phy_clk_out_clk ; # SMA_CLKOUT
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to phy_clk_out_clk
# set_instance_assignment -name SLEW_RATE 1 -to phy_clk_out_clk ; # fast

#============================================================
# LED x 10
#============================================================
set_instance_assignment -name IO_STANDARD "2.5 V" -to led_board[0]   ; # LED[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to led_board[1]   ; # LED[1]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to led_board[2]   ; # LED[2]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to led_board[3]   ; # LED[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to led_bracket[0] ; # LED_BRACKET[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to led_bracket[1] ; # LED_BRACKET[1]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to led_bracket[2] ; # LED_BRACKET[2]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to led_bracket[3] ; # LED_BRACKET[3]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to led_rj45[0]    ; # LED_RJ45_L
# set_instance_assignment -name IO_STANDARD "2.5 V" -to led_rj45[1]    ; # LED_RJ45_R
set_location_assignment PIN_AW37 -to led_board[0]     ; # LED[0]
# set_location_assignment PIN_AV37 -to led_board[1]     ; # LED[1]
# set_location_assignment PIN_BB36 -to led_board[2]     ; # LED[2]
# set_location_assignment PIN_BB39 -to led_board[3]     ; # LED[3]
set_location_assignment PIN_AH15 -to led_bracket[0]   ; # LED_BRACKET[0]
# set_location_assignment PIN_AH13 -to led_bracket[1]   ; # LED_BRACKET[1]
# set_location_assignment PIN_AJ13 -to led_bracket[2]   ; # LED_BRACKET[2]
# set_location_assignment PIN_AJ14 -to led_bracket[3]   ; # LED_BRACKET[3]
# set_location_assignment PIN_AG15 -to led_rj45[0]      ; # LED_RJ45_L
# set_location_assignment PIN_AG16 -to led_rj45[1]      ; # LED_RJ45_R
set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_board[0]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_board[1]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_board[2]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_board[3]
set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_bracket[0]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_bracket[1]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_bracket[2]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_bracket[3]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_rj45[0]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to led_rj45[1]
set_instance_assignment -name SLEW_RATE 1 -to led_board[0]   ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to led_board[1]   ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to led_board[2]   ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to led_board[3]   ; # fast
set_instance_assignment -name SLEW_RATE 1 -to led_bracket[0] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to led_bracket[1] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to led_bracket[2] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to led_bracket[3] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to led_rj45[0]    ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to led_rj45[1]    ; # fast

#============================================================
# BUTTON x 4 and CPU_RESET_n
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to BUTTON[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to BUTTON[1]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to BUTTON[2]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to BUTTON[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to resetn ; # CPU_RESET_n
# set_location_assignment PIN_AK15 -to BUTTON[0]
# set_location_assignment PIN_AK14 -to BUTTON[1]
# set_location_assignment PIN_AL14 -to BUTTON[2]
# set_location_assignment PIN_AL15 -to BUTTON[3]
set_location_assignment PIN_BC37 -to resetn ; # CPU_RESET_n

#============================================================
# SWITCH x 4
#============================================================
# set_instance_assignment -name IO_STANDARD "1.8 V" -to SW[0]
# set_instance_assignment -name IO_STANDARD "1.8 V" -to SW[1]
# set_instance_assignment -name IO_STANDARD "1.8 V" -to SW[2]
# set_instance_assignment -name IO_STANDARD "1.8 V" -to SW[3]
# set_location_assignment PIN_B25 -to SW[0]
# set_location_assignment PIN_A25 -to SW[1]
# set_location_assignment PIN_B23 -to SW[2]
# set_location_assignment PIN_A23 -to SW[3]

#============================================================
# 7-Segement
#============================================================
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX0_DP
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX0_D[0]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX0_D[1]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX0_D[2]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX0_D[3]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX0_D[4]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX0_D[5]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX0_D[6]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX1_DP
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX1_D[0]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX1_D[1]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX1_D[2]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX1_D[3]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX1_D[4]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX1_D[5]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to HEX1_D[6]
# set_location_assignment PIN_P8 -to HEX0_DP
# set_location_assignment PIN_G8 -to HEX0_D[0]
# set_location_assignment PIN_H8 -to HEX0_D[1]
# set_location_assignment PIN_J9 -to HEX0_D[2]
# set_location_assignment PIN_K10 -to HEX0_D[3]
# set_location_assignment PIN_K8 -to HEX0_D[4]
# set_location_assignment PIN_K9 -to HEX0_D[5]
# set_location_assignment PIN_N8 -to HEX0_D[6]
# set_location_assignment PIN_E9 -to HEX1_DP
# set_location_assignment PIN_H18 -to HEX1_D[0]
# set_location_assignment PIN_G16 -to HEX1_D[1]
# set_location_assignment PIN_F16 -to HEX1_D[2]
# set_location_assignment PIN_A7 -to HEX1_D[3]
# set_location_assignment PIN_B7 -to HEX1_D[4]
# set_location_assignment PIN_C9 -to HEX1_D[5]
# set_location_assignment PIN_D10 -to HEX1_D[6]

#============================================================
# Temperature
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to TEMP_CLK
# set_instance_assignment -name IO_STANDARD "2.5 V" -to TEMP_DATA
# set_instance_assignment -name IO_STANDARD "2.5 V" -to TEMP_INT_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to TEMP_OVERT_n
# set_location_assignment PIN_D21 -to TEMP_CLK
# set_location_assignment PIN_D20 -to TEMP_DATA
# set_location_assignment PIN_C21 -to TEMP_INT_n
# set_location_assignment PIN_C22 -to TEMP_OVERT_n

#============================================================
# Fan
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to fan_fan ; # FAN_CTRL
# set_location_assignment PIN_AR32 -to fan_fan ; # FAN_CTRL
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to fan_fan
# set_instance_assignment -name SLEW_RATE 1 -to fan_fan ; # fast

#============================================================
# RS422
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to rs422_de      ; # RS422_DE
# set_instance_assignment -name IO_STANDARD "2.5 V" -to uart_rxd      ; # RS422_DIN
# set_instance_assignment -name IO_STANDARD "2.5 V" -to uart_txd      ; # RS422_DOUT
# set_instance_assignment -name IO_STANDARD "2.5 V" -to rs422_re_n    ; # RS422_RE_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to rs422_te      ; # RS422_TE
# set_location_assignment PIN_AG14 -to rs422_de                       ; # RS422_DE
# set_location_assignment PIN_AE18 -to uart_rxd                       ; # RS422_DIN
# set_location_assignment PIN_AE17 -to uart_txd                       ; # RS422_DOUT
# set_location_assignment PIN_AF17 -to rs422_re_n                     ; # RS422_RE_n
# set_location_assignment PIN_AF16 -to rs422_te                       ; # RS422_TE
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to rs422_de
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to uart_rxd
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to uart_txd
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to rs422_re_n
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to rs422_te
# set_instance_assignment -name SLEW_RATE 1 -to rs422_de     ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to uart_rxd     ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to uart_txd     ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to rs422_re_n   ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to rs422_te     ; # fast

#============================================================
# PCIe x 8
#============================================================
set_instance_assignment -name IO_STANDARD "2.5 V" -to pcie_reset_pin_perst_n ; # PCIE_PERST_n
set_instance_assignment -name IO_STANDARD "HCSL" -to pcie_refclk_clk ; # PCIE_REFCLK_p
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_rx_in0 ; # PCIE_RX_p[0]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_rx_in1 ; # PCIE_RX_p[1]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_rx_in2 ; # PCIE_RX_p[2]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_rx_in3 ; # PCIE_RX_p[3]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_rx_in4 ; # PCIE_RX_p[4]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_rx_in5 ; # PCIE_RX_p[5]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_rx_in6 ; # PCIE_RX_p[6]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_rx_in7 ; # PCIE_RX_p[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to PCIE_SMBCLK
set_instance_assignment -name IO_STANDARD "2.5 V" -to PCIE_SMBDAT
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_tx_out0 ; # PCIE_TX_p[0]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_tx_out1 ; # PCIE_TX_p[1]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_tx_out2 ; # PCIE_TX_p[2]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_tx_out3 ; # PCIE_TX_p[3]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_tx_out4 ; # PCIE_TX_p[4]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_tx_out5 ; # PCIE_TX_p[5]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_tx_out6 ; # PCIE_TX_p[6]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to pcie_serial_tx_out7 ; # PCIE_TX_p[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to PCIE_WAKE_n
set_location_assignment PIN_AU33 -to pcie_reset_pin_perst_n ; # PCIE_PERST_n
set_location_assignment PIN_AK38 -to pcie_refclk_clk ; # PCIE_REFCLK_p
set_location_assignment PIN_BB43 -to pcie_serial_rx_in0 ; # PCIE_RX_p[0]
set_location_assignment PIN_BA41 -to pcie_serial_rx_in1 ; # PCIE_RX_p[1]
set_location_assignment PIN_AW41 -to pcie_serial_rx_in2 ; # PCIE_RX_p[2]
set_location_assignment PIN_AY43 -to pcie_serial_rx_in3 ; # PCIE_RX_p[3]
set_location_assignment PIN_AT43 -to pcie_serial_rx_in4 ; # PCIE_RX_p[4]
set_location_assignment PIN_AP43 -to pcie_serial_rx_in5 ; # PCIE_RX_p[5]
set_location_assignment PIN_AM43 -to pcie_serial_rx_in6 ; # PCIE_RX_p[6]
set_location_assignment PIN_AK43 -to pcie_serial_rx_in7 ; # PCIE_RX_p[7]
set_location_assignment PIN_BD34 -to PCIE_SMBCLK
set_location_assignment PIN_AT33 -to PCIE_SMBDAT
set_location_assignment PIN_AY39 -to pcie_serial_tx_out0 ; # PCIE_TX_p[0]
set_location_assignment PIN_AV39 -to pcie_serial_tx_out1 ; # PCIE_TX_p[1]
set_location_assignment PIN_AT39 -to pcie_serial_tx_out2 ; # PCIE_TX_p[2]
set_location_assignment PIN_AU41 -to pcie_serial_tx_out3 ; # PCIE_TX_p[3]
set_location_assignment PIN_AN41 -to pcie_serial_tx_out4 ; # PCIE_TX_p[4]
set_location_assignment PIN_AL41 -to pcie_serial_tx_out5 ; # PCIE_TX_p[5]
set_location_assignment PIN_AJ41 -to pcie_serial_tx_out6 ; # PCIE_TX_p[6]
set_location_assignment PIN_AG41 -to pcie_serial_tx_out7 ; # PCIE_TX_p[7]
set_location_assignment PIN_BD35 -to PCIE_WAKE_n

#============================================================
# Flash/MAX Address/Data Share Bus
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[1]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[2]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[3]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[4]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[5]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[6]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[7]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[8]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[9]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[10]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[11]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[12]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[13]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[14]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[15]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[16]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[17]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[18]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[19]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[20]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[21]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[22]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[23]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[24]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[25]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_A[26]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[1]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[2]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[3]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[4]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[5]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[6]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[7]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[8]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[9]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[10]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[11]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[12]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[13]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[14]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[15]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[16]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[17]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[18]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[19]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[20]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[21]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[22]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[23]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[24]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[25]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[26]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[27]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[28]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[29]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[30]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FSM_D[31]
# set_location_assignment PIN_AU32 -to FSM_A[0]
# set_location_assignment PIN_AH30 -to FSM_A[1]
# set_location_assignment PIN_AJ30 -to FSM_A[2]
# set_location_assignment PIN_AH31 -to FSM_A[3]
# set_location_assignment PIN_AK30 -to FSM_A[4]
# set_location_assignment PIN_AJ32 -to FSM_A[5]
# set_location_assignment PIN_AG33 -to FSM_A[6]
# set_location_assignment PIN_AL30 -to FSM_A[7]
# set_location_assignment PIN_AK33 -to FSM_A[8]
# set_location_assignment PIN_AJ33 -to FSM_A[9]
# set_location_assignment PIN_AN30 -to FSM_A[10]
# set_location_assignment PIN_AH33 -to FSM_A[11]
# set_location_assignment PIN_AK32 -to FSM_A[12]
# set_location_assignment PIN_AM32 -to FSM_A[13]
# set_location_assignment PIN_AM31 -to FSM_A[14]
# set_location_assignment PIN_AL31 -to FSM_A[15]
# set_location_assignment PIN_AN33 -to FSM_A[16]
# set_location_assignment PIN_AP33 -to FSM_A[17]
# set_location_assignment PIN_AT32 -to FSM_A[18]
# set_location_assignment PIN_AT29 -to FSM_A[19]
# set_location_assignment PIN_AP31 -to FSM_A[20]
# set_location_assignment PIN_AR30 -to FSM_A[21]
# set_location_assignment PIN_AU30 -to FSM_A[22]
# set_location_assignment PIN_AJ31 -to FSM_A[23]
# set_location_assignment PIN_AP30 -to FSM_A[24]
# set_location_assignment PIN_AN31 -to FSM_A[25]
# set_location_assignment PIN_AT30 -to FSM_A[26]
# set_location_assignment PIN_AG26 -to FSM_D[0]
# set_location_assignment PIN_AD33 -to FSM_D[1]
# set_location_assignment PIN_AE34 -to FSM_D[2]
# set_location_assignment PIN_AF31 -to FSM_D[3]
# set_location_assignment PIN_AG28 -to FSM_D[4]
# set_location_assignment PIN_AG30 -to FSM_D[5]
# set_location_assignment PIN_AF29 -to FSM_D[6]
# set_location_assignment PIN_AE29 -to FSM_D[7]
# set_location_assignment PIN_AG25 -to FSM_D[8]
# set_location_assignment PIN_AF34 -to FSM_D[9]
# set_location_assignment PIN_AE33 -to FSM_D[10]
# set_location_assignment PIN_AE31 -to FSM_D[11]
# set_location_assignment PIN_AF28 -to FSM_D[12]
# set_location_assignment PIN_AE30 -to FSM_D[13]
# set_location_assignment PIN_AG29 -to FSM_D[14]
# set_location_assignment PIN_AG27 -to FSM_D[15]
# set_location_assignment PIN_AP28 -to FSM_D[16]
# set_location_assignment PIN_AN28 -to FSM_D[17]
# set_location_assignment PIN_AU31 -to FSM_D[18]
# set_location_assignment PIN_AW32 -to FSM_D[19]
# set_location_assignment PIN_BD32 -to FSM_D[20]
# set_location_assignment PIN_AY31 -to FSM_D[21]
# set_location_assignment PIN_BA30 -to FSM_D[22]
# set_location_assignment PIN_BB30 -to FSM_D[23]
# set_location_assignment PIN_AM29 -to FSM_D[24]
# set_location_assignment PIN_AR29 -to FSM_D[25]
# set_location_assignment PIN_AV31 -to FSM_D[26]
# set_location_assignment PIN_AV32 -to FSM_D[27]
# set_location_assignment PIN_BC31 -to FSM_D[28]
# set_location_assignment PIN_AW30 -to FSM_D[29]
# set_location_assignment PIN_BC32 -to FSM_D[30]
# set_location_assignment PIN_BD31 -to FSM_D[31]

#============================================================
# Flash Control
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_ADV_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_CE_n[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_CE_n[1]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_CLK
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_OE_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_RDY_BSY_n[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_RDY_BSY_n[1]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_RESET_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to FLASH_WE_n
# set_location_assignment PIN_AK29 -to FLASH_ADV_n
# set_location_assignment PIN_AE27 -to FLASH_CE_n[0]
# set_location_assignment PIN_BA31 -to FLASH_CE_n[1]
# set_location_assignment PIN_AL29 -to FLASH_CLK
# set_location_assignment PIN_AY30 -to FLASH_OE_n
# set_location_assignment PIN_BA29 -to FLASH_RDY_BSY_n[0]
# set_location_assignment PIN_BB32 -to FLASH_RDY_BSY_n[1]
# set_location_assignment PIN_AE28 -to FLASH_RESET_n
# set_location_assignment PIN_AR31 -to FLASH_WE_n

#============================================================
# SATA
#============================================================
# set_instance_assignment -name IO_STANDARD "HCSL" -to SATA_DEVICE_REFCLK_p
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to SATA_DEVICE_RX_p[0]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to SATA_DEVICE_RX_p[1]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to SATA_DEVICE_TX_p[0]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to SATA_DEVICE_TX_p[1]
# set_instance_assignment -name IO_STANDARD "HCSL" -to SATA_HOST_REFCLK_p
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to SATA_HOST_RX_p[0]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to SATA_HOST_RX_p[1]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to SATA_HOST_TX_p[0]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to SATA_HOST_TX_p[1]
# set_location_assignment PIN_V39 -to SATA_DEVICE_REFCLK_p
# set_location_assignment PIN_K43 -to SATA_DEVICE_RX_p[0]
# set_location_assignment PIN_H43 -to SATA_DEVICE_RX_p[1]
# set_location_assignment PIN_K39 -to SATA_DEVICE_TX_p[0]
# set_location_assignment PIN_H39 -to SATA_DEVICE_TX_p[1]
# set_location_assignment PIN_V6 -to SATA_HOST_REFCLK_p
# set_location_assignment PIN_K2 -to SATA_HOST_RX_p[0]
# set_location_assignment PIN_H2 -to SATA_HOST_RX_p[1]
# set_location_assignment PIN_K6 -to SATA_HOST_TX_p[0]
# set_location_assignment PIN_H6 -to SATA_HOST_TX_p[1]

#============================================================
# RZQ
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to RZQ_0
# set_instance_assignment -name IO_STANDARD "1.8 V" -to RZQ_1
# set_instance_assignment -name IO_STANDARD "1.5 V" -to RZQ_4
# set_instance_assignment -name IO_STANDARD "1.5 V" -to RZQ_5
# set_location_assignment PIN_BA36 -to RZQ_0
# set_location_assignment PIN_AR8 -to RZQ_1
# set_location_assignment PIN_H9 -to RZQ_4
# set_location_assignment PIN_P35 -to RZQ_5

#============================================================
# QDRII+ SRAM A
#============================================================
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[17]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[18]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[19]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_A[20]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_BWS_n[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_BWS_n[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_CQ_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_CQ_p
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_DOFF_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_D[17]
# set_instance_assignment -name IO_STANDARD "Differential 1.8-V HSTL Class I" -to QDRIIA_K_n
# set_instance_assignment -name IO_STANDARD "Differential 1.8-V HSTL Class I" -to QDRIIA_K_p
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_ODT
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_QVLD
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_Q[17]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_RPS_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIA_WPS_n
# set_location_assignment PIN_AU29 -to QDRIIA_A[0]
# set_location_assignment PIN_BA28 -to QDRIIA_A[1]
# set_location_assignment PIN_AP27 -to QDRIIA_A[2]
# set_location_assignment PIN_AK27 -to QDRIIA_A[3]
# set_location_assignment PIN_AN27 -to QDRIIA_A[4]
# set_location_assignment PIN_AM28 -to QDRIIA_A[5]
# set_location_assignment PIN_AV28 -to QDRIIA_A[6]
# set_location_assignment PIN_AY27 -to QDRIIA_A[7]
# set_location_assignment PIN_BC29 -to QDRIIA_A[8]
# set_location_assignment PIN_AU28 -to QDRIIA_A[9]
# set_location_assignment PIN_AW27 -to QDRIIA_A[10]
# set_location_assignment PIN_AY28 -to QDRIIA_A[11]
# set_location_assignment PIN_BD28 -to QDRIIA_A[12]
# set_location_assignment PIN_AV29 -to QDRIIA_A[13]
# set_location_assignment PIN_AW29 -to QDRIIA_A[14]
# set_location_assignment PIN_BB29 -to QDRIIA_A[15]
# set_location_assignment PIN_BD29 -to QDRIIA_A[16]
# set_location_assignment PIN_AL27 -to QDRIIA_A[17]
# set_location_assignment PIN_AR27 -to QDRIIA_A[18]
# set_location_assignment PIN_AL28 -to QDRIIA_A[19]
# set_location_assignment PIN_AR28 -to QDRIIA_A[20]
# set_location_assignment PIN_AJ24 -to QDRIIA_BWS_n[0]
# set_location_assignment PIN_AT27 -to QDRIIA_BWS_n[1]
# set_location_assignment PIN_BA25 -to QDRIIA_CQ_n
# set_location_assignment PIN_AH22 -to QDRIIA_CQ_p
# set_location_assignment PIN_AR23 -to QDRIIA_DOFF_n
# set_location_assignment PIN_AH28 -to QDRIIA_D[0]
# set_location_assignment PIN_AH27 -to QDRIIA_D[1]
# set_location_assignment PIN_AH25 -to QDRIIA_D[2]
# set_location_assignment PIN_AJ28 -to QDRIIA_D[3]
# set_location_assignment PIN_AJ27 -to QDRIIA_D[4]
# set_location_assignment PIN_AJ26 -to QDRIIA_D[5]
# set_location_assignment PIN_AJ25 -to QDRIIA_D[6]
# set_location_assignment PIN_AL25 -to QDRIIA_D[7]
# set_location_assignment PIN_AH24 -to QDRIIA_D[8]
# set_location_assignment PIN_AN25 -to QDRIIA_D[9]
# set_location_assignment PIN_AM26 -to QDRIIA_D[10]
# set_location_assignment PIN_AM25 -to QDRIIA_D[11]
# set_location_assignment PIN_AL26 -to QDRIIA_D[12]
# set_location_assignment PIN_AK26 -to QDRIIA_D[13]
# set_location_assignment PIN_AU27 -to QDRIIA_D[14]
# set_location_assignment PIN_AU26 -to QDRIIA_D[15]
# set_location_assignment PIN_AV26 -to QDRIIA_D[16]
# set_location_assignment PIN_AW26 -to QDRIIA_D[17]
# set_location_assignment PIN_AR26 -to QDRIIA_K_n
# set_location_assignment PIN_AP25 -to QDRIIA_K_p
# set_location_assignment PIN_AN23 -to QDRIIA_ODT
# set_location_assignment PIN_AM23 -to QDRIIA_QVLD
# set_location_assignment PIN_AK23 -to QDRIIA_Q[0]
# set_location_assignment PIN_BB26 -to QDRIIA_Q[1]
# set_location_assignment PIN_BD26 -to QDRIIA_Q[2]
# set_location_assignment PIN_BA24 -to QDRIIA_Q[3]
# set_location_assignment PIN_AL23 -to QDRIIA_Q[4]
# set_location_assignment PIN_AJ23 -to QDRIIA_Q[5]
# set_location_assignment PIN_AL21 -to QDRIIA_Q[6]
# set_location_assignment PIN_AK21 -to QDRIIA_Q[7]
# set_location_assignment PIN_AJ22 -to QDRIIA_Q[8]
# set_location_assignment PIN_AW24 -to QDRIIA_Q[9]
# set_location_assignment PIN_BC26 -to QDRIIA_Q[10]
# set_location_assignment PIN_AY25 -to QDRIIA_Q[11]
# set_location_assignment PIN_AU24 -to QDRIIA_Q[12]
# set_location_assignment PIN_AV25 -to QDRIIA_Q[13]
# set_location_assignment PIN_AU25 -to QDRIIA_Q[14]
# set_location_assignment PIN_AR25 -to QDRIIA_Q[15]
# set_location_assignment PIN_AP24 -to QDRIIA_Q[16]
# set_location_assignment PIN_AL24 -to QDRIIA_Q[17]
# set_location_assignment PIN_AT26 -to QDRIIA_RPS_n
# set_location_assignment PIN_AK24 -to QDRIIA_WPS_n

#============================================================
# QDRII+ SRAM B
#============================================================
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[17]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[18]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[19]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_A[20]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_BWS_n[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_BWS_n[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_CQ_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_CQ_p
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_DOFF_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_D[17]
# set_instance_assignment -name IO_STANDARD "Differential 1.8-V HSTL Class I" -to QDRIIB_K_n
# set_instance_assignment -name IO_STANDARD "Differential 1.8-V HSTL Class I" -to QDRIIB_K_p
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_ODT
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_QVLD
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_Q[17]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_RPS_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIB_WPS_n
# set_location_assignment PIN_AR24 -to QDRIIB_A[0]
# set_location_assignment PIN_BB23 -to QDRIIB_A[1]
# set_location_assignment PIN_AK20 -to QDRIIB_A[2]
# set_location_assignment PIN_AJ19 -to QDRIIB_A[3]
# set_location_assignment PIN_AL20 -to QDRIIB_A[4]
# set_location_assignment PIN_AG19 -to QDRIIB_A[5]
# set_location_assignment PIN_AT23 -to QDRIIB_A[6]
# set_location_assignment PIN_AU23 -to QDRIIB_A[7]
# set_location_assignment PIN_AV23 -to QDRIIB_A[8]
# set_location_assignment PIN_AM22 -to QDRIIB_A[9]
# set_location_assignment PIN_AJ20 -to QDRIIB_A[10]
# set_location_assignment PIN_AG20 -to QDRIIB_A[11]
# set_location_assignment PIN_AW23 -to QDRIIB_A[12]
# set_location_assignment PIN_BB24 -to QDRIIB_A[13]
# set_location_assignment PIN_AY24 -to QDRIIB_A[14]
# set_location_assignment PIN_BD23 -to QDRIIB_A[15]
# set_location_assignment PIN_BC23 -to QDRIIB_A[16]
# set_location_assignment PIN_AG21 -to QDRIIB_A[17]
# set_location_assignment PIN_AM20 -to QDRIIB_A[18]
# set_location_assignment PIN_AK18 -to QDRIIB_A[19]
# set_location_assignment PIN_AN22 -to QDRIIB_A[20]
# set_location_assignment PIN_AV20 -to QDRIIB_BWS_n[0]
# set_location_assignment PIN_AU21 -to QDRIIB_BWS_n[1]
# set_location_assignment PIN_AP18 -to QDRIIB_CQ_n
# set_location_assignment PIN_AJ15 -to QDRIIB_CQ_p
# set_location_assignment PIN_AH19 -to QDRIIB_DOFF_n
# set_location_assignment PIN_BB21 -to QDRIIB_D[0]
# set_location_assignment PIN_BD20 -to QDRIIB_D[1]
# set_location_assignment PIN_BC20 -to QDRIIB_D[2]
# set_location_assignment PIN_AR22 -to QDRIIB_D[3]
# set_location_assignment PIN_BB20 -to QDRIIB_D[4]
# set_location_assignment PIN_AU22 -to QDRIIB_D[5]
# set_location_assignment PIN_BA21 -to QDRIIB_D[6]
# set_location_assignment PIN_AY21 -to QDRIIB_D[7]
# set_location_assignment PIN_AW21 -to QDRIIB_D[8]
# set_location_assignment PIN_AT21 -to QDRIIB_D[9]
# set_location_assignment PIN_AR21 -to QDRIIB_D[10]
# set_location_assignment PIN_AP21 -to QDRIIB_D[11]
# set_location_assignment PIN_BD22 -to QDRIIB_D[12]
# set_location_assignment PIN_BC22 -to QDRIIB_D[13]
# set_location_assignment PIN_BA22 -to QDRIIB_D[14]
# set_location_assignment PIN_AV22 -to QDRIIB_D[15]
# set_location_assignment PIN_AY22 -to QDRIIB_D[16]
# set_location_assignment PIN_AW22 -to QDRIIB_D[17]
# set_location_assignment PIN_AT20 -to QDRIIB_K_n
# set_location_assignment PIN_AR20 -to QDRIIB_K_p
# set_location_assignment PIN_AH18 -to QDRIIB_ODT
# set_location_assignment PIN_AJ16 -to QDRIIB_QVLD
# set_location_assignment PIN_AR19 -to QDRIIB_Q[0]
# set_location_assignment PIN_AM19 -to QDRIIB_Q[1]
# set_location_assignment PIN_AL19 -to QDRIIB_Q[2]
# set_location_assignment PIN_AM17 -to QDRIIB_Q[3]
# set_location_assignment PIN_AL18 -to QDRIIB_Q[4]
# set_location_assignment PIN_AN19 -to QDRIIB_Q[5]
# set_location_assignment PIN_AU18 -to QDRIIB_Q[6]
# set_location_assignment PIN_AK17 -to QDRIIB_Q[7]
# set_location_assignment PIN_AL17 -to QDRIIB_Q[8]
# set_location_assignment PIN_AG17 -to QDRIIB_Q[9]
# set_location_assignment PIN_AJ18 -to QDRIIB_Q[10]
# set_location_assignment PIN_AJ17 -to QDRIIB_Q[11]
# set_location_assignment PIN_AG18 -to QDRIIB_Q[12]
# set_location_assignment PIN_AU19 -to QDRIIB_Q[13]
# set_location_assignment PIN_AW19 -to QDRIIB_Q[14]
# set_location_assignment PIN_AV19 -to QDRIIB_Q[15]
# set_location_assignment PIN_AP19 -to QDRIIB_Q[16]
# set_location_assignment PIN_AN20 -to QDRIIB_Q[17]
# set_location_assignment PIN_AW20 -to QDRIIB_RPS_n
# set_location_assignment PIN_AU20 -to QDRIIB_WPS_n

#============================================================
# QDRII+ SRAM C
#============================================================
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[17]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[18]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[19]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_A[20]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_BWS_n[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_BWS_n[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_CQ_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_CQ_p
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_DOFF_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_D[17]
# set_instance_assignment -name IO_STANDARD "Differential 1.8-V HSTL Class I" -to QDRIIC_K_n
# set_instance_assignment -name IO_STANDARD "Differential 1.8-V HSTL Class I" -to QDRIIC_K_p
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_ODT
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_QVLD
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_Q[17]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_RPS_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIIC_WPS_n
# set_location_assignment PIN_AV16 -to QDRIIC_A[0]
# set_location_assignment PIN_AW16 -to QDRIIC_A[1]
# set_location_assignment PIN_AP16 -to QDRIIC_A[2]
# set_location_assignment PIN_AW9 -to QDRIIC_A[3]
# set_location_assignment PIN_BD7 -to QDRIIC_A[4]
# set_location_assignment PIN_BC7 -to QDRIIC_A[5]
# set_location_assignment PIN_AR17 -to QDRIIC_A[6]
# set_location_assignment PIN_AR18 -to QDRIIC_A[7]
# set_location_assignment PIN_AT17 -to QDRIIC_A[8]
# set_location_assignment PIN_BB9 -to QDRIIC_A[9]
# set_location_assignment PIN_AH21 -to QDRIIC_A[10]
# set_location_assignment PIN_AU17 -to QDRIIC_A[11]
# set_location_assignment PIN_AU16 -to QDRIIC_A[12]
# set_location_assignment PIN_BB8 -to QDRIIC_A[13]
# set_location_assignment PIN_AT18 -to QDRIIC_A[14]
# set_location_assignment PIN_AW17 -to QDRIIC_A[15]
# set_location_assignment PIN_AV17 -to QDRIIC_A[16]
# set_location_assignment PIN_AU8 -to QDRIIC_A[17]
# set_location_assignment PIN_AT9 -to QDRIIC_A[18]
# set_location_assignment PIN_AV8 -to QDRIIC_A[19]
# set_location_assignment PIN_AN17 -to QDRIIC_A[20]
# set_location_assignment PIN_AJ11 -to QDRIIC_BWS_n[0]
# set_location_assignment PIN_AJ10 -to QDRIIC_BWS_n[1]
# set_location_assignment PIN_AF13 -to QDRIIC_CQ_n
# set_location_assignment PIN_BC11 -to QDRIIC_CQ_p
# set_location_assignment PIN_AE14 -to QDRIIC_DOFF_n
# set_location_assignment PIN_AG9 -to QDRIIC_D[0]
# set_location_assignment PIN_AG10 -to QDRIIC_D[1]
# set_location_assignment PIN_AG12 -to QDRIIC_D[2]
# set_location_assignment PIN_AG11 -to QDRIIC_D[3]
# set_location_assignment PIN_AV10 -to QDRIIC_D[4]
# set_location_assignment PIN_AH12 -to QDRIIC_D[5]
# set_location_assignment PIN_AK12 -to QDRIIC_D[6]
# set_location_assignment PIN_AL12 -to QDRIIC_D[7]
# set_location_assignment PIN_AJ12 -to QDRIIC_D[8]
# set_location_assignment PIN_AN12 -to QDRIIC_D[9]
# set_location_assignment PIN_AM13 -to QDRIIC_D[10]
# set_location_assignment PIN_AR12 -to QDRIIC_D[11]
# set_location_assignment PIN_AR13 -to QDRIIC_D[12]
# set_location_assignment PIN_AU9 -to QDRIIC_D[13]
# set_location_assignment PIN_AU10 -to QDRIIC_D[14]
# set_location_assignment PIN_AU11 -to QDRIIC_D[15]
# set_location_assignment PIN_AV11 -to QDRIIC_D[16]
# set_location_assignment PIN_AT12 -to QDRIIC_D[17]
# set_location_assignment PIN_AP13 -to QDRIIC_K_n
# set_location_assignment PIN_AP12 -to QDRIIC_K_p
# set_location_assignment PIN_BD10 -to QDRIIC_ODT
# set_location_assignment PIN_BD11 -to QDRIIC_QVLD
# set_location_assignment PIN_BA12 -to QDRIIC_Q[0]
# set_location_assignment PIN_AF14 -to QDRIIC_Q[1]
# set_location_assignment PIN_AE13 -to QDRIIC_Q[2]
# set_location_assignment PIN_AD14 -to QDRIIC_Q[3]
# set_location_assignment PIN_AE12 -to QDRIIC_Q[4]
# set_location_assignment PIN_AF11 -to QDRIIC_Q[5]
# set_location_assignment PIN_AE11 -to QDRIIC_Q[6]
# set_location_assignment PIN_AE10 -to QDRIIC_Q[7]
# set_location_assignment PIN_AE9 -to QDRIIC_Q[8]
# set_location_assignment PIN_BB11 -to QDRIIC_Q[9]
# set_location_assignment PIN_AW11 -to QDRIIC_Q[10]
# set_location_assignment PIN_AF10 -to QDRIIC_Q[11]
# set_location_assignment PIN_AY12 -to QDRIIC_Q[12]
# set_location_assignment PIN_AW10 -to QDRIIC_Q[13]
# set_location_assignment PIN_AY10 -to QDRIIC_Q[14]
# set_location_assignment PIN_BB12 -to QDRIIC_Q[15]
# set_location_assignment PIN_BC10 -to QDRIIC_Q[16]
# set_location_assignment PIN_BA10 -to QDRIIC_Q[17]
# set_location_assignment PIN_AH10 -to QDRIIC_RPS_n
# set_location_assignment PIN_AL11 -to QDRIIC_WPS_n

#============================================================
# QDRII+ SRAM D
#============================================================
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[17]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[18]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[19]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_A[20]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_BWS_n[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_BWS_n[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_CQ_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_CQ_p
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_DOFF_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_D[17]
# set_instance_assignment -name IO_STANDARD "Differential 1.8-V HSTL Class I" -to QDRIID_K_n
# set_instance_assignment -name IO_STANDARD "Differential 1.8-V HSTL Class I" -to QDRIID_K_p
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_ODT
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_QVLD
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[0]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[1]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[2]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[3]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[4]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[5]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[6]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[7]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[8]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[9]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[10]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[11]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[12]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[13]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[14]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[15]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[16]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_Q[17]
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_RPS_n
# set_instance_assignment -name IO_STANDARD "1.8-V HSTL Class I" -to QDRIID_WPS_n
# set_location_assignment PIN_N26 -to QDRIID_A[0]
# set_location_assignment PIN_P28 -to QDRIID_A[1]
# set_location_assignment PIN_N28 -to QDRIID_A[2]
# set_location_assignment PIN_L26 -to QDRIID_A[3]
# set_location_assignment PIN_K27 -to QDRIID_A[4]
# set_location_assignment PIN_L27 -to QDRIID_A[5]
# set_location_assignment PIN_U26 -to QDRIID_A[6]
# set_location_assignment PIN_T26 -to QDRIID_A[7]
# set_location_assignment PIN_T27 -to QDRIID_A[8]
# set_location_assignment PIN_V27 -to QDRIID_A[9]
# set_location_assignment PIN_U27 -to QDRIID_A[10]
# set_location_assignment PIN_R27 -to QDRIID_A[11]
# set_location_assignment PIN_P27 -to QDRIID_A[12]
# set_location_assignment PIN_V25 -to QDRIID_A[13]
# set_location_assignment PIN_V26 -to QDRIID_A[14]
# set_location_assignment PIN_T25 -to QDRIID_A[15]
# set_location_assignment PIN_P26 -to QDRIID_A[16]
# set_location_assignment PIN_M27 -to QDRIID_A[17]
# set_location_assignment PIN_M28 -to QDRIID_A[18]
# set_location_assignment PIN_P29 -to QDRIID_A[19]
# set_location_assignment PIN_D29 -to QDRIID_A[20]
# set_location_assignment PIN_E26 -to QDRIID_BWS_n[0]
# set_location_assignment PIN_K26 -to QDRIID_BWS_n[1]
# set_location_assignment PIN_H27 -to QDRIID_CQ_n
# set_location_assignment PIN_E29 -to QDRIID_CQ_p
# set_location_assignment PIN_E27 -to QDRIID_DOFF_n
# set_location_assignment PIN_H25 -to QDRIID_D[0]
# set_location_assignment PIN_H24 -to QDRIID_D[1]
# set_location_assignment PIN_H23 -to QDRIID_D[2]
# set_location_assignment PIN_J25 -to QDRIID_D[3]
# set_location_assignment PIN_J24 -to QDRIID_D[4]
# set_location_assignment PIN_K25 -to QDRIID_D[5]
# set_location_assignment PIN_D26 -to QDRIID_D[6]
# set_location_assignment PIN_F25 -to QDRIID_D[7]
# set_location_assignment PIN_G25 -to QDRIID_D[8]
# set_location_assignment PIN_N23 -to QDRIID_D[9]
# set_location_assignment PIN_P24 -to QDRIID_D[10]
# set_location_assignment PIN_P23 -to QDRIID_D[11]
# set_location_assignment PIN_L24 -to QDRIID_D[12]
# set_location_assignment PIN_R24 -to QDRIID_D[13]
# set_location_assignment PIN_U23 -to QDRIID_D[14]
# set_location_assignment PIN_U24 -to QDRIID_D[15]
# set_location_assignment PIN_T24 -to QDRIID_D[16]
# set_location_assignment PIN_T23 -to QDRIID_D[17]
# set_location_assignment PIN_K24 -to QDRIID_K_n
# set_location_assignment PIN_L23 -to QDRIID_K_p
# set_location_assignment PIN_H26 -to QDRIID_ODT
# set_location_assignment PIN_J27 -to QDRIID_QVLD
# set_location_assignment PIN_C27 -to QDRIID_Q[0]
# set_location_assignment PIN_A26 -to QDRIID_Q[1]
# set_location_assignment PIN_B26 -to QDRIID_Q[2]
# set_location_assignment PIN_F26 -to QDRIID_Q[3]
# set_location_assignment PIN_G26 -to QDRIID_Q[4]
# set_location_assignment PIN_C28 -to QDRIID_Q[5]
# set_location_assignment PIN_A29 -to QDRIID_Q[6]
# set_location_assignment PIN_A28 -to QDRIID_Q[7]
# set_location_assignment PIN_B28 -to QDRIID_Q[8]
# set_location_assignment PIN_G28 -to QDRIID_Q[9]
# set_location_assignment PIN_F28 -to QDRIID_Q[10]
# set_location_assignment PIN_D27 -to QDRIID_Q[11]
# set_location_assignment PIN_G29 -to QDRIID_Q[12]
# set_location_assignment PIN_F29 -to QDRIID_Q[13]
# set_location_assignment PIN_H28 -to QDRIID_Q[14]
# set_location_assignment PIN_K28 -to QDRIID_Q[15]
# set_location_assignment PIN_J28 -to QDRIID_Q[16]
# set_location_assignment PIN_H29 -to QDRIID_Q[17]
# set_location_assignment PIN_F24 -to QDRIID_RPS_n
# set_location_assignment PIN_M23 -to QDRIID_WPS_n

#============================================================
# DDR3 SODIMM, DDR3 SODIMM_A
#============================================================
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[2]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[3]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[4]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[5]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[6]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[7]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[8]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[9]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[10]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[11]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[12]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[13]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[14]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_A[15]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_BA[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_BA[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_BA[2]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_CAS_n
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_CK[0]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_CK[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_CKE[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_CKE[1]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_CK_n[0]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_CK_n[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_CS_n[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_CS_n[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DM[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DM[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DM[2]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DM[3]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DM[4]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DM[5]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DM[6]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DM[7]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[2]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[3]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[4]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[5]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[6]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[7]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[8]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[9]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[10]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[11]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[12]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[13]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[14]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[15]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[16]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[17]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[18]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[19]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[20]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[21]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[22]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[23]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[24]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[25]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[26]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[27]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[28]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[29]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[30]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[31]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[32]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[33]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[34]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[35]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[36]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[37]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[38]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[39]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[40]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[41]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[42]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[43]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[44]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[45]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[46]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[47]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[48]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[49]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[50]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[51]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[52]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[53]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[54]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[55]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[56]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[57]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[58]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[59]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[60]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[61]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[62]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_DQ[63]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS[0]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS[1]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS[2]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS[3]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS[4]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS[5]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS[6]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS[7]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS_n[0]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS_n[1]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS_n[2]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS_n[3]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS_n[4]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS_n[5]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS_n[6]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3A_DQS_n[7]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to DDR3A_EVENT_n
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_ODT[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_ODT[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_RAS_n
# set_instance_assignment -name IO_STANDARD "1.5 V" -to DDR3A_RESET_n
# set_instance_assignment -name IO_STANDARD "1.5 V" -to DDR3A_SCL
# set_instance_assignment -name IO_STANDARD "1.5 V" -to DDR3A_SDA
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3A_WE_n
# set_location_assignment PIN_M39 -to DDR3A_A[0]
# set_location_assignment PIN_L35 -to DDR3A_A[1]
# set_location_assignment PIN_N38 -to DDR3A_A[2]
# set_location_assignment PIN_L36 -to DDR3A_A[3]
# set_location_assignment PIN_H36 -to DDR3A_A[4]
# set_location_assignment PIN_K29 -to DDR3A_A[5]
# set_location_assignment PIN_D37 -to DDR3A_A[6]
# set_location_assignment PIN_K35 -to DDR3A_A[7]
# set_location_assignment PIN_K32 -to DDR3A_A[8]
# set_location_assignment PIN_K37 -to DDR3A_A[9]
# set_location_assignment PIN_M38 -to DDR3A_A[10]
# set_location_assignment PIN_C37 -to DDR3A_A[11]
# set_location_assignment PIN_K36 -to DDR3A_A[12]
# set_location_assignment PIN_M33 -to DDR3A_A[13]
# set_location_assignment PIN_K34 -to DDR3A_A[14]
# set_location_assignment PIN_B38 -to DDR3A_A[15]
# set_location_assignment PIN_M37 -to DDR3A_BA[0]
# set_location_assignment PIN_P39 -to DDR3A_BA[1]
# set_location_assignment PIN_J36 -to DDR3A_BA[2]
# set_location_assignment PIN_M36 -to DDR3A_CAS_n
# set_location_assignment PIN_G37 -to DDR3A_CK[0]
# set_location_assignment PIN_J37 -to DDR3A_CK[1]
# set_location_assignment PIN_E36 -to DDR3A_CKE[0]
# set_location_assignment PIN_B35 -to DDR3A_CKE[1]
# set_location_assignment PIN_F36 -to DDR3A_CK_n[0]
# set_location_assignment PIN_H37 -to DDR3A_CK_n[1]
# set_location_assignment PIN_P36 -to DDR3A_CS_n[0]
# set_location_assignment PIN_R28 -to DDR3A_CS_n[1]
# set_location_assignment PIN_C36 -to DDR3A_DM[0]
# set_location_assignment PIN_E32 -to DDR3A_DM[1]
# set_location_assignment PIN_H34 -to DDR3A_DM[2]
# set_location_assignment PIN_L32 -to DDR3A_DM[3]
# set_location_assignment PIN_N32 -to DDR3A_DM[4]
# set_location_assignment PIN_W32 -to DDR3A_DM[5]
# set_location_assignment PIN_K30 -to DDR3A_DM[6]
# set_location_assignment PIN_T28 -to DDR3A_DM[7]
# set_location_assignment PIN_A35 -to DDR3A_DQ[0]
# set_location_assignment PIN_A34 -to DDR3A_DQ[1]
# set_location_assignment PIN_D36 -to DDR3A_DQ[2]
# set_location_assignment PIN_C33 -to DDR3A_DQ[3]
# set_location_assignment PIN_B32 -to DDR3A_DQ[4]
# set_location_assignment PIN_D35 -to DDR3A_DQ[5]
# set_location_assignment PIN_D33 -to DDR3A_DQ[6]
# set_location_assignment PIN_E33 -to DDR3A_DQ[7]
# set_location_assignment PIN_A32 -to DDR3A_DQ[8]
# set_location_assignment PIN_A31 -to DDR3A_DQ[9]
# set_location_assignment PIN_C30 -to DDR3A_DQ[10]
# set_location_assignment PIN_D30 -to DDR3A_DQ[11]
# set_location_assignment PIN_B29 -to DDR3A_DQ[12]
# set_location_assignment PIN_E30 -to DDR3A_DQ[13]
# set_location_assignment PIN_F31 -to DDR3A_DQ[14]
# set_location_assignment PIN_G31 -to DDR3A_DQ[15]
# set_location_assignment PIN_F35 -to DDR3A_DQ[16]
# set_location_assignment PIN_G34 -to DDR3A_DQ[17]
# set_location_assignment PIN_J33 -to DDR3A_DQ[18]
# set_location_assignment PIN_J34 -to DDR3A_DQ[19]
# set_location_assignment PIN_F34 -to DDR3A_DQ[20]
# set_location_assignment PIN_E35 -to DDR3A_DQ[21]
# set_location_assignment PIN_J31 -to DDR3A_DQ[22]
# set_location_assignment PIN_K31 -to DDR3A_DQ[23]
# set_location_assignment PIN_P34 -to DDR3A_DQ[24]
# set_location_assignment PIN_R33 -to DDR3A_DQ[25]
# set_location_assignment PIN_M34 -to DDR3A_DQ[26]
# set_location_assignment PIN_L33 -to DDR3A_DQ[27]
# set_location_assignment PIN_R34 -to DDR3A_DQ[28]
# set_location_assignment PIN_T34 -to DDR3A_DQ[29]
# set_location_assignment PIN_W34 -to DDR3A_DQ[30]
# set_location_assignment PIN_V35 -to DDR3A_DQ[31]
# set_location_assignment PIN_P33 -to DDR3A_DQ[32]
# set_location_assignment PIN_P32 -to DDR3A_DQ[33]
# set_location_assignment PIN_V33 -to DDR3A_DQ[34]
# set_location_assignment PIN_V34 -to DDR3A_DQ[35]
# set_location_assignment PIN_N31 -to DDR3A_DQ[36]
# set_location_assignment PIN_M31 -to DDR3A_DQ[37]
# set_location_assignment PIN_U32 -to DDR3A_DQ[38]
# set_location_assignment PIN_U33 -to DDR3A_DQ[39]
# set_location_assignment PIN_R31 -to DDR3A_DQ[40]
# set_location_assignment PIN_W31 -to DDR3A_DQ[41]
# set_location_assignment PIN_U30 -to DDR3A_DQ[42]
# set_location_assignment PIN_P31 -to DDR3A_DQ[43]
# set_location_assignment PIN_T31 -to DDR3A_DQ[44]
# set_location_assignment PIN_Y32 -to DDR3A_DQ[45]
# set_location_assignment PIN_T29 -to DDR3A_DQ[46]
# set_location_assignment PIN_P30 -to DDR3A_DQ[47]
# set_location_assignment PIN_H32 -to DDR3A_DQ[48]
# set_location_assignment PIN_H31 -to DDR3A_DQ[49]
# set_location_assignment PIN_L30 -to DDR3A_DQ[50]
# set_location_assignment PIN_L29 -to DDR3A_DQ[51]
# set_location_assignment PIN_F32 -to DDR3A_DQ[52]
# set_location_assignment PIN_G32 -to DDR3A_DQ[53]
# set_location_assignment PIN_M30 -to DDR3A_DQ[54]
# set_location_assignment PIN_N29 -to DDR3A_DQ[55]
# set_location_assignment PIN_U29 -to DDR3A_DQ[56]
# set_location_assignment PIN_V28 -to DDR3A_DQ[57]
# set_location_assignment PIN_Y28 -to DDR3A_DQ[58]
# set_location_assignment PIN_W29 -to DDR3A_DQ[59]
# set_location_assignment PIN_V30 -to DDR3A_DQ[60]
# set_location_assignment PIN_V29 -to DDR3A_DQ[61]
# set_location_assignment PIN_W28 -to DDR3A_DQ[62]
# set_location_assignment PIN_Y27 -to DDR3A_DQ[63]
# set_location_assignment PIN_C34 -to DDR3A_DQS[0]
# set_location_assignment PIN_C31 -to DDR3A_DQS[1]
# set_location_assignment PIN_H35 -to DDR3A_DQS[2]
# set_location_assignment PIN_U35 -to DDR3A_DQS[3]
# set_location_assignment PIN_T33 -to DDR3A_DQS[4]
# set_location_assignment PIN_T30 -to DDR3A_DQS[5]
# set_location_assignment PIN_J30 -to DDR3A_DQS[6]
# set_location_assignment PIN_Y30 -to DDR3A_DQS[7]
# set_location_assignment PIN_B34 -to DDR3A_DQS_n[0]
# set_location_assignment PIN_B31 -to DDR3A_DQS_n[1]
# set_location_assignment PIN_G35 -to DDR3A_DQS_n[2]
# set_location_assignment PIN_T35 -to DDR3A_DQS_n[3]
# set_location_assignment PIN_T32 -to DDR3A_DQS_n[4]
# set_location_assignment PIN_R30 -to DDR3A_DQS_n[5]
# set_location_assignment PIN_H30 -to DDR3A_DQS_n[6]
# set_location_assignment PIN_Y29 -to DDR3A_DQS_n[7]
# set_location_assignment PIN_K19 -to DDR3A_EVENT_n
# set_location_assignment PIN_V36 -to DDR3A_ODT[0]
# set_location_assignment PIN_W35 -to DDR3A_ODT[1]
# set_location_assignment PIN_P38 -to DDR3A_RAS_n
# set_location_assignment PIN_H33 -to DDR3A_RESET_n
# set_location_assignment PIN_C15 -to DDR3A_SCL
# set_location_assignment PIN_P15 -to DDR3A_SDA
# set_location_assignment PIN_N37 -to DDR3A_WE_n

#============================================================
# DDR3 SODIMM, DDR3 SODIMM_B
#============================================================
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[2]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[3]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[4]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[5]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[6]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[7]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[8]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[9]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[10]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[11]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[12]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[13]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[14]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_A[15]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_BA[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_BA[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_BA[2]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_CAS_n
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_CK[0]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_CK[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_CKE[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_CKE[1]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_CK_n[0]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_CK_n[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_CS_n[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_CS_n[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DM[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DM[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DM[2]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DM[3]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DM[4]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DM[5]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DM[6]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DM[7]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[2]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[3]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[4]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[5]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[6]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[7]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[8]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[9]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[10]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[11]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[12]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[13]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[14]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[15]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[16]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[17]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[18]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[19]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[20]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[21]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[22]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[23]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[24]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[25]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[26]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[27]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[28]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[29]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[30]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[31]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[32]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[33]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[34]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[35]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[36]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[37]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[38]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[39]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[40]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[41]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[42]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[43]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[44]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[45]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[46]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[47]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[48]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[49]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[50]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[51]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[52]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[53]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[54]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[55]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[56]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[57]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[58]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[59]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[60]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[61]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[62]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_DQ[63]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS[0]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS[1]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS[2]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS[3]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS[4]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS[5]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS[6]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS[7]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS_n[0]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS_n[1]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS_n[2]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS_n[3]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS_n[4]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS_n[5]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS_n[6]
# set_instance_assignment -name IO_STANDARD "Differential 1.5-V SSTL Class I" -to DDR3B_DQS_n[7]
# set_instance_assignment -name IO_STANDARD "1.5 V" -to DDR3B_EVENT_n
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_ODT[0]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_ODT[1]
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_RAS_n
# set_instance_assignment -name IO_STANDARD "1.5 V" -to DDR3B_RESET_n
# set_instance_assignment -name IO_STANDARD "1.5 V" -to DDR3B_SCL
# set_instance_assignment -name IO_STANDARD "1.5 V" -to DDR3B_SDA
# set_instance_assignment -name IO_STANDARD "SSTL-15 Class I" -to DDR3B_WE_n
# set_location_assignment PIN_G17 -to DDR3B_A[0]
# set_location_assignment PIN_F17 -to DDR3B_A[1]
# set_location_assignment PIN_N17 -to DDR3B_A[2]
# set_location_assignment PIN_F19 -to DDR3B_A[3]
# set_location_assignment PIN_N19 -to DDR3B_A[4]
# set_location_assignment PIN_H16 -to DDR3B_A[5]
# set_location_assignment PIN_M17 -to DDR3B_A[6]
# set_location_assignment PIN_T18 -to DDR3B_A[7]
# set_location_assignment PIN_H17 -to DDR3B_A[8]
# set_location_assignment PIN_J19 -to DDR3B_A[9]
# set_location_assignment PIN_C19 -to DDR3B_A[10]
# set_location_assignment PIN_R18 -to DDR3B_A[11]
# set_location_assignment PIN_K18 -to DDR3B_A[12]
# set_location_assignment PIN_E18 -to DDR3B_A[13]
# set_location_assignment PIN_T19 -to DDR3B_A[14]
# set_location_assignment PIN_R19 -to DDR3B_A[15]
# set_location_assignment PIN_C18 -to DDR3B_BA[0]
# set_location_assignment PIN_G19 -to DDR3B_BA[1]
# set_location_assignment PIN_M20 -to DDR3B_BA[2]
# set_location_assignment PIN_A17 -to DDR3B_CAS_n
# set_location_assignment PIN_B16 -to DDR3B_CK[0]
# set_location_assignment PIN_E17 -to DDR3B_CK[1]
# set_location_assignment PIN_P17 -to DDR3B_CKE[0]
# set_location_assignment PIN_V18 -to DDR3B_CKE[1]
# set_location_assignment PIN_A16 -to DDR3B_CK_n[0]
# set_location_assignment PIN_D17 -to DDR3B_CK_n[1]
# set_location_assignment PIN_B19 -to DDR3B_CS_n[0]
# set_location_assignment PIN_B17 -to DDR3B_CS_n[1]
# set_location_assignment PIN_R15 -to DDR3B_DM[0]
# set_location_assignment PIN_K15 -to DDR3B_DM[1]
# set_location_assignment PIN_V12 -to DDR3B_DM[2]
# set_location_assignment PIN_G10 -to DDR3B_DM[3]
# set_location_assignment PIN_T12 -to DDR3B_DM[4]
# set_location_assignment PIN_C16 -to DDR3B_DM[5]
# set_location_assignment PIN_H15 -to DDR3B_DM[6]
# set_location_assignment PIN_B11 -to DDR3B_DM[7]
# set_location_assignment PIN_Y17 -to DDR3B_DQ[0]
# set_location_assignment PIN_W17 -to DDR3B_DQ[1]
# set_location_assignment PIN_V15 -to DDR3B_DQ[2]
# set_location_assignment PIN_T15 -to DDR3B_DQ[3]
# set_location_assignment PIN_V13 -to DDR3B_DQ[4]
# set_location_assignment PIN_V16 -to DDR3B_DQ[5]
# set_location_assignment PIN_W14 -to DDR3B_DQ[6]
# set_location_assignment PIN_U15 -to DDR3B_DQ[7]
# set_location_assignment PIN_T17 -to DDR3B_DQ[8]
# set_location_assignment PIN_T16 -to DDR3B_DQ[9]
# set_location_assignment PIN_R16 -to DDR3B_DQ[10]
# set_location_assignment PIN_P16 -to DDR3B_DQ[11]
# set_location_assignment PIN_N16 -to DDR3B_DQ[12]
# set_location_assignment PIN_M15 -to DDR3B_DQ[13]
# set_location_assignment PIN_M14 -to DDR3B_DQ[14]
# set_location_assignment PIN_L14 -to DDR3B_DQ[15]
# set_location_assignment PIN_T14 -to DDR3B_DQ[16]
# set_location_assignment PIN_U14 -to DDR3B_DQ[17]
# set_location_assignment PIN_U11 -to DDR3B_DQ[18]
# set_location_assignment PIN_T13 -to DDR3B_DQ[19]
# set_location_assignment PIN_U12 -to DDR3B_DQ[20]
# set_location_assignment PIN_R13 -to DDR3B_DQ[21]
# set_location_assignment PIN_P13 -to DDR3B_DQ[22]
# set_location_assignment PIN_N13 -to DDR3B_DQ[23]
# set_location_assignment PIN_K12 -to DDR3B_DQ[24]
# set_location_assignment PIN_J12 -to DDR3B_DQ[25]
# set_location_assignment PIN_J10 -to DDR3B_DQ[26]
# set_location_assignment PIN_H12 -to DDR3B_DQ[27]
# set_location_assignment PIN_N11 -to DDR3B_DQ[28]
# set_location_assignment PIN_M11 -to DDR3B_DQ[29]
# set_location_assignment PIN_H10 -to DDR3B_DQ[30]
# set_location_assignment PIN_H11 -to DDR3B_DQ[31]
# set_location_assignment PIN_T10 -to DDR3B_DQ[32]
# set_location_assignment PIN_R10 -to DDR3B_DQ[33]
# set_location_assignment PIN_M12 -to DDR3B_DQ[34]
# set_location_assignment PIN_L12 -to DDR3B_DQ[35]
# set_location_assignment PIN_V10 -to DDR3B_DQ[36]
# set_location_assignment PIN_V9 -to DDR3B_DQ[37]
# set_location_assignment PIN_R12 -to DDR3B_DQ[38]
# set_location_assignment PIN_P12 -to DDR3B_DQ[39]
# set_location_assignment PIN_D14 -to DDR3B_DQ[40]
# set_location_assignment PIN_C13 -to DDR3B_DQ[41]
# set_location_assignment PIN_B14 -to DDR3B_DQ[42]
# set_location_assignment PIN_B13 -to DDR3B_DQ[43]
# set_location_assignment PIN_E14 -to DDR3B_DQ[44]
# set_location_assignment PIN_F14 -to DDR3B_DQ[45]
# set_location_assignment PIN_A14 -to DDR3B_DQ[46]
# set_location_assignment PIN_A13 -to DDR3B_DQ[47]
# set_location_assignment PIN_K13 -to DDR3B_DQ[48]
# set_location_assignment PIN_K16 -to DDR3B_DQ[49]
# set_location_assignment PIN_H13 -to DDR3B_DQ[50]
# set_location_assignment PIN_H14 -to DDR3B_DQ[51]
# set_location_assignment PIN_J13 -to DDR3B_DQ[52]
# set_location_assignment PIN_J16 -to DDR3B_DQ[53]
# set_location_assignment PIN_G13 -to DDR3B_DQ[54]
# set_location_assignment PIN_F13 -to DDR3B_DQ[55]
# set_location_assignment PIN_D11 -to DDR3B_DQ[56]
# set_location_assignment PIN_C10 -to DDR3B_DQ[57]
# set_location_assignment PIN_A10 -to DDR3B_DQ[58]
# set_location_assignment PIN_B10 -to DDR3B_DQ[59]
# set_location_assignment PIN_G11 -to DDR3B_DQ[60]
# set_location_assignment PIN_F11 -to DDR3B_DQ[61]
# set_location_assignment PIN_E11 -to DDR3B_DQ[62]
# set_location_assignment PIN_E12 -to DDR3B_DQ[63]
# set_location_assignment PIN_Y16 -to DDR3B_DQS[0]
# set_location_assignment PIN_V17 -to DDR3B_DQS[1]
# set_location_assignment PIN_P14 -to DDR3B_DQS[2]
# set_location_assignment PIN_K11 -to DDR3B_DQS[3]
# set_location_assignment PIN_U9 -to DDR3B_DQS[4]
# set_location_assignment PIN_E15 -to DDR3B_DQS[5]
# set_location_assignment PIN_L15 -to DDR3B_DQS[6]
# set_location_assignment PIN_D12 -to DDR3B_DQS[7]
# set_location_assignment PIN_W16 -to DDR3B_DQS_n[0]
# set_location_assignment PIN_U17 -to DDR3B_DQS_n[1]
# set_location_assignment PIN_N14 -to DDR3B_DQS_n[2]
# set_location_assignment PIN_L11 -to DDR3B_DQS_n[3]
# set_location_assignment PIN_T9 -to DDR3B_DQS_n[4]
# set_location_assignment PIN_D15 -to DDR3B_DQS_n[5]
# set_location_assignment PIN_K14 -to DDR3B_DQS_n[6]
# set_location_assignment PIN_C12 -to DDR3B_DQS_n[7]
# set_location_assignment PIN_K17 -to DDR3B_EVENT_n
# set_location_assignment PIN_M18 -to DDR3B_ODT[0]
# set_location_assignment PIN_A19 -to DDR3B_ODT[1]
# set_location_assignment PIN_H19 -to DDR3B_RAS_n
# set_location_assignment PIN_T20 -to DDR3B_RESET_n
# set_location_assignment PIN_P18 -to DDR3B_SCL
# set_location_assignment PIN_P19 -to DDR3B_SDA
# set_location_assignment PIN_D18 -to DDR3B_WE_n

#============================================================
# SFP+ A
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp0_sfp_los                   ; # SFPA_LOS
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp0_sfp_prsnt_n               ; # SFPA_MOD0_PRSNT_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp0_sfp_scl                   ; # SFPA_MOD1_SCL
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp0_sfp_sda                   ; # SFPA_MOD2_SDA
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp0_sfp_ratesel[0]            ; # SFPA_RATESEL[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp0_sfp_ratesel[1]            ; # SFPA_RATESEL[1]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to port0_line_rd_lvds        ; # SFPA_RX_p
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp0_sfp_txdis                 ; # SFPA_TXDISABLE
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp0_sfp_txfail                ; # SFPA_TXFAULT
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to port0_line_td_lvds        ; # SFPA_TX_p
# set_location_assignment PIN_F22 -to sfp0_sfp_los                                     ; # SFPA_LOS
# set_location_assignment PIN_E21 -to sfp0_sfp_prsnt_n                                 ; # SFPA_MOD0_PRSNT_n
# set_location_assignment PIN_B20 -to sfp0_sfp_scl                                     ; # SFPA_MOD1_SCL
# set_location_assignment PIN_A20 -to sfp0_sfp_sda                                     ; # SFPA_MOD2_SDA
# set_location_assignment PIN_E20 -to sfp0_sfp_ratesel[0]                              ; # SFPA_RATESEL[0]
# set_location_assignment PIN_G22 -to sfp0_sfp_ratesel[1]                              ; # SFPA_RATESEL[1]
# set_location_assignment PIN_AK2 -to port0_line_rd_lvds                               ; # SFPA_RX_p
# set_location_assignment PIN_B22 -to sfp0_sfp_txdis                                   ; # SFPA_TXDISABLE
# set_location_assignment PIN_A22 -to sfp0_sfp_txfail                                  ; # SFPA_TXFAULT
# set_location_assignment PIN_AG4 -to port0_line_td_lvds                               ; # SFPA_TX_p
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp0_sfp_scl
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp0_sfp_sda
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp0_sfp_ratesel[0]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp0_sfp_ratesel[1]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp0_sfp_txdis
# set_instance_assignment -name SLEW_RATE 1 -to sfp0_sfp_scl        ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp0_sfp_sda        ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp0_sfp_ratesel[0] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp0_sfp_ratesel[1] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp0_sfp_txdis      ; # fast

#============================================================
# SFP+ B
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp1_sfp_los                   ; # SFPB_LOS
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp1_sfp_prsnt_n               ; # SFPB_MOD0_PRSNT_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp1_sfp_scl                   ; # SFPB_MOD1_SCL
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp1_sfp_sda                   ; # SFPB_MOD2_SDA
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp1_sfp_ratesel[0]            ; # SFPB_RATESEL[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp1_sfp_ratesel[1]            ; # SFPB_RATESEL[1]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to port1_line_rd_lvds        ; # SFPB_RX_p
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp1_sfp_txdis                 ; # SFPB_TXDISABLE
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp1_sfp_txfail                ; # SFPB_TXFAULT
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to port1_line_td_lvds        ; # SFPB_TX_p
# set_location_assignment PIN_R22 -to sfp1_sfp_los                                     ; # SFPB_LOS
# set_location_assignment PIN_K22 -to sfp1_sfp_prsnt_n                                 ; # SFPB_MOD0_PRSNT_n
# set_location_assignment PIN_K21 -to sfp1_sfp_scl                                     ; # SFPB_MOD1_SCL
# set_location_assignment PIN_K20 -to sfp1_sfp_sda                                     ; # SFPB_MOD2_SDA
# set_location_assignment PIN_R21 -to sfp1_sfp_ratesel[0]                              ; # SFPB_RATESEL[0]
# set_location_assignment PIN_T22 -to sfp1_sfp_ratesel[1]                              ; # SFPB_RATESEL[1]
# set_location_assignment PIN_AP2 -to port1_line_rd_lvds                               ; # SFPB_RX_p
# set_location_assignment PIN_H22 -to sfp1_sfp_txdis                                   ; # SFPB_TXDISABLE
# set_location_assignment PIN_H20 -to sfp1_sfp_txfail                                  ; # SFPB_TXFAULT
# set_location_assignment PIN_AL4 -to port1_line_td_lvds                               ; # SFPB_TX_p
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp1_sfp_scl
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp1_sfp_sda
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp1_sfp_ratesel[0]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp1_sfp_ratesel[1]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp1_sfp_txdis
# set_instance_assignment -name SLEW_RATE 1 -to sfp1_sfp_scl        ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp1_sfp_sda        ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp1_sfp_ratesel[0] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp1_sfp_ratesel[1] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp1_sfp_txdis      ; # fast

#============================================================
# SFP+ C
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp2_sfp_los                   ; # SFPC_LOS
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp2_sfp_prsnt_n               ; # SFPC_MOD0_PRSNT_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp2_sfp_scl                   ; # SFPC_MOD1_SCL
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp2_sfp_sda                   ; # SFPC_MOD2_SDA
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp2_sfp_ratesel[0]            ; # SFPC_RATESEL[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp2_sfp_ratesel[1]            ; # SFPC_RATESEL[1]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to port2_line_rd_lvds        ; # SFPC_RX_p
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp2_sfp_txdis                 ; # SFPC_TXDISABLE
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp2_sfp_txfail                ; # SFPC_TXFAULT
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to port2_line_td_lvds        ; # SFPC_TX_p
# set_location_assignment PIN_L21 -to sfp2_sfp_los                                     ; # SFPC_LOS
# set_location_assignment PIN_J21 -to sfp2_sfp_prsnt_n                                 ; # SFPC_MOD0_PRSNT_n
# set_location_assignment PIN_H21 -to sfp2_sfp_scl                                     ; # SFPC_MOD1_SCL
# set_location_assignment PIN_G20 -to sfp2_sfp_sda                                     ; # SFPC_MOD2_SDA
# set_location_assignment PIN_J22 -to sfp2_sfp_ratesel[0]                              ; # SFPC_RATESEL[0]
# set_location_assignment PIN_P21 -to sfp2_sfp_ratesel[1]                              ; # SFPC_RATESEL[1]
# set_location_assignment PIN_AW4 -to port2_line_rd_lvds                               ; # SFPC_RX_p
# set_location_assignment PIN_F21 -to sfp2_sfp_txdis                                   ; # SFPC_TXDISABLE
# set_location_assignment PIN_F20 -to sfp2_sfp_txfail                                  ; # SFPC_TXFAULT
# set_location_assignment PIN_AT6 -to port2_line_td_lvds                               ; # SFPC_TX_p
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp2_sfp_scl
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp2_sfp_sda
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp2_sfp_ratesel[0]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp2_sfp_ratesel[1]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp2_sfp_txdis
# set_instance_assignment -name SLEW_RATE 1 -to sfp2_sfp_scl        ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp2_sfp_sda        ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp2_sfp_ratesel[0] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp2_sfp_ratesel[1] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp2_sfp_txdis      ; # fast

#============================================================
# SFP+ D
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp3_sfp_los                   ; # SFPD_LOS
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp3_sfp_prsnt_n               ; # SFPD_MOD0_PRSNT_n
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp3_sfp_scl                   ; # SFPD_MOD1_SCL
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp3_sfp_sda                   ; # SFPD_MOD2_SDA
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp3_sfp_ratesel[0]            ; # SFPD_RATESEL[0]
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp3_sfp_ratesel[1]            ; # SFPD_RATESEL[1]
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to port3_line_rd_lvds        ; # SFPD_RX_p
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp3_sfp_txdis                 ; # SFPD_TXDISABLE
# set_instance_assignment -name IO_STANDARD "2.5 V" -to sfp3_sfp_txfail                ; # SFPD_TXFAULT
# set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to port3_line_td_lvds        ; # SFPD_TX_p
# set_location_assignment PIN_N22 -to sfp3_sfp_los                                     ; # SFPD_LOS
# set_location_assignment PIN_V20 -to sfp3_sfp_prsnt_n                                 ; # SFPD_MOD0_PRSNT_n
# set_location_assignment PIN_U21 -to sfp3_sfp_scl                                     ; # SFPD_MOD1_SCL
# set_location_assignment PIN_V19 -to sfp3_sfp_sda                                     ; # SFPD_MOD2_SDA
# set_location_assignment PIN_V21 -to sfp3_sfp_ratesel[0]                              ; # SFPD_RATESEL[0]
# set_location_assignment PIN_M22 -to sfp3_sfp_ratesel[1]                              ; # SFPD_RATESEL[1]
# set_location_assignment PIN_BB2 -to port3_line_rd_lvds                               ; # SFPD_RX_p
# set_location_assignment PIN_U20 -to sfp3_sfp_txdis                                   ; # SFPD_TXDISABLE
# set_location_assignment PIN_T21 -to sfp3_sfp_txfail                                  ; # SFPD_TXFAULT
# set_location_assignment PIN_AY6 -to port3_line_td_lvds                               ; # SFPD_TX_p
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp3_sfp_scl
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp3_sfp_sda
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp3_sfp_ratesel[0]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp3_sfp_ratesel[1]
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to sfp3_sfp_txdis
# set_instance_assignment -name SLEW_RATE 1 -to sfp3_sfp_scl        ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp3_sfp_sda        ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp3_sfp_ratesel[0] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp3_sfp_ratesel[1] ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to sfp3_sfp_txdis      ; # fast

#============================================================
# SFP+ 10G Referece Clock and Programmable Oscillator Si570
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to si570_i2c_scl ; # CLOCK_SCL
# set_instance_assignment -name IO_STANDARD "2.5 V" -to si570_i2c_sda ; # CLOCK_SDA
# set_instance_assignment -name IO_STANDARD "HCSL" -to phy_clk_clk ; # SFP_REFCLK_p
# set_location_assignment PIN_AE15 -to si570_i2c_scl ; # CLOCK_SCL
# set_location_assignment PIN_AE16 -to si570_i2c_sda ; # CLOCK_SDA
# set_location_assignment PIN_AK7 -to phy_clk_clk ; # SFP_REFCLK_p
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to si570_i2c_sda
# set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to si570_i2c_scl
# set_instance_assignment -name SLEW_RATE 1 -to si570_i2c_sda ; # fast
# set_instance_assignment -name SLEW_RATE 1 -to si570_i2c_scl ; # fast

#============================================================
# SFP+ 1G Referece Clock
#============================================================
# set_instance_assignment -name IO_STANDARD "HCSL" -to phy_clk_clk ; # SFP1G_REFCLK_p
# set_location_assignment PIN_AH6 -to phy_clk_clk ; # SFP1G_REFCLK_p

#============================================================
# Programmable Oscillator CDCM61001/CDCM61004 for SPF1G/SATA
#============================================================
# set_instance_assignment -name IO_STANDARD "2.5 V" -to PLL_SCL
# set_instance_assignment -name IO_STANDARD "2.5 V" -to PLL_SDA
# set_location_assignment PIN_AF32 -to PLL_SCL
# set_location_assignment PIN_AG32 -to PLL_SDA
