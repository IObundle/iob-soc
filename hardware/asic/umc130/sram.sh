#!/bin/bash
source /opt/ic_tools/init/init-memaker-20210111-130LL
memaker -s fsc0l_d -type sj -words $1 -bits 8 -bytes 4 -mux 16 -ds -lib -ver -lef
