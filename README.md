# iob-SoC

SoC template containing a RISC-V processor (iob-rv32), a UART (iob-uart) the following options for booting: no boot (firmware already in internal memory), load firmware to internal RAM and start, load firmware to external DDR and start.

## Install RISC-V GNU Compiler Toolchain if you have not

###Get sources

```
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
git submodule update --init --recursive
git checkout <stable tag>
git submodule update --init --recursive
```

###Prerequisites

```
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```

###Instalation

```
sudo ./configure --prefix=path/to/riscv --enable-multilib
sudo make
```

###Compilation

```
path/to/riscv/riscv32i-unknown-elf-gcc -march=rv32im -mabi=ilp32 <C sources> -o <exec>
```

## Update submodules if you have not
``git submodule update --init --recursive``


## Edit the system configuration file: rtl/system.vh


## Simulate

#Edit simulator path in Makefile and do:

```
make sim
```

## Compile FPGA 

#Edit FPGA path in Makefile and do:

```
source path/to/vivado/settings64.sh
make fpga
```

## Run FPGA

#Ssh to FPGA host:
```
ssh -Y -C -p <port> <fpga_host>
```

# Setup console to interact

This tool will automatically load firmware into the FPGA.

```
cd $HOME/sandbox/iob-soc/
make ld-sw
```

# Configure FPGA

Open a new terminal

```
cd $HOME/sandbox/iob-soc/
source path/to/vivado/settings64.sh
make ld-hw
```

