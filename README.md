# IOb-SoC

SoC template comprising a RISC-V processor (iob-rv32), an SRAM memory subsystem,
a UART (iob-uart), and optional caches and AXI4 connection to external DDR.

## Clone the repository

``git clone git@github.com:IObundle/iob-soc.git``

Ssh access is mandatory so that submodules can be updated.

## Update submodules
``git submodule update --init --recursive``


## Edit the system configuration file: /hardware/system.mk

To configure IOb-SoC the following parameters are available:

FIRM\_ADDR\_W: log2 size of user program and data space, from 1st instruction at
address 0 to the stack end at address 2<sup>FIRM\_ADDR\_W</sup>-1

SRAM\_ADDR\_W: log2 size of SRAM, addresses from 0 to 2<sup>SRAM\_ADDR\_W</sup>-1

USE\_DDR: assign default to 1 if DDR access is needed or to 0
otherwise. Instruction and data L1 caches will be placed in the design,
connected to an L2 cache, which in turn connects to an external DDR
controller. This parameter can also be passed when invoking the makefile.

RUN\_DDR: assign default to 1 if the program runs from the DDR memory and 0
otherwise. This parameter is ignored if USE\_DDR=0. If USE\_DDR=1 and RUN\_DDR=1,
the SRAM memory can be accessed when the address MSB is 1. If USE\_DDR=1 and
RUN\_DDR=0, the DDR is used to store data only; it can be accessed when the
address MSB is 1. This parameter can also be passed when invoking the makefile.

DDR\_ADDR\_W: log2 size of DDR, addresses from 0 to 2<sup>DDR\_ADDR\_W</sup>-1

CACHE\_ADDR\_W: log2 size of addressable memory; it should be greater than
FIRM\_ADDR\_W to allow to allow accessing DDR data outside the program scope.

INIT\_MEM: assign default to 1 to load a program received by the UART and boot
from it, or to 0 otherwise. This parameter can also be passed when invoking the
makefile.

BOOTROM\_ADDR\_W: log2 size of the boot ROM, which should be sufficient to hold
the bootloader program and data.

PERIPHERALS: peripheral list; must match respective submodule name so that
all hardware and software of the peripheral is automatically included when
compiling the system.

SIM\_LIST: list of simulators to use in automatic testing. Simulators can be run
remotely, in which case parameters SIM\_SERVER and SIM\_USER should be given.

SIM\_SERVER: remote machine where the simulator runs.

SIM\_USER: user name for SIM\_SERVER.

SIMULATOR: default simulator. Leave SIM\_SERVER and SIM\_USER blank if simulator
runs locally.

BOARD_LIST: list of boards to use in automatic testing. FPGA compilers, loaders
and our "console" program can be run remotely, in which case parameters
COMPILE\_SERVER, COMPILE\_USER, COMPILE\_OBJ, BOARD\_SERVER and BOARD\_USER
should be given.

LOCAL\_BOARD_LIST: list of boards attached to the local machine.

LOCAL\_COMPILER_LIST: list of FPGA compilers installed in the local machine.

COMPILE\_SERVER: remote machine where the FPGA compiler is installed.

COMPILE\_USER: user name for COMPILE\_SERVER.

COMPILE\_OBJ: name of the FPGA configuration file to build.

BOARD\_SERVER: remote machine where the hardware board is attached.

COMPILE\_USER: user name for BOARD\_SERVER.

REMOTE\_ROOT_DIR: directory in the remote machine to copy the current directory 

ASIC\_NODE: directory in the asic directory containing a compilation environment for the ASIC technology node

DOC\_TYPE: directory in the document directory containing the Latex files producing the desired type of document

## Simulation

To simulate:
```
make sim
```
To visualise simulation waveforms
```
make sim-waves
```
clean simulation files:
```
make sim-clean
```

## FPGA

To compile the FPGA:
```
make fpga
```

To configure the FPGA:
```
make fpga-load
```

To clean FPGA files:
```
make fpga-clean
```
or to clean and delete 3rd party IP:
```
make fpga-clean-ip
```


## Running the hardware
```
make run-hw
```

## ASIC

To compile and ASIC:
```
make asic
```
To clean ASIC files:
```
make asic-clean
```


## Software

To compile the firmware:
```
make  firmware
```

To compile the bootloader:
```
make bootloader
```

## Documentation

To compile the chosen document type:
```
make document
```

To clean document files:
```
make clean-doc
```


## Testing

To run a simulation and FPGA test:
```
make test
```
To run a simulation test only:
```
make test-sim
```
To run a FPGA test only:
```
make test-fpga
```


## Cleaning

Besides the specific cleanup actions give so far, to clean software and documentation type
```
make clean
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
sudo apt install autoconf automake autotools-dev curl python3 python2 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```
To check your python version, use:
```
python --version
```
If this doesn't return Python 2.*, navigate to your /usr/bin folder and soft-link python2 to python using:
```
ln -s python2 /usr/bin/python
```

For CentOS and its variants:

```
sudo yum install autoconf automake python3 python2 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```

### Installation

```
sudo ./configure --prefix=/path/to/riscv --enable-multilib
sudo make
export PATH=$PATH:/path/to/riscv/bin
```
The export PATH command can be added to the bottom of your ~/.bashrc

### Compilation

```
path/to/riscv/riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 <C sources> -o <exec>
```
