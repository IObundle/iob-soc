FPGA_OBJ=top_system.sof
FPGA_LOG=quartus.log

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)

include ../../fpga.mk

#axi interconnect
ifeq ($(USE_DDR),1)
VSRC+=$(AXI_DIR)/submodules/V_AXI/rtl/axi_interconnect.v
VSRC+=$(AXI_DIR)/submodules/V_AXI/rtl/arbiter.v
VSRC+=$(AXI_DIR)/submodules/V_AXI/rtl/priority_encoder.v
endif

local-build: $(QIP_FILE)
	$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh quartus_sh -t ../top_system.tcl "$(incdir)vhdr" "$(addprefix $(defmacro),$(shell cat defines.txt))" "$(wildcard vsrc/*)"
	mv output_files/top_system.sof $(FPGA_OBJ)
	mv output_files/top_system.fit.summary $(FPGA_LOG)

clean: clean-all
	@rm -rf db/ incremental_db/ output_files/ \
	*.qdf *.sof *.sld *.qpf *.qsf *.txt

clean-ip:
	rm -rf qsys/alt_ddr3 qsys/alt_ddr3.sopcinfo

veryclean: clean clean-ip

