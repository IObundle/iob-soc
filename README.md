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

The first step is to clone this repository. IOb-SoC git sub-module trees, and
GitHub will ask for your password for each downloaded module. To avoid this,
setup GitHub access with *ssh* and type:
```
git clone --recursive git@github.com:IObundle/iob-soc.git
cd iob-soc
```

Alternatively, you can clone this repository using *https*. You might want to
cache your credentials before cloning the repository, using:
``git config --global credential.helper 'cache --timeout=<time_in_seconds>'``


## Configure your SoC

To configure your system edit the *system.mk* file, which can be found at the
repository root. In this file, you can find the system configuration variables; each variable is explained by a comment.


## Set environment variables for local or remote building and running

The various simulators, FPGA compilers and FPGA boards may be run locally or
remotely. For running a tool remotely, you need to set two environmental
variables: the server logical name and the server user name. You may place these
settings in your .bashrc file, so that they apply to every session.


### Set up the remote simulator server

For example, in `hardware/simulation/icarus/Makefile`, the variable for the
server logical name, SIM\_SERVER, is set to IVSIM\_SERVER, and the variable for
the user name, SIM\_USER, is set to IVSIM_USER. Hence, you need to set the
latter variables as in the following example:

```
export IVSIM_SERVER=mysimserver.myorg.com
export IVSIM_USER=myusername
```

### Set up the remote FPGA toolchain and board servers

For example, in `hardware/fpga/CYCLONEV-GT-DK/Makefile` the variable for
the FPGA tool server logical name, FPGA\_SERVER, is set to QUARTUS\_SERVER, and the
variable for the user name, FPGA\_USER, is set to QUARTUS\_USER; the variable for
the board server, BOARD\_SERVER, is set to CYC5\_SERVER, and the variable for
the board user, BOARD\_USER, is set to CYC5_USER. Hence, you need to set the
latter variables as in the following example:

```
export QUARTUS_SERVER=myQUARTUSserver.myorg.com
export QUARTUS_USER=myQUARTUSserverusername
export CYC5_SERVER=myCYCLONEV-GT-DKboardserver.myorg.com
export CYC5_USER=myCYCLONEV-GT-DKboardserverusername
```

### Set up the remote ASIC toolchain server

In `hardware/asic/Makefile`, the variable for the server logical name,
ASIC\_SERVER, is set to CADENCE\_SERVER, and the variable for the user name
ASIC\_USER is set to CADENCE\_USER. Hence, you need to set the latter variables
as in the following example:

```
export CADENCE_SERVER=myasicserver.myorg.com
export CADENCE_USER=myusername

```

In each remote server, the environmental variables for the paths of the tools
and license servers used must be defined as in the following example:

```
export QUARTUSPATH=/path/to/quartus
export VIVADOPATH=/path/to/vivado
...
export LM_LICENSE_FILE=port@host;lic_or_dat_file
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
parameters>` can be replaced with `INIT_MEM=0 RUN_EXTMEM=1`.

To visualise simulation waveforms use the `VCD=1` control parameter. It will
open the Gtkwave visualisation program.

To clean simulation generated files, type:
```
make sim-clean [SIMULATOR=<simulator directory name>] 
```

For more details, read the Makefile in each simulator directory.

## Emulate the system on PC 

If there are embedded software compilation or runtime issues you may want to
emulate the system on a PC ot debug those issues. To emulate IOb-SoC's embedded
software on a PC, type:

```
make pc-emul [<control parameters>]
```
where `<control parameters>` are system configuration parameters passed in the
command line, overriding those in the system.mk file. For example, `<control
parameters>` can be replaced with `INIT_MEM=0 RUN_EXTMEM=1`.

To clean the PC compilation generated files, type:
```
make pc-emul-clean
```

For more details, read the Makefile in the `software/pc-emul` directory.


## Build and run on FPGA board

