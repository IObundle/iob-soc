# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a build directory for an IP core
#

build-setup: format-all
ifeq ($(IOB_PYTHONPATH),)
	$(error "IOB_PYTHONPATH is not set")
endif
	mkdir -p $(IOB_PYTHONPATH)
	find $(LIB_DIR) -name \*.py -exec cp -u {} $(IOB_PYTHONPATH) \;
	python3 -B ./$(CORE).py $(SETUP_ARGS)

python-format:
	$(LIB_DIR)/scripts/sw_format.py black . 
ifneq ($(wildcard $(BUILD_DIR)),)
	$(LIB_DIR)/scripts/sw_format.py black $(BUILD_DIR) 
endif

c-format:
	$(LIB_DIR)/scripts/sw_format.py clang .
ifneq ($(wildcard $(BUILD_DIR)),)
	$(LIB_DIR)/scripts/sw_format.py clang $(BUILD_DIR)
endif

# Auto-disable linter and formatter if setting up with the Tester
ifeq ($(TESTER),1)
	DISABLE_LINT:=1
	DISABLE_FORMAT:=1
endif

# Verilog files in build directory
verilog_files:
	$(eval VHFILES = $(shell find $(BUILD_DIR)/hardware -type f -name "*.vh" -not -path "*version.vh" -not -path "*test_*.vh"))
	$(eval VFILES = $(shell find $(BUILD_DIR)/hardware -type f -name "*.v"))

# Run linter on all verilog files
verilog-lint: verilog_files
ifneq ($(DISABLE_LINT),1)
	$(LIB_DIR)/scripts/verilog-lint.py $(VHFILES) $(VFILES)
endif

# Run formatter on all verilog files
verilog-format: verilog-lint
ifneq ($(DISABLE_FORMAT),1)
	$(LIB_DIR)/scripts/verilog-format.sh $(VHFILES) $(VFILES)
endif

format-all: python-format c-format verilog-lint verilog-format

clean:
ifneq ($(wildcard $(BUILD_DIR)),)
	python3 -B ./$(CORE).py clean
endif
	@rm -rf $(IOB_PYTHONPATH)
	@rm -rf ../*.summary ../*.rpt 
	@find . -name \*~ -delete

# Remove all __pycache__ folders with python bytecode
python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune


.PHONY: build-setup clean c-format python-format verilog-format
