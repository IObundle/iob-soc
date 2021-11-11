#!/usr/bin/python3

from sys import argv

binfile = argv[1]
mem_size = 2**(int(argv[2]))

with open(binfile, "rb") as f:
    bindata = f.read()

assert len(bindata) <= mem_size
assert len(bindata) % 4 == 0

num_hex_lines = len(bindata)//4

for i in range(mem_size//4):
    if i < (num_hex_lines):
        print('%02x%02x%02x%02x' % (bindata[4*i+3], bindata[4*i+2], bindata[4*i+1], bindata[4*i+0]))
    else:
        print("00000000")

