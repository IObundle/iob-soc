#!/usr/bin/python

import sys
import subprocess

with open("system.h") as origin:
    for line in origin:
        if not sys.argv[1] in line:
            continue
        else:
            break

line_split = line.split()
line_count = 2**(int(line_split[2])-2)

print line_count
