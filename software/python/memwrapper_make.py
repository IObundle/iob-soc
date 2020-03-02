#!/usr/bin/python

#ram usage: memwrapper_make tech type words bits bytes mux
#rom usage: memwrapper_make tech type words bits mux romcode

import sys

#extract command line arguments

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

# print mem interface 
print "`timescale 1ns / 1ps"
if type == "SH":
    print "module ram #("
elif type == "SP":
    print "module rom #("

print "             parameter ADDR_W = 9,"
print "             parameter FILE = \"rom\""
print "             )"
print "  ("

print "            input clk,"
if type == "SH":
    print "            input rst,"
print "            input ["+str(words-1)+":0] addr,"
if type == "SH":
    print "            input ["+str(bits*bytes-1)+":0] wdata,"
    print "            input ["+str(bytes-1)+":0] wstrb,"
    print "            output ["+str(bits*bytes-1)+":0] rdata,"
    print "            output reg ready,"
elif type == "SP":
    print "            output ["+str(bits-1)+":0] rdata,"

print "            input valid"
print "           );"

# instantiate generated mem

if tech == "LD130":
    if type == "SH":
        print "   "+type+tech+"_"+str(2**words)+"X"+str(bits)+"X"+str(bytes)+"BM"+str(mux)+" #(" 
        print "      .ADDR_W(ADDR_W)"
        print "   ) ram0"
    elif type == "SP":
        print "   "+type+tech+"_"+str(2**words)+"X"+str(bits)+"BM"+str(mux)+"A #("
        print "      .ADDR_W(ADDR_W)"
        print "   ) rom0"

print "   (" 

if type == "SH":
    for i in range(bits*bytes):
        print "    .DO"+str(i)+"(rdata["+str(i)+"]),"
    for i in range(bits*bytes):
        print "    .DI"+str(i)+"(wdata["+str(i)+"]),"
    for i in range(bytes):
        print "    .WEB"+str(i)+"(wstrb["+str(i)+"]),"
    print "    .CS(valid),"
    print "    .OE(valid && !(|wstrb)),"
elif type == "SP":
    for i in range(bits):
        print "    .DO"+str(i)+"(rdata["+str(i)+"]),"
    print "    .OE(valid),"

for i in range(words):
    print "    .A"+str(i)+"(addr["+str(i)+"]),"

print "    .CK(clk)"

print "   );"

# compute the ready signal for ram

if type == "SH":
    print "   always @(posedge clk, posedge rst)"
    print "      if(rst)"
    print "         ready <= 1'b0;"
    print "      else" 
    print "         ready <= valid;"

print "endmodule"
