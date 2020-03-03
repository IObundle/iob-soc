CASE=TC
ROM_DIR=../memory/bootrom
RAM_DIR=../memory/bootram

all:
	cp $(ROM_DIR)/*$(CASE).lib $(RAM_DIR)/*$(CASE).lib .
	./pr.sh
clean:
	rm -rf libscore_work celtic 
	rm -f encounter.* *~ *.lib .holdtw.typical_view*
	rm -rf system* timingReports
