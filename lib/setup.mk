# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a build directory for an IP core
#

# Macro to use Nix-shell if available
# Usage format:
#     $(call IOB_NIX_ENV, <command_to_run>)
ifeq ($(shell which nix),)
$(info Nix-shell not found. Using default shell.)
IOB_NIX_ENV = $(1)
else
IOB_NIX_ENV = nix-shell --run '$(1)'
endif

clean:
	if [ -d "$(BUILD_DIR)" ]; then py2hwsw $(CORE) clean --build_dir '$(BUILD_DIR)'; fi
	@rm -rf ../*.summary ../*.rpt 
	@find . -name \*~ -delete

# Remove all __pycache__ folders with python bytecode
python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune


.PHONY: clean python-cache-clean
