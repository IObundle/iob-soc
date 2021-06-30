# IOb-SoC

IOb-SoC is a System-on-Chip (SoC) template comprising an open-source RISC-V processor
(picorv32), an internal SRAM memory subsystem, a UART (iob-uart), and an
optional interface to an external memory. If external memory is selected, an
instruction L1 cache, a data L1 cache and a shared L2 cache is added to the
system. The L2 cache communicates with a 3rd party memory controller IP
(tpically DDR) using an AXI4 master bus.

## Operating Systems

IOb-SoC can be used in Linux Operating Systems. The following instructions work
for CentOS 7 and Ubuntu 18.04 or 20.04 LTS.

## Clone the repository

The first step is to clone this repository. Before you clone it make sure you
can access Github by *ssh*. This is necessary as IOb-SoC is a git submodule
tree that can only be recursively downloaded via *ssh*. To clone IOb-SoC type 


``git clone --recursive git@github.com:IObundle/iob-soc.git``



## Configure your SoC

To configure your system edit the *system.mk*, which can be found at the
repository root. You configure the system by setting the variables in the
*system.mk* file. The variables are explianed by comments inserted in the
*system.mk* file.


## Set environment variables for local or remote builds and runs

The various simulators, FPGA compilers and FPGA boards may be run locally or
remotely. For running them remotely, you need to set the environmental variables
shown below, replacing the server and user names by the ones you will use. Place
these settings in your .bashrc file, so that you do not need to do them in every
session.

### Set up the remote simulator server

Navigate to the simulator directory, for example, `cd
hardware/simulation/icarus`, and check the Makefile for the environment
variables to be set. You will see that the server is read from the variable
IVSIM\_SERVER and the user from IVSIM_USER. Set them with your simulator server
name and user name, for example:

```
export XMSIM_SERVER=sericaia.iobundle.com
export XMSIM_USER=jsousa
```

### Set up the remote FPGA toolchain and board servers

Navigate to the FPGA board directory, for example, `cd
hardware/fpga/CYCLONEV-GT-DK`, and check the Makefile for the environment
variables to be set. You will see that the compile server is read from the variable
QUAR\_SERVER and the compile user from QUAR\_USER; the board server is read from the variable
CYC5\_SERVER and the compile user from CYC5_USER. Set them accordingly, for example:

```
export QUAR_SERVER=pudim-flan.iobundle.com
export QUAR_USER=jsousa
export CYC5_SERVER=pudim-flan.iobundle.com
export CYC5_USER=jsousa
```

### Set up the remote ASIC toolchain server

Navigate to the ASIC directory, `cd hardware/fpga/CYCLONEV-GT-DK`, and check the
Makefile for the environment variables to be set. You will see that the server
is read from the variable CADE\_SERVER and the user from CADE\_USER. Set them
accordingly, for example:

```
export CADE_SERVER=molotof.iobundle.com
export CADE_USER=jsousa

```

Also make sure the environmental variables for the tool paths, license servers
(ports or files) are defined in each remote server, for example:

```
export ALTERAPATH=/path/to/intel/fpga/tools
export XILINXPATH=/path/to/xilinx/fpga/tools
...
export LM_LICENSE_FILE=port@host:lic_or_dat_file
```


## Simulate the system

To simulate IOb-SoC, simply type:
```
make [sim]
```

Control parameters can be passed in the command line, overriding those in the system.mk file. For example:
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
