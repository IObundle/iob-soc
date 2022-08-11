# core name
NAME=iob_soc
# core version 
VERSION=0010
# top-leel module
TOP_MODULE?=system
# core path as seen from LIB's makefile
ROOT_DIR=$(CORE_DIR)

SETUP_SIM=1
SETUP_FPGA=0
SETUP_DOC=0
SETUP_PPROC=0

# Needed by software/simulation.mk to generate periphs_tmp.h
PERIPHERALS:=UART

#address selection bits
E:=31 #extra memory bit
P:=30 #periphs
B:=29 #boot controller
