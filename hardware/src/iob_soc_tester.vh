`include "iob_soc_conf.vh"
 
// data bus select bits
`define V_BIT (`REQ_W - 1) //valid bit
`define E_BIT (`REQ_W - (ADDR_W-`IOB_SOC_E+1)) //extra mem select bit
`define P_BIT (`REQ_W - (ADDR_W-`IOB_SOC_P+1)) //peripherals select bit
`define B_BIT (`REQ_W - (ADDR_W-`IOB_SOC_B+1)) //boot controller select bit

