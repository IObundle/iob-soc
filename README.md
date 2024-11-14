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
<!--
# TODO: iob-soc repo no longer has sw_build.mk (it comes from iob-system). Should we add it back?
-->
The Makefile compiles and runs the software in the `../iob_soc_Vx.y/software/` directory. The Makefile includes the `sw_build.mk` segment supplied initially in the `./software/` directory in the IOb-SoC root. Please feel free to change this file for your specific project. To run an emulation test comparing the result to the expected result, run
```Bash
make pc-emul-test
```

## Simulate the system

To simulate IOb-SoC's RTL using a Verilog simulator, run
```Bash
make sim-run [SIMULATOR=icarus!verilator|xcelium|vcs|questa] [INIT_MEM=0|1] [USE_EXTMEM=0|1]
```

The INIT_MEM variable specifies whether the firmware is initially loaded in the memory, skipping the boot process, and the USE_EXTMEM variable indicates whether an external memory such as DRAM is used.

The Makefile compiles and runs the software in the `../iob_soc_Vx.y/hardware/simulation` directory. The Makefile includes the `../iob_soc_Vx.y/hardware/simulation/sim_build.mk`, which you can change for your project. To run a simulation test comprising several simulations with different parameters, run
```Bash
make sim-test
```
The simulation test contents can be edited in IOb-SoC's top Makefile. 

Each simulator must be described in the [`../iob_soc_Vx.y/hardware/simulation/<simulator>.mk`](https://github.com/IObundle/py2hwsw/tree/main/py2hwsw/hardware/simulation) file. For example, the file `vcs.mk` describes the VCS simulator.

The simulator will timeout after GRAB_TIMEOUT seconds, which is 300 seconds by default. Its value can be specified in the `../iob_soc_Vx.y/hardware/simulation/sim_build.mk` Makefile segment, for example, as
```Bash
GRAB_TIMEOUT ?= 3600
```


## Run on FPGA board

To build and run IOb-SoC on an FPGA board, the FPGA design tools must be
installed locally. The FPGA board must also be attached to the local host.

Each board must be described under the [`../iob_soc_Vx.y/hardware/fpga/<tool>/<board_dir>`](https://github.com/IObundle/py2hwsw/tree/main/py2hwsw/hardware/fpga) directory.
For example, the [`../iob_soc_Vx.y/hardware/fpga/vivado/basys3`](https://github.com/IObundle/py2hwsw/tree/main/py2hwsw/hardware/fpga/vivado/basys3) directory contents describe the board BASYS3, which has an FPGA device that can be programmed by the Xilinx/AMD Vivado design tool.

To build an FPGA design of an IOb-SoC system and run it on the board located in the `board_dir` directory, type
```Bash
make fpga-run [BOARD=<board_dir>] [INIT_MEM=0|1] [USE_EXTMEM=0|1]
```

To run an FPGA test comparing the result to the expected result, run
```Bash
make fpga-test
```
The FPGA test contents can be edited in IOb-SoC's top Makefile. 

<!--
# TODO: Explain the `board_client`/`board_server` program. It is also used in local machines.
#       Maybe remove the script that uses them in local machines.
-->

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

## Use another Py2HWSW version

By default, when running the `nix-shell` tool, it will build an environment that contains the Py2HWSW version specified in first lines of the [default.nix file](https://github.com/IObundle/iob-soc/blob/main/default.nix#L8).
You can update the `py2hwsw_commit` and `py2hwsw_sha256` lines of that file to use another version of Py2HWSW from the IObundle's github repository.


If you cloned the Py2HWSW repository to a local directory, you can use that directory as a source for the Py2HWSW nix package.
To use a local directory as a source for Py2HWSW, set the following environment variable with the path to the Py2HWSW root directory:
```Bash
export PY2HWSW_ROOT=/path/to/py2hwsw_root_dir
```


# Acknowledgements

First of all, we acknowledge all the volunteer contributors for all their valuable pull requests, issues, and discussions. 

The work has been partially performed in the scope of the A-IQ Ready project, which receives funding within Chips Joint Undertaking (Chips JU) - the Public-Private Partnership for research, development, and innovation under Horizon Europe – and National Authorities under grant agreement No. 101096658.

The A-IQ Ready project is supported by the Chips Joint Undertaking (Chips JU) - the Public-Private Partnership for research, development, and innovation under Horizon Europe – and National Authorities under Grant Agreement No. 101096658.

<!--
# TODO: Fix these broken image links
-->
![image](https://github.com/IObundle/iob-system/assets/5718971/78f2a3ee-d10b-4989-b221-71154fe6e409) ![image](https://github.com/IObundle/iob-system/assets/5718971/d57e0430-bb60-42e3-82a3-c5b6b0417322)


This project provides the basic infrastructure to other projects funded through the NGI Assure Fund, a fund established by NLnet
with financial support from the European Commission's Next Generation Internet program under the aegis of DG Communications Networks, Content, and Technology.

<table>
    <tr>
        <td align="center" width="50%"><img src="https://nlnet.nl/logo/banner.svg" alt="NLnet foundation logo" style="width:50%"></td>
        <td align="center"><img src="https://nlnet.nl/image/logos/NGIAssure_tag.svg" alt="NGI Assure logo" style="width:50%"></td>
    </tr>
</table>
