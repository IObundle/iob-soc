#!/usr/bin/bash
echo `wc -c firmware.bin | head -n1 | cut -d " " -f1`/4|bc
