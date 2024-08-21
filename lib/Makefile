# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile simulates the hardware modules in this repo
#


LIB_DIR:=.
export LIB_DIR

PATH:=$(PATH):$(LIB_DIR)/scripts
export PATH

PROJECT_ROOT=..
export PROJECT_ROOT

DISABLE_LINT:=1
export DISABLE_LINT
DISABLE_FORMAT:=1

# Default lib module to setup. Can be overriden by the user.
CORE ?=iob_ctls


all: sim-test

CUSTOM_SHELL ?=nix-shell --run "$(1)"

# Pass 'py2hwsw' function to shell using workaround: https://stackoverflow.com/a/26518222
# The function is only needed for debug (when not using the version from nix-shell)
# To debug py2hwsw using a local version, you can override the 'py2hwsw' bin path using the following commands:
#   py2hwsw () { <path_to_custom_py2hwsw_repo>/py2hwsw/scripts/py2hwsw.py $@; }
#   export -f py2hwsw
BUILD_DIR ?= $(shell $(call CUSTOM_SHELL, py2hwsw='$(py2hwsw)' py2hwsw $(CORE) print_build_dir))

setup:
	$(call CUSTOM_SHELL, py2hwsw $(CORE) setup --project_root $(PROJECT_ROOT) --build_dir '$(BUILD_DIR)' --no_verilog_lint)

sim-build:
	$(call CUSTOM_SHELL, scripts/test.sh build $(CORE))

sim-run:
	$(call CUSTOM_SHELL, VCD=$(VCD) scripts/test.sh $(CORE))

sim-test:
	$(call CUSTOM_SHELL, scripts/test.sh test)

sim-clean:
	$(call CUSTOM_SHELL, scripts/test.sh clean)

print-attr:
	$(call CUSTOM_SHELL, VCD=$(VCD) SETUP_ARGS='print_attr' scripts/test.sh $(CORE))


.PHONY: all setup sim-build sim-run sim-test sim-clean


# Install board server and client
board_server_install:
	sudo cp scripts/board_client.py /usr/local/bin/ && \
	sudo cp scripts/board_server.py /usr/local/bin/ && \
        sudo cp scripts/board_server.service /etc/systemd/system/ && \
        sudo systemctl daemon-reload && \
	sudo systemctl enable board_server && \
	sudo systemctl restart board_server

board_server_uninstall:
	sudo systemctl stop board_server && \
        sudo systemctl disable board_server && \
        sudo rm /usr/local/bin/board_client.py && \
        sudo rm /usr/local/bin/board_server.py && \
        sudo rm /etc/systemd/system/board_server.service && \
        sudo systemctl daemon-reload

board_server_status:
	sudo systemctl status board_server

.PHONY: board_server_install board_server_uninstall board_server_status


clean:
	$(call CUSTOM_SHELL, py2hwsw $(CORE) clean --build_dir '$(BUILD_DIR)')
	@rm -rf ../*.summary ../*.rpt 
	@find . -name \*~ -delete

.PHONY: clean
