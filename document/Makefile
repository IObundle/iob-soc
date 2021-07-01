#
# Makefile for compiling the documentation.
# Tested with the texlive-full Linux package
#

all:
	make -C presentation
	make -C pb

clean:
	make -C presentation clean
	make -C pb

pdfclean:
	make -C presentation pdf clean
	make -C pb pdf clean


.PHONY: all clean pdfclean
