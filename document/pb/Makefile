include ../../system.mk


INTEL = 0
XILINX = 1

run: pb.pdf

pb.pdf: pb.tex iob_pb.cls figures/*.odg
	make -C figures
	../fpga2tex.sh $(COMPILE_SERVER)
	pdflatex '\def\XILINX{$(XILINX)}\def\INTEL{$(INTEL)}\input{$<}'
	pdflatex '\def\XILINX{$(XILINX)}\def\INTEL{$(INTEL)}\input{$<}'

clean:
	@rm -f *~ *.aux *.out *.log *.summary *_results*
	make -C figures clean

pdfclean: clean
	@rm -f *.pdf

.PHONY: clean pdfclean
