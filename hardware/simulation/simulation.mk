include $(REGFILEIF_DIR)/hardware/hardware.mk

DEFINE+=$(defmacro)VCD

VSRC+=$(wildcard $(REGFILEIF_TB_DIR)/*.v)
