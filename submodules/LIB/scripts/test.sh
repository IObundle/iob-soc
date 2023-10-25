#!/usr/bin/env bash

set -e

#find directories containing testbenches
TBS=`find hardware | grep _tb.v | grep -v include`

#extract respective directories
for i in $TBS; do TB_DIRS+=" `dirname $i`" ; done

#extract respective modules - go back from MODULE/hardware/simulation/src
for i in $TB_DIRS; do MODULES+=" `basename $(builtin cd $i/../../..; pwd)`" ; done

#test first argument is "clean", run make clean for all modules and exit
if [ "$1" == "clean" ]; then
    for i in $MODULES; do make clean CORE=$i; done
    exit 0
fi

#test if first argument is test and run all tests
if [ "$1" == "test" ]; then
    for i in $MODULES; do
        make clean setup CORE=$i
        make -C ../${i}_V* sim-run
    done
    exit 0
fi

#test if first argument is "build" and run build for single module
if [ "$1" == "build" ]; then
    make clean setup CORE=$2
    make -C ../$2_V* sim-build
    exit 0
fi

#run single test
make clean setup CORE=$1
make -C ../$1_V* sim-run VCD=$VCD
