<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# IOb-SoC

IOb-SoC is a System-on-Chip (SoC) template comprising an open-source RISC-V
processor (picorv32), an internal SRAM memory subsystem, a UART, and
an optional interface to external memory. If the external memory interface is
selected, an instruction L1 cache, a data L1 cache, and a shared L2 cache are
added to the system. The L2 cache communicates with a 3rd party memory
controller IP (typically a DDR controller) using an AXI4 master bus.

## Nix environment

You can use
[nix-shell](https://nixos.org/download.html#nix-install-linux) to run
IOb-SoC in a [Nix](https://nixos.org/) environment with all dependencies
available except for Vivado and Quartus for FPGA compilation and running.

After installing `nix-shell,` it can be initialized by calling any Makefile target in the IOb-SoC root directory, for example
```Bash
make setup
```

The first time it runs, `nix-shell` will automatically install all the required dependencies. This can take a couple of hours, but after that, you can enjoy IOb-SoC and not worry about installing software tools.

  
## Dependencies

If you prefer, you may install all the dependencies manually and run IOb-SoC without nix-shell. The following tools should be installed:
- GNU Bash >=5.1.16
- GNU Make >=4.3
- RISC-V GNU Compiler Toolchain =2022.06.10  (Instructions at the end of this README)
- Python3 >=3.10.6
- Python3-Parse >=1.19.0

Optional tools, depending on the desired run strategy:
- Icarus Verilog >=10.3
- Verilator >=5.002
- gtkwave >=3.3.113
- Vivado >=2020.2
- Quartus >=20.1

Older versions of the dependencies above may work but still need to be tested.



## Operating Systems

IOb-SoC can be used in Linux Operating Systems. The following instructions work
for CentOS 7 and Ubuntu 18.04, 20.04, and 22.04 LTS.

## Clone the repository

The first step is to clone this repository. IOb-SoC uses git sub-module trees, and
GitHub will ask for your password for each downloaded module if you clone it by *https*. To avoid this,
setup GitHub access with *ssh* and type:

```Bash
git clone --recursive git@github.com:IObundle/iob-system.git
cd iob-system
```

Alternatively, you can still clone this repository using *https* if you cache
your credentials before cloning the repository, using: ``git config --global
credential.helper 'cache --timeout=<time_in_seconds>'``


## Configure your SoC

To configure your system, edit the `iob_system.py` file, which can be found at the
repository root. This file has the system configuration variables;
hopefully, each variable is explained by a comment.


## Set environment variables for local or remote building and running

The various simulators, FPGA compilers, and FPGA boards may run locally or
remotely. For running a tool remotely, you need to set two environmental
variables: the server logical name and the server user name. Consider placing
these settings in your `.bashrc` file so that they apply to every session.


### Set up the remote simulator server

Using the open-source simulator Icarus Verilog (`iverilog`) as an example, note that in
`submodules/hardware/simulation/icarus.mk,` the variable for the server logical name,
`SIM_SERVER,` is set to `IVSIM_SERVER,` and the variable for the user name,
`SIM_USER` is set to `IVSIM_USER`.

To run the simulator on the server *mysimserver.myorg.com* as user *ivsimuser*, set the following environmental
variables beforehand, or place them in your `.bashrc` file:

```Bash
export IVSIM_SERVER=ivsimserver.myorg.com
export IVSIM_USER=ivsimuser
```

When you start the simulation, IOb-SoC's simulation Makefile will log you on to the server using `ssh,` then `rsync` the files to a remote build directory and run the simulation there.  If you do not set these variables, the simulator will run locally if installed.

### Set up the remote FPGA toolchain and board servers

Using the cyclonev_gt_dk board as an example, note that in
`hardware/fpga/quartus/cyclonev_gt_dk/Makefile,` the variable for the FPGA tool
server logical name, `FPGA_SERVER,` is set to `QUARTUS_SERVER,` and the
variable for the user name, `FPGA_USER`, is set to `QUARTUS_USER`; the
variable for the board server, `BOARD_SERVER,` is set to `CYC5_SERVER`, and
the variable for the board user, `BOARD_USER,` is set to `CYC5_USER`. As in the
previous example, set these variables as follows:

```Bash
export QUARTUS_SERVER=quartusserver.myorg.com
export QUARTUS_USER=quartususer
export CYC5_SERVER=cyc5server.myorg.com
export CYC5_USER=cyc5username
```

In each remote server, the environment variable for the license server used must be defined as in the following example:

```Bash
export LM_LICENSE_FILE=port@licenseserver.myorg.com;lic_or_dat_file
```

## Create the build directory

IOb-SoC uses intricate Python scripting to create a build directory with all the necessary files and makefiles to run the different tools. The build directory is placed in the folder above at ../iob_system_Vx.y by running the following command from the root directory.
```Bash
make setup
```

If you want to avoid getting into the complications of our Python scripts, use the ../iob_system_Vx.y directory to build your SoC. It only has code files and a few Makefiles. Enter this directory and call the available Makefile targets. Alternatively, using another Makefile in the IOb-SoC root directory, the same targets can be called. For example, to run the simulation, the IOb-SoC's top Makefile has the following target:

```Bash
sim-run:
	nix-shell --run 'make clean setup INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM) && make -C ../$(CORE)_V*/ sim-run SIMULATOR=$(SIMULATOR)'
```
The above target invokes the `nix-shell` environment to call the local targets `clean` and `setup` and the target `sim-run` in the build directory. Below, the targets available in IOb-SoC's top Makefile are explained.

## Emulate the system on PC

You can *emulate* IOb-SoC's on a PC to develop and debug your embedded system. There is also a model to emulate the UART, which communicates with a run-time Python script server. If you develop peripherals, you can build embedded software models to run them using PC emulation. To emulate IOb-SoC's embedded software on a PC, type:

```Bash
make pc-emul-run
```

The Makefile compiles and runs the software in the `../iob_system_Vx.y/software/` directory. The Makefile includes the `sw_build.mk` segment supplied initially in the `./software/` directory in the IOb-SoC root. Please feel free to change this file for your specific project. To run an emulation test comparing the result to the expected result, run
```Bash
make pc-emul-test
```

## Simulate the system

To simulate IOb-SoC's RTL using a Verilog simulator, run
```Bash
make sim-run [SIMULATOR=icarus!verilator|xcelium|vcs|questa] [INIT_MEM=0|1] [USE_EXTMEM=0|1]
```

The INIT_MEM variable specifies whether the firmware is initially loaded in the memory, skipping the boot process, and the USE_EXTMEM variable indicates whether an external memory such as DRAM is used, in which case the cache system described above is instantiated.

The Makefile compiles and runs the software in the `../iob_system_Vx.y/hardware/simulation` directory. The Makefile includes the `./hardware/simulation/sim_build.mk`, which you can change for your project. To run a simulation test comprising several simulations with different parameters, run
```Bash
make sim-test
```
The simulation test contents can be edited in IOb-SoC's top Makefile. 

Each simulator must be described in the `./submodules/LIB/hardware/simulation/<simulator>.mk` file. For example, the file `vcs.mk` describes the VCS simulator.

The host machine must run an access server, a Python program in `./submodules/LIB/scripts/board_server.py,` set up to run as a service. The client connects to the host using the SSH protocol and runs the board client program `/submodules/LIB/scripts/board_client.py.` Note that the term *board* is used instead of *simulator* because the same server/client programs control the access to the board and FPGA compilers. The client requests the simulator for GRAB_TIMEOUT seconds, which is 300 seconds by default. Its value can be specified in the `./hardware/fpga/fpga_build.mk` Makefile segment, for example, as
```Bash
GRAB_TIMEOUT ?= 3600
```


## Build and run on FPGA board

To build and run IOb-SoC on an FPGA board, the FPGA design tools must be
installed locally or remotely. The FPGA board must also be attached to the local
or remote host, not necessarily the same host where the design tools are installed.

Each board must be described under the `/submodules/LIB/hardware/fpga/<tool>/<board_dir>` directory. For example, the `hardware/fpga/vivado/BASYS3`
directory contents describe the board BASYS3, which has an FPGA device that can be programmed by the Xilinx/AMD Vivado design tool. The access to the board is controlled by the same server/client programs described above for the simulators.
To build an FPGA design of an IOb-SoC system and run it on the board located in the `board_dir` directory, type
```Bash
make fpga-run [BOARD=<board_dir>] [INIT_MEM=0|1] [USE_EXTMEM=0|1]
```

To run an FPGA test comparing the result to the expected result, run
```Bash
make fpga-test
```
The FPGA test contents can be edited in IOb-SoC's top Makefile. 


The remote machines that have an FPGA board attached to it must run our board
access control service script, which can be found in
`submodules/LIB/scripts/board_server.py`. When IOb-SoC needs to access a remote
FPGA server, it runs the board access script located in
`submodules/LIB/scripts/board_server.py`.

To install `board_server.py` as a service, run the following command on the remote FPGA server:
```
sudo make board_server_install
```

To uninstall the service, run

```
sudo make board_server_uninstall
```

Finally, to query the board status, run 
```
sudo make board_server_uninstall
```


## Compile the documentation

To compile documents, the LaTeX software must be installed. Three document types are generated: the Product Brief (pb), the User Guide (ug), and a presentation. To build a given document type DOC, run
```Bash
make doc-build [DOC=pb|ug|presentation]
```

To generate the three documents as a test, run 
```Bash
make doc-test
```


## Total test

To run all simulation, FPGA board, and documentation tests, type:

```Bash
make test-all
```

## Running more Makefile Targets

The examples above are the Makefile targets at IOb-SoC's root directory that call the targets in the top Makefile in the build directory. Please explore the available targets in the build directory's top Makefile to add more targets to the root directory Makefile.

## Cleaning the build directory
To clean the build directory, run
```Bash
make clean
```

## Instructions for Installing the RISC-V GNU Compiler Toolchain

### Get sources and check out the supported stable version

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

The above command should be added to your `~/.bashrc` file so you do not have to type it on every session.

## Ethernet

To setup the system with ethernet capability, set the `USE_ETHERNET` macro value to `True`.

When running the system with ethernet, please set the `RMAC_ADDR` and `IOB_CONSOLE_PYTHON_ENV` environment variables.
These values will select which network interface and which python environment to use for the console.

For example, you can add the following to your `~/.bashrc`:

```Bash
# IOb-SoC console network interface (loopback interfacce)
export RMAC_ADDR=000000000000
# Custom IOb-SoC console python interperter with `CAP_NET_RAW` capability.
export IOB_CONSOLE_PYTHON_ENV=/opt/pyeth3/bin/python
``` 

You could also set those variables in the build directory's `config_build.mk` file.

# Acknowledgements

First of all, we acknowledge all the volunteer contributors for all their valuable pull requests, issues, and discussions. 

The work has been partially performed in the scope of the A-IQ Ready project, which receives funding within Chips Joint Undertaking (Chips JU) - the Public-Private Partnership for research, development, and innovation under Horizon Europe – and National Authorities under grant agreement No. 101096658.

The A-IQ Ready project is supported by the Chips Joint Undertaking (Chips JU) - the Public-Private Partnership for research, development, and innovation under Horizon Europe – and National Authorities under Grant Agreement No. 101096658.

![image](https://github.com/IObundle/iob-system/assets/5718971/78f2a3ee-d10b-4989-b221-71154fe6e409) ![image](https://github.com/IObundle/iob-system/assets/5718971/d57e0430-bb60-42e3-82a3-c5b6b0417322)


This project provides the basic infrastructure to other projects funded through the NGI Assure Fund, a fund established by NLnet
with financial support from the European Commission's Next Generation Internet program under the aegis of DG Communications Networks, Content, and Technology.

<table>
    <tr>
        <td align="center" width="50%"><img src="https://nlnet.nl/logo/banner.svg" alt="NLnet foundation logo" style="width:50%"></td>
        <td align="center"><img src="https://nlnet.nl/image/logos/NGIAssure_tag.svg" alt="NGI Assure logo" style="width:50%"></td>
    </tr>
</table>
