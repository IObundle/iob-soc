# This file becomes the syn makefile when copied to the build
# (c) 2022-Present IObundle, Lda, all rights reserved
#
# directory

SHELL:=bash

include ../../config_build.mk


#include the module's headers and sources
VHDR+=$(wildcard ../src/*.vh) 
VHDR+=$(../simulation/src/bsp.vh) 
VSRC+=$(wildcard ../src/*.v) 


INCLUDE+=.
INCLUDE+=../src
INCLUDE+=../common_src

#include local syn segment
include $(SYNTHESIZER)/build.mk

