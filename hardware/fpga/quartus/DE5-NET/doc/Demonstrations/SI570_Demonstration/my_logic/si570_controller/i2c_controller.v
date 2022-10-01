module i2c_controller(
iCLK,
iRST


);

input			iCLK;
input			iRST;


wire div_clk;

//=========================
// clock divivder for i2c clock 
//=========================

clock_divider u1(
.iCLK(iCLK),
.iRST(iRST),
.oCLK_OUT(div_clk)
);





endmodule 