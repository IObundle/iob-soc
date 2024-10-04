# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

PNGS=$(patsubst %.drom,%.png,$(wildcard *.drom))

all: clean $(PNGS)

%.png: %.svg
	rsvg-convert -b '#ffffff' $< -o $@
	rm -rf *.svg

%.svg: %.drom
	wavedrompy -i $< -s $@

clean:
	rm -rf *.png

.PHONY: all clean
	
