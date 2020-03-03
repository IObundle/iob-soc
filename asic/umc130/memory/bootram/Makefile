all:
	../gen_bootram.sh
	sed -i 's/ME\([0-9]\)/metal\1/g' *.lef
clean:
	@find . -type f -not -name Makefile -delete

.PHONY: all clean 