To build and run IOb-SoC on an FPGA board, the FPGA design tools must be
installed, either locally or remotely, the board must be attached to the local
host or to a remote host, and each board must have a run directory under the
`hardware/fpga` directory, for example the `hardware/fpga/BASYS3` directory. The
FPGA tools and board hosts may be different. 

To build only, type
``` 
make fpga-build [BOARD=<board directory name>] [<control parameters>]
``` 
where `<board directory name>` is the name of the board's run directory, and
`<control parameters>` are system configuration parameters passed in the command
line, overriding those in the system.mk file. For example, `<control
parameters>` can be replaced with `INIT_MEM=0 RUN_EXTMEM=1`, etc. For more details,
read the Makefile in the board directory.

To build and run, type:
``` 
make fpga-all [BOARD=<board directory name>] [<control parameters>]
``` 

To run, assuming it is already built, type:
``` 
make fpga-run [BOARD=<board directory name>] [<control parameters>]
``` 

Before running, the FPGA is loaded with the configuration bitstream. However if
the bitstream checksum matches that of the last loaded bitstream, kept in file
`/tmp/<board directory name>.load`, this step is skipped. If, for some reason,
the FPGA does not run, you may interrupt it with Ctr-C. Then run make fpga-run again and force the bitstream to be reloaded using control
parameter FORCE=1.

If many users are trying to run the same FPGA board they will be queued in file
`/tmp/<board directory name>.queue`, before being able to load the bistream and
run. After a successful run or Ctr-C interrupt, the user is dequeued.


To clean the FPGA compilation generated files, type
``` 
make fpga-clean [BOARD=<board directory name>]
``` 

## Compile the documentation

To compile documents, the LaTeX document preparation software must be
installed. To compile the document given by the DOC variable, type:
```
make doc [DOC=<document directory name>]
```

For more details, read the Makefile in each document's directory



## Testing

### Simulation test

To run a series of simulation tests on the simulator selected by the SIMULATOR
variable, type:

```
make test-simulator [SIMULATOR=<simulator directory name>]
```

The above command creates a file called `test.log` in directory
`hardware/simulation/<simulator directory name>`, which is compared to file
`test.expected`in the same directory; if they differ, an error is issued. It
also adds a line to file `test_report.log` in the repository's root directory.

To run the series of simulation tests on all the simulators listed in the
SIM\_LIST variable, type:

```
make test-all-simulators [SIM_LIST="<simulator directory name list>"]
```
where `<simulator directory name list>` is the list of sub-directory names in directory `hardware/simulation`, which correspond to simulator names.

To clean the files produced when testing all simulators, type:

```
make clean-all-simulators
```

The above simulation and board test commands will produce a test log file called
`test.log` in each simulator or board sub-directory. With the `test-all-simulators` or the `test-all-boards` targets, the
`test.log` file is compared with the expected file log in the respective
simulator or board directory; if they differ, an error is issued.



### Board test

To compile and run a series of board tests on the board selected by the BOARD
variable, type:

```
make test-board [BOARD=<board directory name>]
```

The above command creates the file `software/console/test.log`, which is
compared to file `hardware/fpga/<FPGA compiler name>/<board directory
name>/test.expected`; if they differ, an error is issued. It also adds a line to
file `test_report.log` in the repository's root directory.

To run the series of board tests on all the boards listed in the BOARD\_LIST
variable, type:

```
make test-all-boards [BOARD_LIST="<board directory name list>"]
```

To clean the files produced when testing all boards, type:
```
make clean-all-boards
```


### Documentation test

To compile and test the document given in the DOC, variable, type:

```
make test-doc [DOC=<document directory name>]
```

The above command will add a line to file `test_report.log` in the repository's
root directory.


To test all documents listed in the DOC\_LIST variable, type:

```
make test-all-docs [DOC_LIST="<document directory name list>"]
```

To clean the files produced when testing all documents, type:
```
make clean-all-docs
```

### Total test

To run all simulation, FPGA board and documentation tests, type:
```
make test
```

The total test report can be found in file `test_report.log` in the repository's
root directory.


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
