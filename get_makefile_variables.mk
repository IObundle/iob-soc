#Call this makfile segment get all VSRC, VHDR and DEFINES, build them and copy them (link) to current directory
#The variable PERIPHERAL_INC_DIR can be provided with a path to a peripheral makefile segment, to get the variables and files from that peripheral

ifneq ($(PERIPHERAL_INC_DIR),)
include $(PERIPHERAL_INC_DIR)
endif

get_vsrc: $(VSRC)
	mkdir -p vsrc
	for p in $(addprefix ",$(addsuffix ",$(VSRC))); do\
		ln -fsr $$p vsrc/;\
	done

get_vhdr: $(VHDR)
	mkdir -p vhdr
	for p in $(addprefix ",$(addsuffix ",$(VHDR))); do\
		ln -fsr $$p vhdr/;\
	done

get_defines:
	echo -n ' $(DEFINE)' >> defines.txt

#Add 'TESTER_' prefix to every define and remove defmacro
get_tester_defines:
	$(eval PREFIX_DEFINES=$(subst $$(defmacro),TESTER_,$(value DEFINE)))echo -n ' $(PREFIX_DEFINES)' >> defines.txt

.PHONY: get_vhdr get_vsrc get_defines get_tester_defines
