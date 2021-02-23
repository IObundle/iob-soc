#!/usr/bin/python

from sys import argv

binfile = argv[1]
mem_size = 2**(int(argv[2]))

with open(binfile, "rb") as f:
    bindata = f.read()

assert len(bindata) <= mem_size
assert len(bindata) % 4 == 0

for i in range(mem_size/4):
    if i < (len(bindata)/4):
        w = bindata
        print('%02x%02x%02x%02x' % (ord(w[4*i+3]), ord(w[4*i+2]), ord(w[4*i+1]), ord(w[4*i+0])))
    else:
        print("00000000")

