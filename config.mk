TOP_MODULE=iob_axistream_in

#PATHS
REMOTE_ROOT_DIR ?=sandbox/iob-axistream-in
SIM_DIR ?=$(AXISTREAMIN_HW_DIR)/simulation
FPGA_DIR ?=$(shell find $(AXISTREAMIN_DIR)/hardware -name $(FPGA_FAMILY))
DOC_DIR ?=$(AXISTREAMIN_DIR)/document/$(DOC)

LIB_DIR ?=$(AXISTREAMIN_DIR)/submodules/LIB
MEM_DIR ?=$(AXISTREAMIN_DIR)/submodules/MEM
AXISTREAMIN_HW_DIR:=$(AXISTREAMIN_DIR)/hardware

#MAKE SW ACCESSIBLE REGISTER
MKREGS:=$(shell find $(LIB_DIR) -name mkregs.py)

#DEFAULT FPGA FAMILY AND FAMILY LIST
FPGA_FAMILY ?=CYCLONEV-GT
FPGA_FAMILY_LIST ?=CYCLONEV-GT XCKU

#DEFAULT DOC AND doc LIST
DOC ?=pb
DOC_LIST ?=pb ug

# VERSION
VERSION ?=V0.1
$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt

#cpu accessible registers
iob_axistream_in_swreg_def.vh iob_axistream_in_swreg_gen.vh: $(AXISTREAMIN_DIR)/mkregs.conf
	$(MKREGS) iob_axistream_in $(AXISTREAMIN_DIR) HW
	#Hack to modify iob_axistream_in_swreg_gen.vh to allow bypassing mkregs.py generated logic
	LINE=`grep -n -F "//read registers" iob_axistream_in_swreg_gen.vh | cut -d : -f 1`; \
	sed -i "$$LINE,\$$d" iob_axistream_in_swreg_gen.vh

axistream-in-gen-clean:
	@rm -rf *# *~ version.txt

.PHONY: axistream-in-gen-clean
