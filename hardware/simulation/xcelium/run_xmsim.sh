#!/bin/bash
source /opt/ic_tools/init/init-xcelium1903-hf013
xmvlog $2 $1
xmelab $3 worklib.system_tb:module
xmsim  $4 worklib.system_tb:module
