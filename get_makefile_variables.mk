#Call this makfile segment get all VSRC, VHDR and DEFINES, build them and copy them (link) to current directory
#The variable PERIPHERAL_INC_DIR can be provided with a path to a peripheral makefile segment, to get the variables and files from that peripheral

ifneq ($(PERIPHERAL_INC_DIR),)
include $(PERIPHERAL_INC_DIR)
endif

# Get all Verilog sources defined
get_vsrc: $(VSRC)
	mkdir -p vsrc
	for p in $(addprefix ",$(addsuffix ",$(VSRC))); do\
		ln -fsr $$p vsrc/;\
	done

# Get all Verilog headers defined
get_vhdr: $(VHDR)
	mkdir -p vhdr
	for p in $(addprefix ",$(addsuffix ",$(VHDR))); do\
		ln -fsr $$p vhdr/;\
	done

# Get all Verilog macros defined
get_defines:
	echo -n ' $(DEFINE)' >> defines.txt

# Get top module file location based on TOP_MODULE variable
get_top_module:
	echo $(TOP_MODULE)
	echo -n '$(filter %/$(TOP_MODULE) %/$(TOP_MODULE).v, $(VSRC))'

#Add 'TESTER_' prefix to every define and remove defmacro
get_tester_defines:
	#Make sure DDR_ADDR_W is not empty (it is required to build the system)
	$(if $(DDR_ADDR_W),,$(eval DDR_ADDR_W=30))
	#Write Tester defines
	$(eval PREFIX_DEFINES=$(subst $$(defmacro),TESTER_,$(value DEFINE)))echo -n ' $(PREFIX_DEFINES)' >> defines.txt
	#Override USE_DDR, RUN_EXTMEM, INIT_MEM, DDR_ADDR_W, DDR_DATA_W, IS_CYCLONEV, SIM, BAUD, FREQ defines of UUT with the ones from Tester
	$(eval PREFIX_DEFINES=$(filter USE_DDR RUN_EXTMEM INIT_MEM DDR_ADDR_W=% DDR_DATA_W=% IS_CYCLONEV SIM=% BAUD=% FREQ=%,$(subst $$(defmacro),,$(value DEFINE))))echo -n ' $(PREFIX_DEFINES)' >> defines.txt

.PHONY: get_vhdr get_vsrc get_defines get_top_module get_tester_defines
