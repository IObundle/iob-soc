SIM_SERVER=$(VIVADO_SERVER)
SIM_USER=$(VIVADO_USER)
SIM_SSH_FLAGS=$(VIVADO_SSH_FLAGS)
SIM_SCP_FLAGS=$(VIVADO_SCP_FLAGS)
SIM_SYNC_FLAGS=$(VIVADO_SYNC_FLAGS)

SFLAGS = --runall
EFLAGS = --snapshot

VFLAGS+= -sv 

ifneq ($(wildcard ../src),)
VFLAGS+=-i . -i ../src
endif

ifneq ($(wildcard src),)
VFLAGS+=-i ./src
endif

ifneq ($(wildcard hardware/src),)
VFLAGS+=-i hardware/src
endif

ifeq ($(VCD),1)
VFLAGS+=-d VCD
endif

ifeq ($(SYN),1)
VFLAGS+=-d SYN
endif

xvlog.log: $(VHDR) $(VSRC) $(HEX)
	xvlog $(VFLAGS) $(VSRC)

xelab.log : xvlog.log 
	xelab $(EFLAGS) worklib $(NAME)_tb

comp: xelab.log

exec: comp
	sync && sleep 2 && xsim $(SFLAGS) worklib

clean: gen-clean
	@rm -f xelab.log  xsim.log  xvlog.log webtalk* xelab.pb xvlog.pb xsim.jou

very-clean: clean

.PHONY: comp exec clean very-clean

