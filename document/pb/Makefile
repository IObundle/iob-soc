include ../../system.mk


INTEL = 1
XILINX = 1

run: pb.pdf

pb.pdf: pb.tex iob_pb.cls figures/*.odg
	make -C figures
	../fpga2tex.sh $(COMPILE_SERVER) $(REMOTE_ROOT_DIR)/$(HW_DIR) $(INTEL) $(XILINX)
	pdflatex '\def\XILINX{$(XILINX)}\def\INTEL{$(INTEL)}\input{$<}'
	pdflatex '\def\XILINX{$(XILINX)}\def\INTEL{$(INTEL)}\input{$<}'
	evince $@ &

clean:
	@rm -f *~ *.aux *.out *.log *.summary *_results*
	make -C figures clean

pdfclean: clean
	@rm -f *.pdf

.PHONY: clean pdfclean
