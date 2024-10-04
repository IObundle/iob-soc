# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

UART_DIR:=../..
CORE_DIR:=$(UART_DIR)

NOCLEAN=-name "ug.pdf" -o -name "if.tex" -o -name "td.tex" \
	-o -name "csrs.tex" -o -name "swop.tex" -o -name "inst.tex" \
	-o -name "sim.tex" -o -name "synth.tex" -o -name "custom.tex" \
	-o -name "revhist.tex"

figures:
	mkdir -p ./figures
	cp -r -u lib/document/figures/* ../figures/* ./figures

include $(UART_DIR)/document/document.mk
