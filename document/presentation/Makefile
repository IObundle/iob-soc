OBJS = $(patsubst %.odg,%.pdf,$(wildcard drawings/*.odg))
TRGT = presentation

run: $(TRGT).pdf
	evince $< &

$(TRGT).pdf: $(TRGT).tex $(OBJS) $(TRGT).bib
	pdflatex $(TRGT).tex
	pdflatex $(TRGT).tex
	evince $@ &

drawings/%.pdf: drawings/%.odg
	make -C drawings

clean:
	@rm -f $(TRGT).aux $(TRGT).log $(TRGT).dvi $(TRGT).bbl $(TRGT).blg
	@rm -f *.nav *.out *.xml *.snm *.toc $(TRGT)-blx.bib 
	@rm -f *~ *.fls *.fdb_latexmk *.vrb *.aux *.bbl  *.blg  *.log
	make -C figures clean

pdfclean: clean
	@rm $(TRGT).pdf

.PHONY: run clean veryclean

