# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile simulates the hardware modules in this repo
#

LIB_DIR:=.
DISABLE_LINT:=1
export DISABLE_LINT
# Default lib module to setup. Can be overriden by the user.
CORE ?=iob_ctls

clean:
	rm -rf ../$(CORE)_V*

setup:
	python3 -B `find . -name '$(CORE).py'` LIB_DIR=$(LIB_DIR)

sim-build:
	scripts/test.sh build $(CORE)

sim-run:
	VCD=$(VCD) scripts/test.sh $(CORE)

sim-test:
	scripts/test.sh test

sim-clean:
	scripts/test.sh clean




