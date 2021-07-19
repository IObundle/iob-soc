all: $(TRGT).pdf
	evince $< &

$(TRGT).pdf: $(TRGT).tex $(OBJS) $(BIB)
	pdflatex $(TRGT).tex
	pdflatex $(TRGT).tex

clean-all: clean pdf-clean

pdf-clean: clean
	@rm $(TRGT).pdf

clean: doc-clean
	@rm -f $(TRGT).aux $(TRGT).log $(TRGT).dvi $(TRGT).bbl $(TRGT).blg
	@rm -f *.nav *.out *.xml *.snm *.toc $(TRGT)-blx.bib
	@rm -f *~ *.fls *.fdb_latexmk *.vrb *.aux *.bbl  *.blg  *.log

.PHONY: all clean pdf-clean clean-all
