<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# IOb-SoC: this version is under development: please use the latest stable release

IOb-SoC is a System-on-Chip (SoC) template comprising an open-source RISC-V
processor (VexRiscv), a UART, a TIMER, and an interface to external memory.  The
external memory interface uses an AXI4 master bus. It may be used to access an
on-chip RAM or a 3rd party memory controller IP (typically a DDR controller).

## Nix environment

You can use [nix-shell](https://nixos.org/download.html#nix-install-linux) to
run IOb-SoC in a [Nix](https://nixos.org/) environment with all dependencies
available except for comercial EDA tools for FPGA and ASIC, which need to be
licesed and installed by the user.

After installing `nix-shell,` it can be initialized by calling any Makefile target in the IOb-SoC root directory, for example
```Bash
make setup
```

The first time it runs, `nix-shell` will automatically install all the required
dependencies. This can take a couple of hours. After that, you can enjoy IOb-SoC
and not worry about installing any software tools.

  
## Dependencies

If you prefer, you may install all the dependencies manually and run IOb-SoC without nix-shell.
To do this, you must manually remove the `nix-shell --run` commands from the Makefile, 
and install the packages listed in the [py2hwsw default.nix file](https://github.com/IObundle/py2hwsw/blob/main/py2hwsw/lib/default.nix).


## Operating Systems

IOb-SoC can be used in Linux Operating Systems. The following instructions have
been proven on Ubuntu 22.04 LTS, and likely work on most mainstream Linux
distributions.


## Configure your SoC

To configure your SoC, edit the `iob_soc.py` file, which can be found at the
repository root. This file has the system configuration variables;
hopefully, each variable is explained by a comment.


## Set environment variables for local or remote building and running (WIP)

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

IOb-SoC uses the [Py2HWSW](https://nlnet.nl/project/Py2HWSW/) framework to create a build directory with all the necessary files and makefiles to run the different tools. The build directory is placed in the folder above at ../iob_soc_Vx.y by running the following command from the root directory.
```Bash
make setup
```

If you want to avoid getting into the complications of our Python scripts, use the ../iob_soc_Vx.y directory to build your SoC. It only has code files and a few Makefiles. Enter this directory and call the available Makefile targets. Alternatively, using another Makefile in the IOb-SoC root directory, the same targets can be called. For example, to run the simulation, the IOb-SoC's top Makefile has the following target:

```Bash
sim-run:
	nix-shell --run "make clean setup INIT_MEM=$(INIT_MEM) USE_EXTMEM=$(USE_EXTMEM) && make -C ../$(CORE)_V*/ sim-run SIMULATOR=$(SIMULATOR)"
```
The above target invokes the `nix-shell` environment to call the local targets `clean` and `setup` and the target `sim-run` in the build directory. Below, the targets available in IOb-SoC's top Makefile are explained.

## Emulate the system on PC

You can *emulate* IOb-SoC's on a PC to develop and debug your embedded system. There is also a model to emulate the UART, which communicates with a run-time Python script server. If you develop peripherals, you can build embedded software models to run them using PC emulation. To emulate IOb-SoC's embedded software on a PC, type:

```Bash
make pc-emul-run
```

The Makefile compiles and runs the software in the `../iob_soc_Vx.y/software/` directory. The Makefile includes the `sw_build.mk` segment supplied initially in the `./software/` directory in the IOb-SoC root. Please feel free to change this file for your specific project. To run an emulation test comparing the result to the expected result, run
```Bash
make pc-emul-test
```

## Simulate the system

To simulate IOb-SoC's RTL using a Verilog simulator, run
```Bash
make sim-run [SIMULATOR=icarus!verilator|xcelium|vcs|questa] [INIT_MEM=0|1] [USE_EXTMEM=0|1]
```

The INIT_MEM variable specifies whether the firmware is initially loaded in the memory, skipping the boot process, and the USE_EXTMEM variable indicates whether an external memory such as DRAM is used, in which case the cache system described above is instantiated.

The Makefile compiles and runs the software in the `../iob_soc_Vx.y/hardware/simulation` directory. The Makefile includes the `./hardware/simulation/sim_build.mk`, which you can change for your project. To run a simulation test comprising several simulations with different parameters, run
```Bash
make sim-test
```
The simulation test contents can be edited in IOb-SoC's top Makefile. 

Each simulator must be described in the [`./hardware/simulation/<simulator>.mk`](https://github.com/IObundle/py2hwsw/tree/main/py2hwsw/hardware/simulation) file. For example, the file `vcs.mk` describes the VCS simulator.

The host machine must run an access server, a Python program in [`./scripts/board_server.py`](https://github.com/IObundle/py2hwsw/blob/main/py2hwsw/scripts/board_server.py), set up to run as a service. The client connects to the host using the SSH protocol and runs the board client program [`./scripts/board_client.py`](https://github.com/IObundle/py2hwsw/blob/main/py2hwsw/scripts/board_client.py). Note that the term *board* is used instead of *simulator* because the same server/client programs control the access to the board and FPGA compilers. The client requests the simulator for GRAB_TIMEOUT seconds, which is 300 seconds by default. Its value can be specified in the `./hardware/fpga/fpga_build.mk` Makefile segment, for example, as
```Bash
GRAB_TIMEOUT ?= 3600
```


## Run on FPGA board

To build and run IOb-SoC on an FPGA board, the FPGA design tools must be
installed locally or remotely. The FPGA board must also be attached to the local
or remote host, not necessarily the same host where the design tools are installed.

Each board must be described under the [`./hardware/fpga/<tool>/<board_dir>`](https://github.com/IObundle/py2hwsw/tree/main/py2hwsw/hardware/fpga) directory. For example, the [`./hardware/fpga/vivado/BASYS3`](https://github.com/IObundle/py2hwsw/tree/main/py2hwsw/hardware/fpga/vivado/basys3)
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
[`./scripts/board_server.py`](https://github.com/IObundle/py2hwsw/blob/main/py2hwsw/scripts/board_server.py). 
When IOb-SoC needs to access a remote
FPGA server, it runs the board access script located in
[`./scripts/board_client.py`](https://github.com/IObundle/py2hwsw/blob/main/py2hwsw/scripts/board_client.py).

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
