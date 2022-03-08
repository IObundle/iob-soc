#  DO NOT REMOVE THIS HEADER
#  
#  This file is owned by company IObundle, Lda,
#  incorporated under the laws of Portugal.
#  
#  If you have this file, you must also have a License Agreement
#  signed with IObundle, Lda.
#  
#  Please refer to the License Agreement text for instructions
#  on how to legally use the contents of this file.
#  
#  © 2022 Copyright Iobundle, Lda. All rights reserved
ROOT_DIR:=../../..

defmacro:=+define+
incdir:=+incdir+

SIMULATOR=modelsim
SIM_SERVER=$(MODELSIM_SERVER)
SIM_USER=$(MODELSIM_USER)
SIM_SSH_FLAGS=$(MODELSIM_SSH_FLAGS)
SIM_SYNC_FLAGS=$(MODELSIM_SYNC_FLAGS)
SIM_PROC=vsimk

include ../simulation.mk
## SYNTHESIS MACROS
#DEFINES += +define+IN_FIFO_DEPTH_LOG2=11
#DEFINES += +define+OUT_FIFO_DEPTH_LOG2=11
#DEFINES += +define+ANCI_FIFO_DEPTH_LOG2=11
#DEFINES += +define+MAX_IMAGE_WIDTH_LOG2=13
##DEFINES += +define+MAX_IMAGE_WIDTH_BYTES_LOG2=13
#DEFINES += +define+MAX_LZ77_SLIDING_WINDOW_LEN_BYTES_LOG2=15
#DEFINES += +define+VCD=1



##IMAGE TO BE DECODED
#INPUT_IMG=input.png
##DECODED IMAGE
#OUTPUT_IMG=output.raw

#INCLUDE=+incdir+../src

#VSRC=$(wildcard ../src/*.v) $(wildcard *.v)


#simulator command
#VLOG = vlog iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE)
VLOG = vlog -sv $(INCLUDE) $(DEFINE)
CFLAGS = -sv $(INCLUDE) $(DEFINE)
SFLAGS = -voptargs="+acc" -c system_tb

.PHONY: all clean debug $(MACRO_LIST)

run: $(VSRC) $(VHDR) $(MACRO_LIST)
	echo $(MODELSIM_SERVER)
	./run_vsim.sh "$(VSRC)" "$(CFLAGS)" "$(SFLAGS)"

clean: clean-remote
	@rm -f a.out

debug:
	@echo $(INCLUDE)
	@echo $(VSRC)
