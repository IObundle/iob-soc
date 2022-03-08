#!/bin/bash
set -e
source ~/questa_env
vlog $2 $1
vsim $3 -do "run -all;quit"
