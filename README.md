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

To visualize the waveforms type:
```
make sim-waves
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
make fpga [FPGA_FAMILY=<fpga family>]
```
where <fpga family> is the FPGA family's folder name

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

To clean the documentation generated files type:
```
make doc-clean [DOC=<doc type name>]
```

To clean the documentation generated files for all document types, the command is
```
make doc-clean-all
```


## Integrate in SoC ##

* Check out [IOb-SoC](https://github.com/IObundle/iob-soc)

## Clean all generated files ##
To clean all generated files, the command is simply
```
make clean
```
