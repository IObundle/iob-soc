# IOb-SoC-(OpenCrypto)Tester

This [project](https://nlnet.nl/project/OpenCryptoTester#ack) aims to develop a System-on-Chip (SoC) used mainly to verify cryptographic systems that improve internet security but can also be used on any SoC. It is synergetic with several other NGI Assure-funded open-source projects - notably [OpenCryptoHW](https://nlnet.nl/project/OpenCryptoHW) (Coarse-Grained Reconfigurable Array cryptographic hardware) and [OpenCryptoLinux](https://nlnet.nl/project/OpenCryptoLinux). The proposed SoC will support test instruments as peripherals and use OpenCryptoHW as the System Under Test (SUT), hopefully opening the way for open-source test instrumentation operated under Linux.

This repository is a Tester SoC based on [IOb-SoC](https://github.com/IObundle/iob-soc).

An example System Under Test with this Tester configured is available at the [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut) repository.

This system is compatible with any Unit Under Tester (UUT) as it does not impose any hardware constraints.
Nonetheless, the UUT's repository must follow the set of minimum requirements presented below.

## UUT's Repository Minimum Requirements

The Unit Under Test (UUT) repository must contain at least the following files and directories to be compatible with this Tester:
- Must contain the `hardware/hardware.mk` file. 
- Must contain the `config.mk` file. 
- Must contain the `hardware/src/` directory, that will house the top module source file.
- Must contain the `submodules/` directory, that will house a folder with this Tester repository.
- Must contain the `peripheral_portmap.conf` file.
- Must contain the `tester.mk` file.
- Must contain the `software/tester_firmware.c` file.
    
### hardware.mk

The `hardware/hardware.mk` Makefile segment of the UUT provides the Tester with Verilog-related information about the UUT. It can also be used to generate UUT sources and headers dynamically.

This file should define the makefile variables: `VSRC`, `VHDR`, `DEFINE`.

The `VSRC` and `VHDR` variables inform the Tester of the location of the UUT's Verilog source and header files. These variables are a whitespace-separated list of file locations.
Makefile targets can also be defined in this file to generate Verilog files from those lists dynamically. The Tester will try to call Makefile targets to generate Verilog files that do not exist.

The `DEFINE` variable is a whitespace-separated list of Verilog macros with the format `macro=definition`.

When the Tester calls this file, it already defines the `ROOT_DIR` and `[UUTNAME]_DIR` variables. Both of them contain the relative path to the root directory of the UUT. This file can use these variables to find the root directory of the UUT independently from where it is called.
`[UUTNAME]` is replaced by the name of the UUT given in the `tester.mk` file.

### config.mk

The `config.mk` Makefile segment of the UUT provides the Tester with the UUT's Verilog top module file name.

This file should define the makefile variable: `TOP_MODULE`.

The `TOP_MODULE` variable contains the file name (without file extension '.v') of the UUT's Verilog top module. The location of this file is given in the `VSRC` list by the `hardware.mk` Makefile segment.

The UUT's Verilog top module has some limitations for compatibility with the Tester:
- This file should only contain one Verilog module.
- The port list of this Verilog module must only use the following keywords for IO port definition: `input`, `output`, `inout`, `IOB_INPUT`, `IOB_OUTPUT`, and `IOB_INOUT`.
- The port list of this Verilog module can not include other Verilog files (except `iob_gen_if.vh` and `iob_s_if.vh`).
- The port list of this Verilog module can not contain compiler directives (except for the `` `include`` directive for the files listed above).

### src directory

The `hardware/src/` directory in the UUT's repository contains the UUT's verilog top module.

### submodules directory

The `submodules/` directory in the UUT's repository should contain a folder (usually named 'TESTER') with this Tester's repository.

If the UUT's repository is git based, then we suggest adding this Tester's repository as a git submodule.

To add this repository as git submodule, from the UUT's repository, run:
```
git submodule add git@github.com:IObundle/iob-soc-tester.git submodules/TESTER
git submodule update --init --recursive
```

### peripheral\_portmap.conf

The `peripheral_portmap.conf` file in the UUT's repository configures connections between the Tester's peripherals, the UUT's IO, and the external Tester interface.

The Tester provides a Makefile target to automatically generate a template for this file with all the required signals. 
This template contains a header with instructions on how to map the signals.

To generate this template, from the UUT's repository, run:
```
make -C submodules/TESTER/ portmap .
```

### tester.mk

The `tester.mk` Makefile segment in the UUT's repository contains the Tester configuration. It may also have additional Makefile targets for generating application-specific files.

The `example_tester.mk` file in this repository can be used as a basis for a new `tester.mk` file. 
It includes commonly used settings along with their descriptions.

The Tester divides this file into two sections, one for Makefile variable/macro definitions and another for Makefile targets.
It will include this Makefile segment twice, one with the `INCLUDING_VARS` variables defined and another without it.

It starts by including this file with `INCLUDING_VARS` defined. Any variables defined by the `tester.mk` during this can be used by other internal Tester macros and targets.
The second time it includes this file without `INCLUDING_VARS` defined. During this call, any targets defined by the `tester.mk` can use internal Tester macros and targets.

### tester\_firmware.c

The `software/tester_firmware.c` file in the UUT's repository contains the Tester's firmware with the verification sequence.

### Optional: software.mk

The `software/software.mk` Makefile segment of the UUT is optional. It provides the Tester with software-related information about the UUT. It can also be used to generate software for the UUT dynamically.

### Optional: boot.hex firmware.hex

The `software/firmware/boot.hex` and `software/firmware/firmware.hex` files in the UUT's repository are optional.
They usually contain the bootloader and firmware for the UUT. The Tester will copy these files to the run directory if they exist.

## Build and run the Tester (along with UUT)

With the UUT's minimum requirements met, the steps for building and running the Tester are similar to those of [IOb-SoC](https://github.com/IObundle/iob-soc).

To build the Tester for simulation, from the UUT's repository, run:
```
make -C submodules/TESTER sim-build
```

To simulate the Tester, from the UUT's repository, run:
```
make -C submodules/TESTER sim-run
```

To build the Tester for FPGA, from the UUT's repository, run:
```
make -C submodules/TESTER fpga-build
```

To run the Tester in the FPGA, from the UUT's repository, run:
```
make -C submodules/TESTER fpga-run
```

To clean Tester build files, from the UUT's repository, run:
```
make -C submodules/TESTER clean
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
