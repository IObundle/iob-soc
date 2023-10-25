CORE := iob_uart
DISABLE_LINT:=1
export DISABLE_LINT

clean:
	rm -rf ../$(CORE)_V*

setup:
	python3 -B ./$(CORE).py

sim-build: clean setup
	make -C ../$(CORE)_V*/ sim-build

sim-run: clean setup
	make -C ../$(CORE)_V*/ sim-run

sim-waves:
	make -C ../$(CORE)_V*/ sim-waves

sim-test: clean setup
	make -C ../$(CORE)_V*/ sim-test


test: clean setup
	make -C ../iob_uart_* sim-test


