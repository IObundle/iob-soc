# IOb-SoC

SoC template comprising a RISC-V processor (iob-rv32), an SRAM memory subsystem,
a UART (iob-uart), and optional caches and AXI4 connection to external DDR.

## Clone the repository

``git clone git@github.com:IObundle/iob-soc.git``

Ssh access is mandatory so that submodules can be updated.

## Update submodules
``git submodule update --init --recursive``


## Edit the system configuration file: /hardware/system.mk

To configure IOb-SoC the following parameters are availble:

FIRM_ADDR_W: log2 size of user program and data space, from 1st instruction at
address 0 to the stack end at address 2<sup>FIRM_ADDR_W</sup>-1

SRAM_ADDR_W: log2 size of SRAM, addresses from 0 to 2<sup>SRAM_ADDR_W</sup>-1

USE_DDR: assign to 1 if DDR access is needed or to 0 otherwise. Instruction and
data L1 caches will be placed in the design, connected to an L2 cache, which in
turn connects to an external DDR controller.

RUN_DDR:= assign to 1 if the program runs from the DDR memory and 0
otherwise. This parameter is ignored if USE_DDR=0. If USE_DDR=1 and RUN_DDR=1,
the SRAM memory can be accessed when the address MSB is 1. If USE_DDR=1 and
RUN_DDR=0, the DDR is used to store data only; it can be accessed when the
address MSB is 1.

DDR_ADDR_W: log2 size of DDR, addresses from 0 to 2<sup>DDR_ADDR_W</sup>-1

USE_BOOT: assign to 1 to load a program received by the UART and boot from it, or to 0 otherwise.

BOOTROM_ADDR_W: log2 size of the boot ROM, which should be sufficient to hold the bootloader program and data.

PERIPHERALS:=UART: peripheral list (must match respective submodule name)

SIMULATOR:=icarus: chosen RTL simulator

FPGA_BOARD:=AES-KU040-DB-G: chosen FPGA board

FPGA_COMPILER_SERVER=146.193.44.48: chosen FPGA build server

ASIC_NODE:=umc130: chosen ASIC node

DOC_TYPE:=presentation: chosen document to build with Latex

## Simulate
```
make sim
```

## Compile and configure FPGA 
```
make fpga
```

## Load and run firmware
```
make load-firmware
```

## Run firmware only
```
make run-firmware
```

## Implement ASIC
```
make asic
```



## Instructions for Installing the RISC-V GNU Compiler Toolchain

### Get sources

```
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
git submodule update --init --recursive
git checkout <stable tag>
git submodule update --init --recursive
```

### Prerequisites

For Ubuntu OS and its variants:

```
sudo apt install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```

For CentOS and its variants:

```
sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```

### Installation

```
sudo ./configure --prefix=path/to/riscv --enable-multilib
sudo make
```

### Compilation

```
path/to/riscv/riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 <C sources> -o <exec>
```

### Supporting 32-bit applications

Use symbolic links:

```
sudo ln -s riscv64-unknown-elf-gcc riscv32-unknown-elf-gcc
sudo ln -s riscv64-unknown-elf-objcopy riscv32-unknown-elf-objcopy
```
