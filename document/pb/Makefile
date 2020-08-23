INTEL = 0
XILINX = 1

pb.pdf: pb.tex iob_pb.cls figures/*.odg
	make -C figures
	../get_FPGA_results.sh
	pdflatex '\def\XILINX{$(XILINX)}\def\INTEL{$(INTEL)}\input{$<}'
	pdflatex '\def\XILINX{$(XILINX)}\def\INTEL{$(INTEL)}\input{$<}'

clean:
	@rm -f *~ *.aux *.out *.log *.summary *_results*
	make -C figures clean

pdfclean: clean
	@rm -f *.pdf

.PHONY: clean pdfclean
