# IOb-SoC

IOb-SoC is a System-on-Chip (SoC) template comprising an open-source RISC-V
processor (picorv32), an internal SRAM memory subsystem, a UART (iob-uart), and
an optional interface to an external memory. If the external memory interface is
selected, an instruction L1 cache, a data L1 cache and a shared L2 cache are
added to the system. The L2 cache communicates with a 3rd party memory
controller IP (typically a DDR controller) using an AXI4 master bus.

## Dependencies

Before building the system, install the following tools:
- GNU Bash >=5.1.16
- GNU Make >=4.3
- RISC-V GNU Compiler Toolchain =2022.06.10  (Instructions at the end of this README)
- Python3 >=3.10.6
- Python3-Parse >=1.19.0

Optional tools, depending on desired run strategy:
- Icarus Verilog >=10.3
- Verilator >=5.002
- gtkwave >=3.3.113
- Vivado >=2020.2
- Quartus >=20.1

Older versions of the dependencies above may work but were not tested.

## Nix environment

Instead of manually installing the dependencies above, you can use
[nix-shell](https://nixos.org/download.html#nix-install-linux) to run
IOb-SoC in a [Nix](https://nixos.org/) environment with all dependencies
available except for Vivado and Quartus.

- Run `nix-shell` from the IOb-SoC root directory to install and start the environment with all the required dependencies.

## Virtual Machine

IOb-SoC can be run on a VirtualBox VM. This way, the system can be quickly tried
without investing much time installing the tools:

1. Download and install [Oracle's VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Download [IOb-SoC VM](https://drive.google.com/file/d/1X4OXI4JiBLwK7BJPAEG1voxVaFYS9V-f/view?usp=share_link)


## Operating Systems

IOb-SoC can be used in Linux Operating Systems. The following instructions work
for CentOS 7 and Ubuntu 18.04 or 20.04 LTS.

## Clone the repository

The first step is to clone this repository. IOb-SoC uses git sub-module trees, and
GitHub will ask for your password for each downloaded module if you clone by *https*. To avoid this,
setup GitHub access with *ssh* and type:

```Bash
git clone --recursive git@github.com:IObundle/iob-soc.git
cd iob-soc
```

Alternatively, you can still clone this repository using *https* if you cache
your credentials before cloning the repository, using: ``git config --global
credential.helper 'cache --timeout=<time_in_seconds>'``


## Configure your SoC

To configure your system edit the `config.mk` file, which can be found at the
repository root. This file has the system configuration variables;
hopefully, each variable is explained by a comment.


## Set environment variables for local or remote building and running

The various simulators, FPGA compilers and FPGA boards may run locally or
remotely. For running a tool remotely, you need to set two environmental
variables: the server logical name and the server user name. Consider placing
these settings in your `.bashrc` file, so that they apply to every session.


### Set up the remote simulator server

Using open-source simulator Icarus Verilog as an example, note that in
`hardware/simulation/icarus/Makefile`, the variable for the server logical name,
`SIM_SERVER`, is set to `IVSIM_SERVER`, and the variable for the user name,
`SIM_USER`, is set to `IVSIM_USER`. If you do not set these variables the
simulator will run locally. To run the simulator on server
*mysimserver.myorg.com* as user *ivsimuser*, set the following environmental
variables beforehand:

```Bash
export IVSIM_SERVER=ivsimserver.myorg.com
export IVSIM_USER=ivsimuser
```

### Set up the remote FPGA toolchain and board servers

Using the CYCLONEV-GT-DK board as an example, note that in
`hardware/fpga/quartus/CYCLONEV-GT-DK/Makefile` the variable for the FPGA tool
server logical name, `FPGA_SERVER`, is set to `QUARTUS_SERVER`, and the
variable for the user name, `FPGA_USER`, is set to `QUARTUS_USER`; the
variable for the board server, `BOARD_SERVER`, is set to `CYC5_SERVER`, and
the variable for the board user, `BOARD_USER`, is set to `CYC5_USER`. As in the
previous example, set these variables as follows:

```Bash
export QUARTUS_SERVER=quartusserver.myorg.com
export QUARTUS_USER=quartususer
export CYC5_SERVER=cyc5server.myorg.com
export CYC5_USER=cyc5username
```

In each remote server, the environment variables for the executable paths and license
servers used must be defined as in the following example:

```Bash
export QUARTUSPATH=/path/to/quartus
export VIVADOPATH=/path/to/vivado
...
export LM_LICENSE_FILE=port@licenseserver.myorg.com;lic_or_dat_file
```

### Set up Nix environment on remote servers

If you want to run IOb-SoC on the remote servers inside a [Nix](https://nixos.org/) environment, you should
edit the server's `.bashrc` file to launch the environment before running the commands.
The IOb-SoC system uses the command `ssh <remote> <command>` to run commands on the remote server.

Add the following code to the top of the server's `.bashrc` file to launch the Nix environment
when ssh commands are executed:

```Bash
# Check if connected via ssh and is a non-interactive session
if [ -n "$SSH_CONNECTION" ] && [[ $- != *i* ]]; then
    # Get the command sent via ssh, which should run in the Nix environment
    NIX_CMD=`ps -o args= $$ | cut -d ' ' -f3-`
    # Replace the current shell with a nix-shell environment and run the command
    exec $NIX_PATH/nix-shell $NIX_DEPS/shell.nix --run "$NIX_CMD"
fi
```

NOTE: The `$NIX_PATH` variable should be replaced by the path to the nix-shell binary.
Run `whereis nix-shell` on the remote machine to obtain the correct path.

NOTE: The `$NIX_DEPS` variable should be replaced by the path to the [shell.nix](https://github.com/IObundle/iob-lib/blob/python-setup/nix/shell.nix) file.
This file is located in the `nix/` directory of the [IOb-Lib](https://github.com/IObundle/iob-lib) repository.
Copy this file to a fixed location on the remote machine and replace the `$NIX_DEPS` variable with its path.


It is possible to add an extra `if` statement to only run certain tools in the Nix environment.
This may be useful since some tools, like Quartus, don't run well in the Nix environment.

```Bash
# Check if connected via ssh and is a non-interactive session
if [ -n "$SSH_CONNECTION" ] && [[ $- != *i* ]]; then
    # Get the command sent via ssh, which should run in the Nix environment
    NIX_CMD=`ps -o args= $$ | cut -d ' ' -f3-`
    # Only run environment if a specified tool is used in the command
    if [[ "$NIX_CMD" == *"verilator"* ]]; then
        # Replace the current shell with a nix-shell environment and run the command
        exec $NIX_PATH/nix-shell -p verilator --run "$NIX_CMD"
    fi
fi
```



## Setup the system

The main configuration for the system is located in the `iob_soc_setup.py` file.

To set up the system, type:

```Bash
make setup [<control parameters>]
```

`<control parameters>` are system configuration parameters passed in the
command line, overriding those in the `iob_soc_setup.py` file. Example control
parameters are `INIT_MEM=0 USE_EXTMEM=1`. For example,

```Bash
make setup INIT_MEM=0 USE_EXTMEM=1
```

The setup process will create a build directory that contains all the files required for building the system.

The **setup directory** is considered to be the repository folder, as it contains the files needed to set up the system.

The **build directory** is considered to be the folder generated by the setup process, as it contains the files needed to build the system.
The build directory is usually located in `../iob\_soc\_V*` relative to the setup directory.

To further configure the setup process, you can create/modify the following scripts:
- hardware/fpga/fpga\_setup.py
- hardware/fpga/sim\_setup.py
- software/sw\_setup.py
Even though all of the scripts above will be called during the setup process, it is useful
to separate them in different scripts according to their use purpose, mostly for organization
purposes.
If this system is included by another primary one, the primary system will have control over
which sections of this system should be set up.

Most Makefiles and Makefile


## Simulate the system

To simulate IOb-SoC, the simulator must be installed, either locally or
remotely. If you are using the Nix environment the simulator is automatically installed.
To simulate, navigate to the build directory and type:

```Bash
make [sim-run] [SIMULATOR=<simulator directory name>]
```

`<simulator directory name>` is the name of the simulator's run directory,
To visualise simulation waveforms use the `VCD=1` control parameter. It will
open the Gtkwave waveform visualisation program.

You can also run the simulation directly from the setup directory (the root
directory of this repository) by typing:

```Bash
make -C ../iob_soc_V* [sim-run] [SIMULATOR=<simulator directory name>]
```

To clean simulation-generated files, type:

```Bash
make -C ../iob_soc_V* sim-clean [SIMULATOR=<simulator directory name>]
# Example
make -C ../iob_soc_V* sim-clean SIMULATOR=icarus
```

For more details, read the Makefile segments in the `hardware/simulaton/` directory
of the build directory. The Makefile of the simulation directory includes the
Makefile segment of the simulator being used, that contains simulator specific configuration.

The simulation Makefile also includes the sim\_build.mk that can be user created in the simulation
folder of the setup directory. The sim\_build.mk file allows overriding Makefile variables for
simulation, and adding extra Makefile targets that can be used to generate files required by
the project.

The simulation Makefile also includes system info from the config\_build.mk file that
is auto-generated during setup.


## Emulate the system on PC

If there are embedded software compilation or runtime issues you can
*emulate* the system on a PC to debug the issues. To emulate IOb-SoC's embedded
software on a PC, type:

```Bash
make -C ../iob_soc_V* pc-emul
```

To clean the PC compilation generated files, type:

```Bash
make -C ../iob_soc_V* pc-emul-clean
```

For more details, read the Makefile in the `software/pc-emul/` directory. As
explained for the simulation make file, note the Makefile includes the pcemul\_build.mk
Makefile segment for project-specific configuration.


## Build and run on FPGA board

To build and run IOb-SoC on an FPGA board, the FPGA design tools must be
installed, either locally or remotely, the board must be attached to the local
host or to a remote host, and each board must have a build directory under the
`hardware/fpga/<tool>` directory, for example the `hardware/fpga/vivado/BASYS3`
directory. The FPGA tools and board hosts may be different.
The host machine must have the [board\_server.py](https://github.com/IObundle/iob-lib/blob/python-setup/scripts/board_server.py)
running. This file can be copied from the [IOb-Lib](https://github.com/IObundle/iob-lib) repository
and set up to run as a service.

To build only, type

```Bash
make -C ../iob_soc_V* fpga-build [BOARD=<board directory name>]
```
where `<board directory name>` is the name of the board's run directory, and

For more details read the Makefile in the `hardware/fpga/` folder of the build directory,
and follow the included Makefile segments as explained before.

To build and run, type:

```Bash
make -C ../iob_soc_V* fpga-run [BOARD=<board directory name>]
```

To manage multiple clients' connections to the same board, the system uses the
[board\_server.py](https://github.com/IObundle/iob-lib/blob/python-setup/scripts/board_server.py)
python server.
If many users are trying to run the same FPGA board they will be queued by the server.
Users will orderly load their bitstream onto the board and start running it.
After a successful run or `Ctr-C` interrupt, the user is de-queued.

If, for some reason, the run gets stuck, you may interrupt it with `Ctr-C`.

To clean the FPGA compilation generated files, type

```Bash
make -C ../iob_soc_V* fpga-clean [BOARD=<board directory name>]
```

## Compile the documentation

To compile documents, the LaTeX document preparation software must be
installed. The system can auto-generate a user guide based on TeX templates
and system configuration.

To compile the document, type:

```Bash
make -C ../iob_soc_V* doc [DOC=<document directory name>]
```


To clean the document's build directory, type:

```Bash
make -C ../iob_soc_V* doc-clean [DOC=<document directory name>]
```

For more details, read the Makefile in the `document/` folder of the build directory,
and follow the included Makefile segments as explained before.


## Testing

### Simulation test

To run a series of simulation tests on the simulator selected by the SIMULATOR
variable, type:

```Bash
make -C ../iob_soc_V* sim-test [SIMULATOR=<simulator directory>]
```

The above command produces a test log file called `test.log` in the simulator's
directory. The `test.log` file is compared with the `test.expected` file, which
resides in the same directory; if they differ, the test fails; otherwise, it
passes.

To clean the files produced when testing all simulators, type:

```Bash
make -C ../iob_soc_V* test-sim-clean
```

To test the setup, build and simulation process for all configurations, type:

```Bash
make sim-test [SIMULATOR=<simulator directory>]
```


### Board test

To compile and run a series of board tests on the board selected by the `BOARD`
variable, type:

```Bash
make -C ../iob_soc_V* fpga-test [BOARD=<board directory name>]
```

The above command produces a test log file called `test.log` in the board's
directory. The `test.log` file is compared with the `test.expected` file, which
resides in the same directory; if they differ, the test fails; otherwise, it
passes.

To clean the files produced when testing all boards, type:

```Bash
make -C ../iob_soc_V* test-fpga-clean
```

To test the setup, build and FPGA run process for all configurations, type:

```Bash
make fpga-test [BOARD=<board directory name>]
```


### Documentation test

To compile and test the document selected by the `DOC`, variable, type:

```Bash
make -C ../iob_soc_V* doc-test [DOC=<document directory name>]
```

The resulting Latex .aux file is compared with a known-good .aux file. If the
match the test passes; otherwise it fails.

To clean the files produced when testing all documents, type:

```Bash
make -C ../iob_soc_V* test-doc-clean
```

### Total test

To run all simulation, FPGA board and documentation tests, type:

```Bash
make test-all
```

## Cleaning

The following command will clean the selected simulation, board and document
directories, locally and in the remote servers:

```Bash
make -C ../iob_soc_V* clean
```

The following command will delete the build directory:

```Bash
make clean
```


## Instructions for Installing the RISC-V GNU Compiler Toolchain

### Get sources and checkout the supported stable version

```Bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
git checkout 2022.06.10
```

### Prerequisites

For the Ubuntu OS and its variants:

```Bash
sudo apt install autoconf automake autotools-dev curl python3 python2 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```

For CentOS and its variants:

```Bash
sudo yum install autoconf automake python3 python2 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```

### Installation

```Bash
./configure --prefix=/path/to/riscv --enable-multilib
sudo make -j$(nproc)
```

This will take a while. After it is done, type:

```Bash
export PATH=$PATH:/path/to/riscv/bin
```

The above command should be added to your `~/.bashrc` file, so that
you do not have to type it on every session.
