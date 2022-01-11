#!/bin/bash
set -e
source /opt/ic_tools/init/init-memaker-20210111-130LL
memaker -s fsc0l_d -type sp -words $1 -bits 32 -mux 1 -rformat hex -romcode boot.hex -ds -lib -ver -lef
