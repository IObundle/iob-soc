#!/bin/bash
set -e
source /opt/ic_tools/init/init-memaker-20210111-130LL
memaker -s fsc0l_d -type $1 -words $2 -bits $3 -bytes $4 -mux $5 -ds -lib -ver -lef
