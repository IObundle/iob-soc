//init sram/ddr with firmware
`ifdef TESTER_INIT_MEM
 `ifdef TESTER_RUN_EXTMEM
   `define TESTER_DDR_INIT
  `else
   `define TESTER_SRAM_INIT
  `endif
`endif
 
// data bus select bits
`define TESTER_V_BIT (`REQ_W - 1) //valid bit
`define TESTER_E_BIT (`REQ_W - (`TESTER_ADDR_W-`TESTER_E+1)) //extra mem select bit
`define TESTER_P_BIT (`REQ_W - (`TESTER_ADDR_W-`TESTER_P+1)) //peripherals select bit
`define TESTER_B_BIT (`REQ_W - (`TESTER_ADDR_W-`TESTER_B+1)) //boot controller select bit

