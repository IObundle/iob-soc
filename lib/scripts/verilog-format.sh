#!/usr/bin/env bash
# run the command below for all files given as command line arguments

set -e 
if [ "$#" -eq 0 ]; then
    echo "No files specified."
    exit 0
fi

verible-verilog-format --inplace $(cat "$IOB_LIB_PATH/verible-format.rules" | tr '\n' ' ') "$@"
