ROOT_DIR:=../..
include ../../system.mk

OBJS=$(patsubst %.odg,%.pdf,$(wildcard figures/*.odg))
TRGT=presentation
BIB=$(TRGT).bib

include ../document.mk

figures/%.pdf: figures/%.odg
	make -C figures all

doc-clean:
	make -C figures clean

.PHONY: doc-clean
