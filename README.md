# IOb-SoC-(OpenCrypto)Tester

This [project](https://nlnet.nl/project/OpenCryptoTester#ack) aims to develop a System-on-Chip (SoC) used mainly to verify cryptographic systems that improve internet security but can also be used on any SoC. It is synergetic with several other NGI Assure-funded open-source projects - notably [OpenCryptoHW](https://nlnet.nl/project/OpenCryptoHW) (Coarse-Grained Reconfigurable Array cryptographic hardware) and [OpenCryptoLinux](https://nlnet.nl/project/OpenCryptoLinux). The proposed SoC will support test instruments as peripherals and use OpenCryptoHW as the System Under Test (SUT), hopefully opening the way for open-source test instrumentation operated under Linux.

This repository is a Tester SoC based on [IOb-SoC](https://github.com/IObundle/iob-soc).

An example System Under Test with this Tester configured is available at the [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut) repository.

This system is compatible with any Unit Under Tester (UUT) as it does not impose any hardware constraints.
Nonetheless, the UUT's repository must follow the [set of minimum requirements](#uuts-repository-minimum-requirements) presented below.

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
IOb-SoC-Tester in a [Nix](https://nixos.org/) environment with all dependencies
available except for Vivado and Quartus.

- Run `nix-shell` from the IOb-SoC-Tester root directory to install and start the environment with all the required dependencies.


## UUT's Repository Minimum Requirements

The Unit Under Test (UUT) repository must contain at least the `<uut_name>_setup.py` file to be compatible with this Tester:

The `<uut_name>_setup.py` python script provides the Tester with information about the UUT, and should contain the following objects:

- Must contain the `name` string variable.
- Must contain the `confs` dictionary variable.
- Must contain the `ios` dictionary variable.

### name

The `name` variable should contain a string equal to the name of the UUT's Verilog top module.

### confs

The `confs` variable should be a dictionary with a similar structure to the one in the `iob_soc_tester_setup.py` file.
This dictionary informs the Tester of the parameters available for the UUT's Verilog top module.

### ios

The `ios` variable should be a dictionary with a similar structure to the one in the `iob_soc_tester_setup.py` file.
This dictionary informs the Tester of the IOs in the UUT's Verilog top module.

## Clone the Tester's repository

If the UUT's repository is git based, then we suggest adding this Tester's repository as a git submodule.

To add this repository as a git submodule inside the `submodules/` folder, from the UUT's repository, run:

```Bash
git submodule add git@github.com:IObundle/iob-soc-tester.git submodules/TESTER
git submodule update --init --recursive
```

Otherwise, clone the Tester's repository to a location of your choosing with the following command:

```Bash
git clone --recursive git@github.com:IObundle/iob-soc-tester.git
```

## Configure the Tester

The Tester's setup, build and run steps are similar to the ones used in [IOb-SoC](https://github.com/IObundle/iob-soc).
Check the `README.md` file of that repository for more details on the process of setup, building and running IOb-SoC-based systems.

The Tester's main configuration is stored in `iob_soc_tester_setup.py` python script.
Most configurations in this file are similar to the ones in [`iob_soc_setup.py`](https://github.com/IObundle/iob-soc/blob/python-setup/iob_soc_setup.py).

The only Tester-specific configurations that must be modified according to the UUT, are located inside the `module_parameters` dictionary variable of the `iob_soc_tester_setup.py` file.

When adding a new UUT, the modifications required in the `module_parameters` dictionary are the following:

1. Add an entry to the `extra_peripherals_dirs` dictionary with the UUT's 'type' name and path to the directory containing the `<uut_name>_setup.py` file.
2. Add an entry to the `extra_peripherals` dictionary with the UUTs instance name, 'type' name, description, and optionally Verilog parameters to pass to that instance.
3. Add an entry to the `peripheral_portmap` dictionary for each IO of the UUT instance. Each entry defines where to connect the UUT IO ports. Each entry may map a single bit, selected bits, an entire port or an entire interface.

As an example, see the `tester_options` dictionary variable from the `iob_soc_sut_setup.py` script in the [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut) repository.
The `tester_options` dictionary variable of the SUT's repository overrides the default `module_parameters` dictionary of the Tester.

## Setup, build and run the Tester along with UUT

With the UUT's minimum requirements met, the steps for setup, building and running the Tester are similar to those of [IOb-SoC](https://github.com/IObundle/iob-soc).

To set up the Tester, type:

```Bash
make setup [<control parameters>]
```

`<control parameters>` are system configuration parameters passed in the
command line, overriding those in the `iob_soc_tester_setup.py` file. Example control
parameters are `INIT_MEM=0 USE_EXTMEM=1`. For example,

To build and run the Tester in simulation, type:

```Bash
make -C ../iob_soc_tester_V* sim-run [SIMULATOR=<simulator name>]
```

`<simulator name>` is the name of the simulator's Makefile segment.

To build the Tester for the FPGA, type:

```Bash
make -C ../iob_soc_tester_V* fpga-build [BOARD=<board directory name>]
```

`<board directory name>` is the name of the board's run directory.

To run the Tester in the FPGA, type:

```Bash
make -C ../iob_soc_tester_V* fpga-run [BOARD=<board directory name>]
```

## Cleaning

The following command will clean the selected simulation, board and document
directories, locally and in the remote servers:

```Bash
make -C ../iob_soc_tester_V* clean
```

The following command will delete the build directory:

```Bash
make clean
```

# Acknowledgement
This project is funded through the NGI Assure Fund, a fund established by NLnet
with financial support from the European Commission's Next Generation Internet
programme, under the aegis of DG Communications Networks, Content and Technology
under grant agreement No 957073.

<table>
    <tr>
        <td align="center" width="50%"><img src="https://nlnet.nl/logo/banner.svg" alt="NLnet foundation logo" style="width:90%"></td>
        <td align="center"><img src="https://nlnet.nl/image/logos/NGIAssure_tag.svg" alt="NGI Assure logo" style="width:90%"></td>
    </tr>
</table>
