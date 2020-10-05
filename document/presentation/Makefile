OBJS = $(patsubst %.odg,%.pdf,$(wildcard drawings/*.odg))
TRGT = main
#BIB = ./bibtex/BIBfile.bib

run: $(TRGT).pdf

$(TRGT).pdf: $(TRGT).tex $(OBJS) $(BIB)
	latexmk -pdf $(TRGT).tex
	evince $@ &

drawings/%.pdf: drawings/%.odg
	make -C drawings

clean:
	@rm -f $(TRGT).aux $(TRGT).log $(TRGT).dvi $(TRGT).bbl $(TRGT).blg
	@rm -f *.nav *.out *.xml *.snm *.toc $(TRGT)-blx.bib 
	@rm -f *~ *.fls *.fdb_latexmk *.vrb
	make -C figures clean

pdfclean: clean
	@rm $(TRGT).pdf

.PHONY: run clean veryclean

