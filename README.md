# IOb-SoC

SoC template comprising an open-source RISC-V processor (picorv32), an internal
SRAM memory subsystem, a UART (iob-uart), and an optional external DDR memory
subsystem. If selected, an instruction L1 cache, a data L1 cache and a shared L2
cache is added to the system. The L2 cache communicates with a DDR
memory controller IP (not provided) using an AXI4 master bus.

## Clone the repository

``git clone --recursive git@github.com:IObundle/iob-soc.git``

Access to Github by *ssh* is mandatory so that submodules can be updated.


## The system configuration file: system.mk

The system configuration is the system.mk file residing at the repository
root. Edit the system.mk file at will. The variables that can be set are
explained by comments in the system.mk file.

## Setup your environment variables

The various simulators, FPGA compilers and FPGA boards may be run locally or
remotely. For running them remotely, set environmental variables as shown below
using some example servers and user names.  Have these settings in your .bashrc file
so that you do not need to do it every session.


```
#ncsim simulator server
export NCSIM_SERVER=sericaia.iobundle.com
export NCSIM_USER=jsousa

#quartus server
export QUAR_SERVER=pudim-flan.iobundle.com
export QUAR_USER=jsousa

#ku40 board server
export KU40_SERVER=baba-de-camelo.iobundle.com
export KU40_USER=jsousa

#cadence tools server
export CADE_SERVER=molotof.iobundle.com
export CADE_USER=user19
```

Make sure the environmental variables for the tool paths, licenses servers,
ports or files are defined in each server in use according to the following
examples.

```
export ALTERAPATH=/path/to/intel/fpga/tools
export XILINXPATH=/path/to/xilinx/fpga/tools
...
export LM_LICENSE_FILE=port@host:lic_or_dat_file
```


## Simulation

To simulate:
```
make [sim]
```

Parameters can be passed in the command line, overriding those in the system.mk file. For example:
```
make [sim] INIT_MEM=0 RUN_EXTMEM=1
```

To clean the simulation directory:
```
make sim-clean
```

To visualise simulation waveforms:
```
make sim-waves
```
The above command assumes simulation had been previously run with the VCD variable set to 1. Otherwise an error issued.

## FPGA

To compile the FPGA:
```
make fpga
```

To clean FPGA files:
```
make fpga-clean
```

To clean and also delete any used FPGA vendor IP core:
```
make fpga-clean-ip
```


## Running on the board

To load the board with an FPGA configuration bitstream file:
```
make board-load
```

To load the board with the most recently compiled firmware and run:
```
make board-run
```

To clean the board directory:
```
make board-clean
```


## Software

The following commands assume the RISC-V toolchain is installed. Otherwise
follow the instructions below to install the toolchain.

To compile the firmware:
```
make  firmware
```

To clean the firmware directory:
```
make  firmware-clean
```

To compile the bootloader:
```
make bootloader
```

To clean the bootloader directory:
```
make bootloader-clean
```

To compile the provided *console* PC program to communicate with the board:
```
make console
```


To clean the console directory
```
make console-clean
```

To clean all software directories
```
make sw-clean
```



## Documentation

The following commands assume a full installation of Latex is
present. Otherwise install it. The texlive-full Linux package is recommended.

To compile the chosen document type:
```
make document [DOC_TYPE=[pb|presentation]]
```

To clean the chosen document type:
```
make doc-clean [DOC_TYPE=[pb|presentation]]
```

To clean the chosen document type including the pdf file:
```
make doc-pdfclean [DOC_TYPE=[pb|presentation]]
```


## Testing

If you create a system using IOb-SoC, you will will want to exhaustively test it
in simulation and FPGA board. The following commands automate this process.

Tho run a series of simulation tests on the simulator selected by the SIMULATOR variable: 
```
make test-simulator
```

Tho run a series of simulation tests on the simulators listed in the SIM_LIST variable: 
```
make test-all-simulators
```

The above commands will produce a simulation log test.log. With the
test-all-simulators target, test.log is compared with the expected file in
test/test-sim.log; if they are different an error is issued.

To create an updated test-sim.log, inspect the test.log file. If you deem the file correct replace the test-sim.log file with it:
```
mv test.log test/test-sim.log
```

Run the test-all-simulators target and verify that the test now passes.



To compile and run a particular system configuration on the board selected by the BOARD variable:
```
make test-board-config
```

To compile and run a series of system configurations on the board selected by the BOARD variable:
```
make test-board
```

To compile and run a series of system configurations on the boards listed in the BOARD_LIST variable:
```
make test-all-boards
```

The above commands will produce a board run log test.log. With the
test-all-boards target, test.log is compared with the expected file in
test/test-fpga.log; if they are different an error is issued.

To create an updated test-fpga.log, inspect the test.log file. If you deem the file correct replace the test-fpga.log file with it:
```
mv test.log test/test-fpga.log
```

Run the test-all-boards target and verify that the test now passes.


## Cleaning

The following command will clean the selected directories for simulation, FPGA compilation and board run: 
```
make clean-all
```



## Instructions for Installing the RISC-V GNU Compiler Toolchain

### Get sources and checkout the supported stable version

```
git clone https://github.com/riscv/riscv-gnu-toolchain
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
sudo ln -s python2 /usr/bin/python
```

For CentOS and its variants:

```
sudo yum install autoconf automake python3 python2 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```

### Installation

```
cd riscv-gnu-toolchain
./configure --prefix=/path/to/riscv --enable-multilib
sudo make -j$(nproc)
```

This will take a while... After it is done do:

```
export PATH=$PATH:/path/to/riscv/bin
```
The above command should be added to the bottom of your ~/.bashrc file, so that you do not have to type it every session.
