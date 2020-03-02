#!/usr/bin/python

import sys

with open("system.h") as origin:
    for line in origin:
        if not sys.argv[1] in line:
            continue
        else:
            break

line_split = line.split()
line_count_log2 = int(line_split[2])-2
line_count = 2**line_count_log2

if len(sys.argv)==3 and sys.argv[2]=="log2":
    print line_count_log2
else:
    print line_count
