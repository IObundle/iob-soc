include $(GPIO_DIR)/hardware/hardware.mk

DEFINE+=$(defmacro)VCD

VSRC+=$(wildcard $(GPIO_TB_DIR)/*.v)
