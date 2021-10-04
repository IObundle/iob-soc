all: rom ram

rom:
	make -C bootrom	run

ram:
	make -C sram run

clean:
	make -C bootrom	clean
	make -C sram clean

.PHONY: all rom ram clean
