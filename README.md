# iob-SoC-e

This is an IObundle proprietary System on Chip (Soc) which consists on a
iob-rv32 (a RISC-V processor), an UART and support for external memory (optional).

## To build the SoC:
* ``git submodule update --init --recursive``

#### With external memory:
* Open rtl/include/system.vh
* Keep `` `define CACHE`` uncommented 
* If the external memory is a DDR:
    * Uncomment `` `define DDR`` and `` `define DDR_INTERCONNECT``.
    * Open software/system.h and uncomment ``#define DDR``

* If the external memory is a BRAM (It was not tested):
    * Comment ``define DDR`` and ``define DDR_interconnect``.

#### Without external memory: 
* Open rtl/include/system.vh
* Comment `` `define CACHE``, `` `define DDR`` and `` `define DDR_INTERCONNECT``

```bash
make bitstream
```

## To send the program to board FPGA host (baba-de-camelo):
```bash
make send-baba
```

## To run on Xilinx FPGA:
This command should be given in FPGA host machine. At this moment the unique
Xilinx FPGA is hosted by baba-de-camelo.

```bash
make ld-hw
make 
```

picocom /dev/ttyUSB0 -b 115200 --imap lfcrlf --send-cmd "ascii-xfr -sedv"

Note: If you change the program, just re-run on Xilinx FPGA. The program will be
loaded by UART BUT you need 'dialout' group permissions.
