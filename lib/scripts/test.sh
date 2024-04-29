#!/usr/bin/env bash

set -e

#find directories containing testbenches
TBS=`find ${LIB_DIR}/hardware | grep _tb.v | grep -v include`

#extract respective directories
for i in $TBS; do TB_DIRS+=" `dirname $i`" ; done

#extract respective modules - go back from MODULE/hardware/simulation/src
for i in $TB_DIRS; do MODULES+=" `basename $(builtin cd $i/../../..; pwd)`" ; done

#test first argument is "clean", run make clean for all modules and exit
if [ "$1" == "clean" ]; then
    for i in $MODULES; do 
        DEFAULT_BUILD_DIR=`./scripts/py2hwsw.py $i print_build_dir`
        make clean CORE=$i BUILD_DIR=../${DEFAULT_BUILD_DIR}
    done
    exit 0
fi

#test if first argument is test and run all tests
if [ "$1" == "test" ]; then
    for i in $MODULES; do
        echo -e "\n\033[1;33mTesting module '${i}'\033[0m"
        DEFAULT_BUILD_DIR=`./scripts/py2hwsw.py $i print_build_dir`
        make -f ${LIB_DIR}/Makefile clean setup CORE=$i BUILD_DIR=../${DEFAULT_BUILD_DIR}
        make -C ../${DEFAULT_BUILD_DIR} sim-run
    done
    exit 0
fi

#test if first argument is "build" and run build for single module
if [ "$1" == "build" ]; then
    DEFAULT_BUILD_DIR=`./scripts/py2hwsw.py $2 print_build_dir`
    make clean setup CORE=$2 BUILD_DIR=../${DEFAULT_BUILD_DIR}
    make -C ../${DEFAULT_BUILD_DIR} sim-build
    exit 0
fi

#run single test
DEFAULT_BUILD_DIR=`./scripts/py2hwsw.py $1 print_build_dir`
make clean setup CORE=$1 BUILD_DIR=../${DEFAULT_BUILD_DIR}
make -C ../${DEFAULT_BUILD_DIR} sim-run VCD=$VCD
