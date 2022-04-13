# README #

# iob-regfileif

## What is this repository for? ##

The IObundle REGFILEIF is a RISC-V-based Peripheral written in Verilog, which users can download, modify, simulate and implement in FPGA or ASIC.  
This peripheral contains registers to buffer communication between two systems using their respective peripheral buses.
It has the internal native interface that connects to the peripheral bus of the system that uses this REGFILEIF as a peripheral.
It also has an external native interface that connects to the native peripheral bus of an external system.

## Simulate

Install the latest stable version of the open-source Verilog simulator Icarus Verilog.

To simulate type:
```
make [sim]
```

To clean the simulation generated files:
```
make sim-clean
```

## Compile and FPGA netlist

Install the FPGA design tools of your favority vendor. Create an FPGA build
folder below folder hardware/simulation/<compiler>/<fpga family>; use the
existing compiler and FPGA family folders as a reference.

Make sure the environmental variables for the tools and licenses you use are are defined. For example:
```
export ALTERAPATH=/path/to/intel/fpga/tools
export XILINXPATH=/path/to/xilinx/fpga/tools
export LM_LICENSE_FILE=port@host:lic_or_dat_file
```

To generate an FPGA neltlist for the REGFILEIF core type:
```
make fpga-build [FPGA_FAMILY=<fpga family>]
```
where <fpga family> is the FPGA family's folder name

To generate all FPGA families for the REGFILEIF core type:
```
make fpga-build-all [FPGA_FAMILY_LIST="<fpga family directory name list>"]
```

If you have the FPGA tools installed on another machine you can run FPGA compilation remotely by setting the following environment variables:

```
export VIVADO_SERVER=<full host name including domain or IP address>
export VIVADO_USER=<your user name at the host>
export QUARTUS_SERVER=<full host name including domain or IP address>
export QUARTUS_USER=<your user name at the host>
```

To clean the FPGA compilation generated files on the local or remote host type:
```
make fpga-clean
```



## Generate the documentation ##

To generate the documentation for the IP core type:
```
make doc-build [DOC=<doc type name>]
```

Currently you can generate two document types: the Product Brief (DOC=pb)
or the User Guide (DOC=ug). To create a new document type get inspired by
the Makefiles in the document type directories document/pb and document/ug. Data
from the FPGA compile tools is imported automatically into the docs.

To generate all documents for the IP core type:
```
make doc-build-all [DOC_LIST="<document directory name list>"]
```

To clean the documentation generated files type:
```
make doc-clean [DOC=<doc type name>]
```

To clean the documentation generated files for all document types, the command is
```
make doc-clean-all
```


## Testing

### Simulation test

To run a series of simulation tests on the simulator selected by the SIMULATOR
variable, type:

```
make sim-test [SIMULATOR=<simulator directory>]
```

The above command produces a test log file called `test.log` in the simulator's
directory. The `test.log` file is compared with the `test.expected` file, which
resides in the same directory; if they differ, the test fails; otherwise, it
passes.

To run the series of simulation tests on all the simulators listed in the
SIMOLATOR\_LIST variable, type:

```
make test-sim [SIMOLATOR_LIST="<simulator directory list>"]
```

where `<simulator directory list>` is the list of sub-directories in directory
`hardware/simulation`, which correspond to simulator names.

To clean the files produced when testing all simulators, type:

```
make test-sim-clean
```


### FPGA family test

To compile and run a series of FPGA family tests on the FPGA family selected by the FPGA\_FAMILY
variable, type:

```
make fpga-test [FPGA_FAMILY=<fpga family directory name>]
```

The above command produces a test log file called `test.log` in the FPGA family's
directory. The `test.log` file is compared with the `test.expected` file, which
resides in the same directory; if they differ, the test fails; otherwise, it
passes.

To run the series of FPGA family tests on all the FPGA families listed in the FPGA\_FAMILY\_LIST
variable, type:

```
make test-fpga [FPGA_FAMILY_LIST="<fpga family directory name list>"]
```

To clean the files produced when testing all FPGA families, type:
```
make test-fpga-clean
```


### Documentation test

To compile and test the document selected by the DOC, variable, type:

```
make doc-test [DOC=<document directory name>]
```

