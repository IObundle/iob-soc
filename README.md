# README #

## What is this repository for? ##

The IObundle UART is a RISC-V-based Peripheral written in Verilog, which users
can download for free, modify, simulate and implement in FPGA or ASIC. It is
written in Verilog and includes a C software driver.  The IObundle UART is a
very compact IP that works at high clock rates if needed. It supports
full-duplex operation and a configurable baud rate. The IObundle UART has a
fixed configuration for the Start and Stop bits. More flexible licensable
commercial versions are available upon request.

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

To generate an FPGA neltlist for the UART core type:
```
make fpga-build [FPGA_FAMILY=<fpga family>]
```
where <fpga family> is the FPGA family's folder name

To generate all FPGA families for the UART core type:
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
