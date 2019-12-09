# iob-SoC-e

SoC template containing a RISC-V processor (iob-rv32), a UART (iob-uart) the following options for booting: no boot (firmware already in internal memory), load firmware to internal RAM and start, load firmware to external DDR and start.

## Update submodules if you have not
``git submodule update --init --recursive``


## Edit the system configuration file:
``rtl/system.vh``


## Simulate

```
cd simulation/<simulator>
make
```

## Compile for FPGA 

```
cd fpga/<vendor>/<board>
make
```

## Configure FPGA

```
ssh -Y -C -p <port> <fpga_host>
cd sandbox/iob-soc-e/fpga/<vendor>/<board>
make ld-hw
```

## Load software in FPGA and run
```
picocom /dev/ttyUSB0 -b 115200 --imap lfcrlf --send-cmd "ascii-xfr -sedv"
```
In picocom enter C-a C-s followed by the file name "firmware.bin" to load the software.