The resulting Latex .aux file is compared with a known-good .aux file. If the
match the test passes; otherwise it fails.

To test all documents listed in the DOC\_LIST variable, type:

```
make test-doc [DOC_LIST="<document directory name list>"]
```

To clean the files produced when testing all documents, type:
```
make test-doc-clean
```

### Total test

To run all simulation, FPGA family and documentation tests,
type:
```
make test
```


## Integrate in SoC ##

* Check out [IOb-SoC](https://github.com/IObundle/iob-soc)

## Clean all generated files ##
To clean all generated files, the command is simply
```
make clean-all
```

## Usage

This peripheral need a register configuration file to determine how many registers it contains and the type of those registers.
This configuration file must be named "iob\_regfileif\_swreg.vh" and is placed in the root directory of the system that is using this component as a peripheral.

The "iob\_regfileif\_swreg.vh" file is based on a group of \`IOB\_SWREG_ macros from IOb-Lib. An example configuration is:
```
`IOB\_SWREG_W(REGFILEIF_REG1, 8, 0) // Write register: 8 bit
`IOB\_SWREG_R(REGFILEIF_REG3, 8, 0) // Read register: 8 bit
```

When the system is built, the values from the configuration file are automatically read, and the peripheral is created according to the configuration.
The internal native interface connects automatically to the peripheral bus, while the external native interface is available to be used externally.

### Connecting peripheral buses of SUT and Tester systems

When using two systems, such as SUT and Tester, the REGFILEIF is a peripheral of the SUT.

The connection between the REGFILEIF's external native interface and the peripheral bus of the Tester can be made using the peripheral\_portmap.txt

However, to connect using the portmap, the native bus signals of the Tester must be externally accessible (the portmap configuration can only map signals that can be accessed externally).
To do this, we use the peripheral **IOBNATIVEBRIDGEIF**. This peripheral also has two native interfaces, one internal and one external, however, unlike REGFILEIF, the external interface of this peripheral is made to be connected to the native interface of another peripheral. The IOBNATIVEBRIDGEIF, allows the peripheral bus signals of the system to be accessed externally.

We use the IOBNATIVEBRIDGEIF as a peripheral of the Tester to allows its peripheral bus signals to be accessed externally (and therefore be portmapped).
To create the IOBNATIVEBRIDGEIF we use the `software/python/iobnativebridge.py` script. We call this script along with the path to the directory in which the peripheral will be created.
For example, if we are in the root directory of the system, we use:
```
./submodules/REGFILEIF/software/python/iobnativebridge.py submodules/
```
The command above creates the IOBNATIVEBRIDGEIF peripheral inside de submodules folder.

We then change the PERIPHERALS and TESTER\_PERIPHERALS lists in config.mk to contain REGFILEIF and IOBNATIVEBRIDGEIF, respectively.

Using the tester-portmap target, we generate a template for the portmap configuration file:
```
make tester-portmap
```

In the portmap file, we connect the regfileif signals and nativebridgeif signals together, and then the complete system is ready to be built!
Example connection if peripheral\_portmap.txt file:
```
SUT.REGFILEIF[0].REGFILEIF_valid : Tester.IOBNATIVEBRIDGEIF[0].IOBNATIVEBRIDGEIF_valid
SUT.REGFILEIF[0].REGFILEIF_address : Tester.IOBNATIVEBRIDGEIF[0].IOBNATIVEBRIDGEIF_address
SUT.REGFILEIF[0].REGFILEIF_wdata : Tester.IOBNATIVEBRIDGEIF[0].IOBNATIVEBRIDGEIF_wdata
SUT.REGFILEIF[0].REGFILEIF_wstrb : Tester.IOBNATIVEBRIDGEIF[0].IOBNATIVEBRIDGEIF_wstrb
SUT.REGFILEIF[0].REGFILEIF_rdata : Tester.IOBNATIVEBRIDGEIF[0].IOBNATIVEBRIDGEIF_rdata
SUT.REGFILEIF[0].REGFILEIF_ready : Tester.IOBNATIVEBRIDGEIF[0].IOBNATIVEBRIDGEIF_ready
```

---

(Enhancement for the future: allow bidirectional registers if no config file is found)
