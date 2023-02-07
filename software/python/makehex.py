#!/usr/bin/env python3

from sys import argv

binfile = argv[1]
nwords = 2**(int(argv[2])-2)

with open(binfile, "rb") as f:
    bindata = f.read()

assert len(bindata) <= 4*nwords
assert len(bindata) % 4 == 0

for i in range(nwords):
    if i < len(bindata) // 4:
        w = str(bindata)
        print('%02x%02x%02x%02x' % (ord(w[4*i+3]), ord(w[4*i+2]), ord(w[4*i+1]), ord(w[4*i+0])))
    else:
        print("00000000")

