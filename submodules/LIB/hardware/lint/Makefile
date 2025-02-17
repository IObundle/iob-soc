# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

SHELL:=bash

include ../../config_build.mk

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_LINT_DIR=$(REMOTE_BUILD_DIR)/hardware/lint

LINTER?=verilator
LINT_TOP=$(NAME)

VHDR=$(wildcard ../src/*.vh)
VSRC=$(wildcard ../src/*.v)

$(NAME)_files.list: $(VSRC)

$(VSRC):
	@ls $@ >> $(NAME)_files.list

#include local lint segment
ifneq ($(wildcard lint_build.mk),)
include lint_build.mk
endif

include $(LINTER).mk

run: clean $(NAME)_files.list
	make run-lint LINTER=$(LINTER)

clean:
	make clean-lint LINTER=$(LINTER)

.PHONY: run $(VSRC) clean
