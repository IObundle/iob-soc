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
        core_dir=`find -name ${i}.py | xargs dirname`
        make clean CORE=$i TOP_MODULE_NAME=$i CORE_DIR=$core_dir
    done
    exit 0
fi

#test if first argument is test and run all tests
if [ "$1" == "test" ]; then
    for i in $MODULES; do
        # echo "$i"
        core_dir=`find -name ${i}.py | xargs dirname`
        # echo "Running test for $core_dir"
        make -f ${LIB_DIR}/Makefile clean build-setup CORE=$i TOP_MODULE_NAME=$i CORE_DIR=$core_dir
        make -C ../${i}_V* sim-run
    done
    exit 0
fi

#test if first argument is "build" and run build for single module
if [ "$1" == "build" ]; then
    core_dir=`find -name $2.py | xargs dirname`
    make clean build-setup CORE=$2 TOP_MODULE_NAME=$2 CORE_DIR=$core_dir
    make -C ../$2_V* sim-build
    exit 0
fi

#run single test
core_dir=`find -name $1.py | xargs dirname`
make clean build-setup CORE=$1 TOP_MODULE_NAME=$1 CORE_DIR=$core_dir
make -C ../$1_V* sim-run VCD=$VCD
