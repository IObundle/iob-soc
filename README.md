<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# IOb-SoC:

IOb-SoC is a System-on-Chip (SoC) described in Python, using the [Py2HWSW](https://github.com/IObundle/py2hwsw/blob/main/py2hwsw/lib/default.nix) framework. The SoC is entirely described in a few lines of Python. The Py2HWSW framework describes SoCs with a main [VexRiscv](https://github.com/SpinalHDL/VexRiscv) CPU by adding C software and a list of peripherals. After a setup procedure, Py2HWSW creates a build directory with all the sources and makefiles to build and run various tools on the Soc, such as simulation, synthesis, and FPGA prototyping; the SoC is described in Verilog. The Py2HWSW framework also has a comprehensive library of prebuilt modules and peripherals, including their bare-metal drivers. IObSoC uses the 
iob-uart and iob-timer from this library. The external memory interface uses an AXI4 master bus. It may be used to access an on-chip RAM or a 3rd party memory controller IP (typically a DDR controller).

  
## Dependencies

IOb-SoC needs the [Py2HWSW](https://github.com/IObundle/py2hwsw/blob/main/py2hwsw/lib/default.nix) framework.


## Operating Systems

IOb-SoC can run on most mainstream Linux distributions. The reference distribution is Ubuntu 24.04.1 LTS.


## SoC Configuration

The SoC configuration is in the `iob_soc.py` file at the repository root. To create your own SoC description, follow the instructions in the Py2HWSW user guide. 


## Setup the SoC by Creating the build directory

At the repository root, there is a Makefile with some ready-to-use commands, assuming you have nix-shell installed. If you have installed Py2HWSW without nix-shell, edit the make file to remove the nix-shell --run "(...)" command wrappers.
To create the build directory, simply type:

```Bash
make setup
```

The build directory is created in the folder ../iob_soc_Vx.y, where Vx.y is the IObSoC's current version.

The build directory only has source code files and Makefiles. If you do not want to use the Py2HWSW framework, you may, from now on, only use the build directory, provided you have installed all the tools that makefiles will call outside the nix-shell environment.

## Emulate the system on PC

You can *emulate* IOb-SoC's on a PC to develop and debug your embedded software. A model to emulate the UART uses a Python console server that comes with Py2HWSW. The same server is used to communicate with FPGA targets.
If you develop peripherals, you can build embedded software models for PC emulation. To emulate IOb-SoC's embedded software on a PC, type:

```Bash
make pc-emul-run
```
<!--
# TODO: iob-soc repo no longer has sw_build.mk (it comes from iob-system). Should we add it back?
-->
The Makefile compiles and runs the software in the `../iob_soc_Vx.y/software/` directory. The Makefile includes the `sw_build.mk` segment supplied initially in the same directory. Please feel free to change this file for your specific project. To run an emulation test comparing the result to the expected result, run
```Bash
make pc-emul-test
```

## Simulate the system

To simulate IOb-SoC's RTL using a Verilog simulator, run:
```Bash
make sim-run [SIMULATOR=icarus!verilator|xcelium|vcs|questa] [INIT_MEM=0|1] [USE_EXTMEM=0|1]
```

This target compiles the software and hardware and simulates in the `../iob_soc_Vx.y/hardware/simulation` directory. The `../iob_soc_Vx.y/hardware/simulation/sim_build.mk` makefile segment allows users to change the simulation settings.
The INIT_MEM variable specifies whether the firmware is initially loaded in the memory, skipping the boot process, and the USE_EXTMEM variable indicates whether an external memory such as DRAM is used.

To run a simulation test comprising a few configurations and two simulators, type:
```Bash
make sim-test
```

The settings for each simulator are described in the [`../iob_soc_Vx.y/hardware/simulation/<simulator>.mk`](https://github.com/IObundle/py2hwsw/tree/main/py2hwsw/hardware/simulation) file. For example, file `icarus.mk` describes the settings for the Icarus Verilog simulator.

The simulator will timeout after GRAB_TIMEOUT seconds, which is 300 seconds by default. Its value can be specified in the `../iob_soc_Vx.y/hardware/simulation/sim_build.mk` Makefile segment, for example, as
```Bash
GRAB_TIMEOUT ?= 3600
```


## Run on FPGA board

The FPGA design tools must be installed locally to build and run IOb-SoC on an FPGA board. The FPGA board must also be attached to the local host. Currently, only AMD (Xilinx) and Altera boards are supported.

The board settings are in the  [`../iob_soc_Vx.y/hardware/fpga/<tool>/<board_dir>`](https://github.com/IObundle/py2hwsw/tree/main/py2hwsw/hardware/fpga) directory, where ""
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

First, we acknowledge all the volunteer contributors for all their valuable pull requests, issues, and discussions. 

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
