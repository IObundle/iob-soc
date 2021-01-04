all: mem synth #pr

mem:
	make -C memory

synth:
	make -C synth run

pr:
	make -C pr run

clean:
	make -C memory clean
	make -C synth clean
#	make -C pr clean

.PHONY: all mem synth pr clean
