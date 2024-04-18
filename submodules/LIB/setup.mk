# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a build directory for an IP core
#

TOP_MODULE_NAME ?=$(basename $(wildcard *.py))
PROJECT_ROOT ?=.

LIB_DIR ?=submodules/LIB
SETUP_ARGS += LIB_DIR=$(LIB_DIR)

# python scripts directory
PYTHON_DIR=$(LIB_DIR)/scripts

# establish build dir paths
build_dir_name:
	$(eval BUILD_DIR := $(shell $(PYTHON_DIR)/bootstrap.py $(TOP_MODULE_NAME) $(SETUP_ARGS) -f get_build_dir -s $(PROJECT_ROOT)))
	if [ $(.SHELLSTATUS) -ne 0 ]; then exit 1; fi
	$(eval BUILD_VSRC_DIR = $(BUILD_DIR)/hardware/src)
	$(eval BUILD_SIM_DIR := $(BUILD_DIR)/hardware/simulation)
	$(eval BUILD_FPGA_DIR = $(BUILD_DIR)/hardware/fpga)	
	$(eval BUILD_SYN_DIR = $(BUILD_DIR)/hardware/syn)
	$(eval BUILD_DOC_DIR = $(BUILD_DIR)/document)
	$(eval BUILD_FIG_DIR = $(BUILD_DOC_DIR)/figures)
	$(eval BUILD_TSRC_DIR = $(BUILD_DOC_DIR)/tsrc)
	@echo $(BUILD_DIR)

build_top_module:
	./$(PYTHON_DIR)/bootstrap.py $(TOP_MODULE_NAME) $(SETUP_ARGS) -s $(PROJECT_ROOT)

python-lint: build_dir_name
	$(LIB_DIR)/scripts/sw_tools.py mypy . 

python-format: build_dir_name
	$(LIB_DIR)/scripts/sw_tools.py black . 
ifneq ($(wildcard $(BUILD_DIR)),)
	$(LIB_DIR)/scripts/sw_tools.py black $(BUILD_DIR) 
endif

c-format: build_dir_name
	$(LIB_DIR)/scripts/sw_tools.py clang .
ifneq ($(wildcard $(BUILD_DIR)),)
	$(LIB_DIR)/scripts/sw_tools.py clang $(BUILD_DIR)
endif

IOB_LIB_PATH=$(LIB_DIR)/scripts
export IOB_LIB_PATH

# Auto-disable linter and formatter if setting up with the Tester
ifeq ($(TESTER),1)
	DISABLE_LINT:=1
	DISABLE_FORMAT:=1
endif

# Verilog files in build directory
verilog_files: build_dir_name
	$(eval VHFILES = $(shell find $(BUILD_DIR)/hardware -type f -name "*.vh" -not -path "*version.vh" -not -path "*test_*.vh"))
	$(eval VFILES = $(shell find $(BUILD_DIR)/hardware -type f -name "*.v"))

# Run linter on all verilog files
verilog-lint: verilog_files
ifneq ($(DISABLE_LINT),1)
	$(IOB_LIB_PATH)/verilog-lint.py $(VHFILES) $(VFILES)
endif

# Run formatter on all verilog files
verilog-format: verilog-lint
ifneq ($(DISABLE_FORMAT),1)
	$(IOB_LIB_PATH)/verilog-format.sh $(VHFILES) $(VFILES)
endif

format-all: build_dir_name python-lint python-format c-format verilog-lint verilog-format

clean: build_dir_name
	-@if [ -f $(BUILD_DIR)/Makefile ]; then make -C $(BUILD_DIR) clean; fi
	# replace [top_module]_V[version] by [top_module]_V
	$(eval CLEAN_DIR=$(shell echo $(BUILD_DIR) | sed 's/_V[0-9]\+\.[0-9]\+$$/_V/'))
	@rm -rf ../*.summary ../*.rpt $(CLEAN_DIR)*  ~*

# Remove all __pycache__ folders with python bytecode
python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune

build-setup: build_dir_name build_top_module $(SRC) format-all
	@for i in $(SRC); do echo $$i; done


.PHONY: build-setup clean c-format python-lint python-format verilog-format
