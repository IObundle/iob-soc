all:
	make -C document/pb pb.pdf
	make -C document/presentation presentation.pdf

clean:
	make -C document/pb clean
	make -C document/presentation clean

pdfclean:
	make -C document/pb pdfclean
	make -C document/presentation pdfclean

.PHONY: all clean pdfclean
