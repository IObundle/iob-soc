all: mem synth #pr

mem:
	make -C memory

synth:
	make -C synth run

pr:
	make -C pr run

sim:
	make -C sim run

clean:
	make -C memory clean
	make -C synth clean
#	make -C pr clean
	make -C sim clean

.PHONY: all mem synth pr sim clean
