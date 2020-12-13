#!/usr/bin/python

#ram usage: memwrapper_make tech type words bits bytes mux
#rom usage: memwrapper_make tech type words bits mux romcode

import sys

#
# extract command line arguments
#

if sys.argv[1] == "fsc0l_d":
    tech = "LD130"
    if sys.argv[2] == "sh":
        type = "SH"
        bits = int(sys.argv[4])
        bytes = int(sys.argv[5])
        mux = int(sys.argv[6])
    elif sys.argv[2] == "sp":
        type = "SP"
        bits = int(sys.argv[4])
        mux = int(sys.argv[5])
    else:
        sys.exit("Unsupported memory type")
else:
    sys.exit("Unsupported memory technology")

words = int(sys.argv[3])

#
# print time scale
#

print "`timescale 1ns / 1ps"
print ""

#
# print mem interface
#

if type == "SH":
    print "module sram"
    print "  #("
    print "    parameter FILE = \"none\""
elif type == "SP":
    print "module sp_rom"
    print "  #("
    print "    parameter DATA_W = 8,"
    print "    parameter ADDR_W = 9,"
    print "    parameter FILE = \"rom.dat\""
print "    )"
print "  ("
print "            input clk,"
if type == "SH":
    print "            input rst,"
    print ""
    #
    # instruction port
    #
    print "            input i_valid,"
    print "            input ["+str(words-1)+":0] i_addr,"
    print "            input ["+str(bits*bytes-1)+":0] i_wdata,"
    print "            input ["+str(bytes-1)+":0] i_wstrb,"
    print "            output ["+str(bits*bytes-1)+":0] i_rdata,"
    print "            output reg i_ready,"
    print ""
    #
    # data port
    #
    print "            input d_valid,"
    print "            input ["+str(words-1)+":0] d_addr,"
    print "            input ["+str(bits*bytes-1)+":0] d_wdata,"
    print "            input ["+str(bytes-1)+":0] d_wstrb,"
    print "            output ["+str(bits*bytes-1)+":0] d_rdata,"
    print "            output reg d_ready"
elif type == "SP":
    print ""
    print "            input ["+str(words-1)+":0] addr,"
    print "            output ["+str(bits-1)+":0] rdata,"
    print "            input r_en"
print "           );"
print ""

#
# mux signals for ram
#

if type == "SH":
    print "   wire valid = i_valid? i_valid: d_valid;"
    print "   wire ["+str(words-1)+":0] addr = i_valid? i_addr: d_addr;"
    print "   wire ["+str(bits*bytes-1)+":0] wdata = i_valid? i_wdata: d_wdata;"
    print "   wire ["+str(bytes-1)+":0] wstrb = i_valid? i_wstrb: d_wstrb;"
    print "   wire ["+str(bits*bytes-1)+":0] rdata;"
    print "   wire ["+str(bytes-1)+":0] wstrb_int = ~wstrb;"
    print "   wire oe = 1'b1; //valid & ~(|wstrb);"
    print "   assign i_rdata = rdata;"
    print "   assign d_rdata = rdata;"
    print ""

if type == "SP":
    print "   wire oe = 1'b1; //r_en;"

#
# instantiate generated mem
#

if tech == "LD130":
    if type == "SH":
        print "   "+type+tech+"_"+str(2**words)+"X"+str(bits)+"X"+str(bytes)+"BM"+str(mux)+" ram0" 
    elif type == "SP":
        print "   "+type+tech+"_"+str(2**words)+"X"+str(bits)+"BM"+str(mux)+"A rom0"

print "   (" 

if type == "SH":
    for i in range(bits*bytes):
        print "    .DO"+str(i)+"(rdata["+str(i)+"]),"
    for i in range(bits*bytes):
        print "    .DI"+str(i)+"(wdata["+str(i)+"]),"
    for i in range(bytes):
        print "    .WEB"+str(i)+"(wstrb_int["+str(i)+"]),"
    print "    .CS(valid),"
    print "    .OE(oe),"
elif type == "SP":
    for i in range(bits):
        print "    .DO"+str(i)+"(rdata["+str(i)+"]),"
    print "    .CS(r_en),"
    print "    .OE(oe),"

for i in range(words):
    print "    .A"+str(i)+"(addr["+str(i)+"]),"

print "    .CK(clk)"

print "   );"
print ""

#
# compute the ready signals for ram
#

if type == "SH":
    print "   always @(posedge clk, posedge rst)"
    print "      if (rst) begin"
    print "         i_ready <= 1'b0;"
    print "         d_ready <= 1'b0;"
    print "      end else begin"
    print "         i_ready <= i_valid;"
    print "         if (~i_valid)"
    print "            d_ready <= d_valid;"
    print "      end"
    print ""

print "endmodule"
