setup clean python-cache-clean debug:
	make -f submodules/LIB/setup.mk $@

clean: python-cache-clean

.PHONY: setup clean debug config 
