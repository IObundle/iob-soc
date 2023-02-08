// data bus select bits
`define V_BIT (`REQ_W - 1) //valid bit
`define E_BIT (`REQ_W - (ADDR_W-E_BIT+1)) //extra mem select bit
`define P_BIT (`REQ_W - (ADDR_W-P_BIT+1)) //peripherals select bit
`define B_BIT (`REQ_W - (ADDR_W-B_BIT+1)) //boot controller select bit
