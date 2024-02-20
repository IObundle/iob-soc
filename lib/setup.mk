# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a build directory for an IP core
#
export PYTHONPATH=../iob_python

build-setup: format-all
	mkdir -p ../iob_python
	find . -name \*.py -exec cp -u {} ../iob_python \;
	python3 -B ./iob_soc.py $(SETUP_ARGS)

python-format:
	lib/scripts/sw_format.py black . 
ifneq ($(wildcard $(BUILD_DIR)),)
	lib/scripts/sw_format.py black $(BUILD_DIR) 
endif

c-format:
	lib/scripts/sw_format.py clang .
ifneq ($(wildcard $(BUILD_DIR)),)
	lib/scripts/sw_format.py clang $(BUILD_DIR)
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
	./lib/scripts/verilog-lint.py $(VHFILES) $(VFILES)
endif

# Run formatter on all verilog files
verilog-format: verilog-lint
ifneq ($(DISABLE_FORMAT),1)
	./lib/scripts/verilog-format.sh $(VHFILES) $(VFILES)
endif

format-all: python-format c-format verilog-lint verilog-format

clean:
	export BUILD_DIR = `python3 -B ./$(CORE).py -f print_build_dir_name`
	echo $(BUILD_DIR)
#	-@if [ -f $(BUILD_DIR)/Makefile ]; then make -C $(BUILD_DIR) clean; fi
#	@rm -rf ../*.summary ../*.rpt $(BUILD_DIR)*  ~*

# Remove all __pycache__ folders with python bytecode
python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune


.PHONY: build-setup clean c-format python-format verilog-format
