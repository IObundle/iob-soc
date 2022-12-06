CONF_NAME ?= base

setup clean python-cache-clean debug:
	make -f submodules/LIB/setup.mk $@

config:
	submodules/LIB/scripts/hw_defines.py hardware/src/iob_soc_conf_$(CONF_NAME).vh $(SOC_DEFINE)

.PHONY: setup clean debug config 
