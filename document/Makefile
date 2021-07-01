#
# Makefile for compiling the documentation.
# Tested with the texlive-full Linux package
#

all:
	make -C presentation all
	make -C pb

clean:
	make -C presentation clean
	make -C pb

clean-all:
	make -C presentation clean-all
	make -C pb pdf clean


.PHONY: all clean clean-all
