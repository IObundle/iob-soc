# IOb-SoC

IOb-SoC is a System-on-Chip (SoC) template comprising an open-source RISC-V
processor (picorv32), an internal SRAM memory subsystem, a UART (iob-uart), and
an optional interface to an external memory. If the external memory interface is
selected, an instruction L1 cache, a data L1 cache and a shared L2 cache are
added to the system. The L2 cache communicates with a 3rd party memory
controller IP (typically a DDR controller) using an AXI4 master bus.

## Operating Systems

IOb-SoC can be used in Linux Operating Systems. The following instructions work
for CentOS 7 and Ubuntu 18.04 or 20.04 LTS.

## Clone the repository

The first step is to clone this repository. IOb-SoC is a git sub-module tree and
GitHub will ask for your password for each downloaded module. To avoid this,
setup GitHub access with *ssh* and type:
```
git clone --recursive git@github.com:IObundle/iob-soc.git
cd iob-soc
```

Alternatively, you can clone this repository using *https*. You might want to
cache your credentials using:
``git config --global credential.helper 'cache --timeout=<time_in_seconds>'``

Before cloning the repository:
``git clone --recursive https://github.com/IObundle/iob-soc.git``


## Configure your SoC

To configure your system edit the *system.mk* file, which can be found at the
repository root. In this file there is a set of variables to configure the
system as desired; there are comments to explain each variable.


## Set environment variables for local or remote building and running

The various simulators, FPGA compilers and FPGA boards may be run locally or
remotely. For running a tool remotely, you need to set two environmental
variables: the server logical name and the server user name. You may place these
settings in your .bashrc file, so that they apply to every session.


### Set up the remote simulator server

For example, in the Makefile in `hardware/simulation/icarus`, the variable for
the server logical name, SIM\_SERVER, is set to IVSIM\_SERVER, and the variable
for the user name, SIM\_USER, is set to IVSIM_USER. Hence, you need to set the
latter variables as in the following example:

```
export IVSIM_SERVER=sericaia.iobundle.com
export IVSIM_USER=jsousa
```

### Set up the remote FPGA toolchain and board servers

For example, in the Makefile in `hardware/fpga/CYCLONEV-GT-DK` the variable for
the FPGA tool server logical name, FPGA\_SERVER, is set to QUAR\_SERVER, and the
variable for the user name, FPGA\_USER, is set to QUAR\_USER; the variable for
the board server, BOARD\_SERVER, is set to CYC5\_SERVER, and the variable for
the board user, BOARD\_USER, is set to CYC5_USER. Hence, you need to set the
latter variables as in the following example:

```
export QUAR_SERVER=pudim-flan.iobundle.com
export QUAR_USER=jsousa
export CYC5_SERVER=pudim-flan.iobundle.com
export CYC5_USER=jsousa
```

### Set up the remote ASIC toolchain server

In the Makefile in `hardware/asic`, the variable for the server logical name,
ASIC\_SERVER, is set to CADE\_SERVER, and the variable for the user name
ASIC\_USER is set to CADE\_USER. Hence, you need to set the latter variables as
in the following example:

```
export CADE_SERVER=molotof.iobundle.com
export CADE_USER=jsousa

```

In each remote server, the environmental variables for the paths of tools and
license servers must be defined as in the following example:

```
export ALTERAPATH=/path/to/intel/fpga/tools
export XILINXPATH=/path/to/xilinx/fpga/tools
...
export LM_LICENSE_FILE=port@host:lic_or_dat_file
```


## Simulate the system

To simulate IOb-SoC, the simulator must be installed, either locally or
remotely, and must have a run directory under the `hardware/simulation`
directory. To simulate, type:

```
make [sim] [SIMULATOR=<simulator directory name>] [<control parameters>]
```
where `<simulator directory name>` is the name of the simulator's run directory,
and `<control parameters>` are system configuration parameters passed in the
command line, overriding those in the system.mk file. For example, `<control
parameters>` can be set to `INIT_MEM=0 RUN_EXTMEM=1`, etc.

To visualise simulation waveforms use the `VCD=1` control parameter. It will
open the Gtkwave visualisation program.

For more details, read the Makefile in the simulator directory.


## Run on FPGA board

To run IOb-SoC on an FPGA board, the FPGA design tools must be installed, either
locally or remotely, the board must be attached to a local host or remote host,
and IOb-SoC must have a run directory under the `hardware/fpga` directory. The
FPGA tools and bord hosts may be different. To compile and run, type:

``` 
make run [BOARD=<board directory name>] [<control parameters>]
``` 
where `<board directory name>` is the name of the board's run directory, and
`<control parameters>` are system configuration parameters passed in the command
line, overriding those in the system.mk file. For example, `<control
parameters>` can be set to `INIT_MEM=0 RUN_EXTMEM=1`, etc. For more details,
read the Makefile in the board directory.



## Compile the documentation

To compile the documents, the LaTeX document preparation software must be
installed. To compile, type:
```
make doc
```

For more details, read the Makefile in the `document` directory.



## Testing

### Simulation test

To run a series of simulation tests on the simulator selected by the SIMULATOR
variable, type:

```
make test-simulator [SIMULATOR=<simulator directory name>]
```

To run the series of simulation tests on all the simulators listed in the
SIM\_LIST variable, type:

```
make test-all-simulators [SIM_LIST="<simulator directory name list>"]
```
where `<simulator directory name list>` is the list of directory names of the
simulators to be used.

To clean the files produced when testing all simulators, type:

```
make clean-all-simulators
```


### Board test

To compile and run a series of board tests on the board selected by the BOARD
variable, type:

```
make test-board [BOARD=<board directory name>]
```

To run the series of board tests on all the boards listed in the BOARD\_LIST
variable, type:

```
make test-all-boards [BOARD_LIST="<board directory name list>"]
```

To clean the files produced when testing all boards, type:
```
make clean-all-boards
```

The above simulation and board test commands will produce a test log file called
`test.log`. With the `test-all-simulators` or the `test-all-boards` targets, the
`test.log` file is compared with the expected file log in the respective
simulator or board directory; if they differ, an error is issued.


## Cleaning

The following command will clean the selected directories for simulation and
board runs, locally and in the remote servers:

```
make clean
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

If this doesn't return Python 2.*, navigate to your /usr/bin folder and
soft-link python2 to python using:
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

This will take a while... After it is done, type:
```
export PATH=$PATH:/path/to/riscv/bin
```

The above command should be added to the bottom of your ~/.bashrc file, so that
you do not have to type it every session.
