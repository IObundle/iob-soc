# IOb-SoC

IOb-SoC is a System-on-Chip (SoC) template comprising an open-source RISC-V
processor (picorv32), an internal SRAM memory subsystem, a UART (iob-uart), and
an optional interface to an external memory. If the external memory interface is
selected, an instruction L1 cache, a data L1 cache and a shared L2 cache is
added to the system. The L2 cache communicates with a 3rd party memory
controller IP (typically a DDR controller) using an AXI4 master bus.

## Operating Systems

IOb-SoC can be used in Linux Operating Systems. The following instructions work
for CentOS 7 and Ubuntu 18.04 or 20.04 LTS.

## Clone the repository

The first step is to clone this repository. IOb-SoC is a git sub-module tree and
Github will ask for your password for each downloaded module. To avoid this,
setup Github access with *ssh*, or configure git to cache your password for a
few minutes:

``git config credential.helper 'cache --timeout=300'``

To clone IOb-SoC and enter into its directory, type:

```
git clone --recursive git@github.com:IObundle/iob-soc.git
cd iob-soc
```



## Configure your SoC

To configure your system edit the *system.mk* file, which can be found at the
repository root, and set its variables as desired; there comments in the file to
explain each variable.



## Set environment variables for local or remote builds and runs

The various simulators, FPGA compilers and FPGA boards may be run locally or
remotely. For running a tool remotely, you need to set two environmental
variables: the server logical name and the server user name. You may place these
settings in your .bashrc file, so that you do not need to do them in every
session.


### Set up the remote simulator server

Check the Makefile in `hardware/simulation/icarus` for the environment variables
to be set. In it, the variable for the server logical name, SIM\_SERVER, is set
to IVSIM\_SERVER, and the variable for the user name, SIM\_USER, is set to
IVSIM_USER. Hence, you need to set the latter variables before simulating, for
example:

```
export IVSIM_SERVER=sericaia.iobundle.com
export IVSIM_USER=jsousa
```

### Set up the remote FPGA toolchain and board servers

Check the Makefile in `hardware/fpga/<board>` for the environment variables to
be set, where `board` is the board you will run. In that Makefile, the variable
for the FPGA tool server logical name, FPGA\_SERVER, is set to QUAR\_SERVER, and
the variable for the user name, FPGA\_USER, is set to QUAR\_USER; the variable
for the board server, BOARD\_SERVER, is set to CYC5\_SERVER, and the variable
for the board user, BOARD\_USER, is set to CYC5_USER. Hence, you need to set the
latter variables before simulating, for example:

```
export QUAR_SERVER=pudim-flan.iobundle.com
export QUAR_USER=jsousa
export CYC5_SERVER=pudim-flan.iobundle.com
export CYC5_USER=jsousa
```

### Set up the remote ASIC toolchain server

Check the Makefile in `hardware/asic` for the environment variables to be set.
In it, the variable for the server logical name, ASIC\_SERVER, is set to
CADE\_SERVER, and the variable for the user name ASIC\_USER is set to
CADE\_USER. Hence, you need to set the latter variables before simulating, for
example:

```
export CADE_SERVER=molotof.iobundle.com
export CADE_USER=jsousa

```

In each remote server, the environmental variables for the tool paths and
license servers must be defined, for example:

```
export ALTERAPATH=/path/to/intel/fpga/tools
export XILINXPATH=/path/to/xilinx/fpga/tools
...
export LM_LICENSE_FILE=port@host:lic_or_dat_file
```


## Simulate the system

To simulate IOb-SoC, the simulator must be installed, either locally or remotely, and must have a run directory under the `hardware/simulation` directory. To simulate, type:
```
make [sim] [SIMULATOR=simulator_dir_name] [<control_parameters>]
```

where `simulator_dir_name` is the name of the simulator's run directory, and
 `control_parameters` are system configuration parameters passed in the command
 line, overriding those in the system.mk file, for example, `INIT_MEM=0
 RUN_EXTMEM=1`, etc. For more details, read the Makefile in the simulator
 directory.


## Run on FPGA board

To run IOb-SoC on an FPGA board, the board must be attached, either to the local
or to a remote host, and must have a run directory under the `hardware/fpga`
directory. To simulate, type:
```
make run [BOARD=<board_dir_name>] [<control parameters>]
```
where `board\_dir_name` is the name of the board's run directory, and `control
 parameters` are system configuration parameters passed in the command line,
 overriding those in the system.mk file, for example, `INIT_MEM=0 RUN_EXTMEM=1`,
 etc. For more details, read the Makefile in the board directory.


## Compile the documentation

To compile the documents, it is assumed that a full installation of Latex is
present. With Latex installed, type:

```
make doc
```

For more details, read the Makefile in the `document` directory.



## Testing

### Simulation test

To run a series of simulation tests on the simulator selected by the SIMULATOR variable, type: 
```
make test-simulator [SIMULATOR=<simulator_dir_name>]
```

To run the series of simulation tests on all the simulators listed in the SIM\_LIST variable, type: 
```
make test-all-simulators [SIM_LIST="simulator_dir_name_list"]
```
where `simulator_dir_name_list` is the list of directory names of the simulators
to be used.

To clean the files produced when testing all simulators, type:
```
make clean-all-simulators
```


### Board test

To compile and run a series of board tests on the board selected by the BOARD variable, type:
```
make test-board [BOARD=<board_dir_name>]
```

To run the series of board tests on all the boards listed in the BOARD\_LIST variable, type: 
```
make test-all-boards [BOARD_LIST="board_dir_name_list"]
```

To clean the files produced when testing all boards, type:
```
make clean-all-boards
```


The above simulation and board test commands will produce a test log file called
`test.log`. With the `test-all-simulators` or the `test-all-boards` targets,
`test.log` is compared with the expected file log in the respective simulator or
board directory; if they are different an error is issued.


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

This will take a while... After it is done, type:
```
export PATH=$PATH:/path/to/riscv/bin
```

The above command should be added to the bottom of your ~/.bashrc file, so that
you do not have to type it every session.
