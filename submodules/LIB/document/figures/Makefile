LO_RUNNING = $(shell pgrep libreoffice)

PDF = $(patsubst %.odg,%.pdf,$(wildcard *.odg))
PDF += $(patsubst %.drom,%.pdf,$(wildcard *.drom))

SVG = $(patsubst %.drom,%.svg,$(wildcard *.drom))

.PHONY: figs clean debug

pb_figs: bg.pdf bd.pdf

figs: $(PDF)

#make libreoffice figures
ifeq ($(LO_RUNNING), )
%.pdf : %.odg
	soffice --headless --convert-to pdf $<
else 	
$(error LibreOffice is running. Close it before proceeding.)
endif

#make wavedrom figures
%.pdf: %.svg
	rsvg-convert $< > $@

%.svg: %.drom
	wavedrompy -i $< -s $@

clean:
	@rm -f *.pdf *.svg *~

debug:
	@echo $(SVG)
	@echo $(PDF)
