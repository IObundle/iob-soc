CC = soffice

all: $(patsubst %.odg,%.png,$(wildcard *.odg))

ifeq ($(shell pgrep soffice), )
%.png: %.odg
	$(CC) --headless --convert-to png $<

else 	
$(error LibreOffice is running. Close it before proceeding.)
endif

clean:
	@rm -f *.png *.pdf bd.png *~


.PHONY: clean all

