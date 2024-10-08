<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# README #

# iob-uart

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
make setup
make -C iob_uart_V0.70/ sim-run
```

To clean the simulation generated files:
```
make -C iob_uart_V0.70/ sim-clean
```

## Testing

### Simulation test

To run a series of simulation tests, type:

```
make setup
make -C iob_uart_V0.70/ sim-test
```

The above command produces a test log file called `test.log` in the `iob_uart_V0.70/hardware/simulation/`
directory. The `test.log` file is compared with the `Test passed!` string; if they differ, the test fails; otherwise, it
passes.

To clean the files produced when testing all simulators, type:

```
make -C iob_uart_V0.70/ sim-clean
```

## Integrate in SoC ##

* Check out [IOb-SoC](https://github.com/IObundle/iob-soc)

## Usage

This peripheral has a set of driver functions, declared in the `software/src/iob-uart.h` file.
These functions allow the primary system to control this peripheral to receive and send UART messages.
The `iob_soc_firmware.c` file of the [IOb-SoC](https://github.com/IObundle/iob-soc) provides an example on how to use these functions.

To instantiate the peripheral, add a dictionary describing the peripheral in the `peripherals` list of the `blocks` dictionary in the setup Python module of the system.

The `iob_soc_setup.py` script of the [IOb-SoC](https://github.com/IObundle/iob-soc) system, uses the following dictionary to instantiate a UART peripheral with the instance name `UART0`:
```Python
blocks = \
[
    # Other blocks here...

    {'name':'peripherals', 'descr':'peripheral modules', 'blocks': [
        {'name':'UART0', 'type':'UART', 'descr':'Default UART interface', 'params':{}},

        # Other peripheral instances here...
    ]},
]
```


## Generate the documentation ##

To generate the documentation for the IP core type:
```
make setup
make -C iob_uart_V0.70/ doc-build [DOC=<doc type name>]
```

Currently you can generate two document types: the Product Brief (DOC=pb)
or the User Guide (DOC=ug). To create a new document type get inspired by
the Makefiles in the document type directories document/pb and document/ug. Data
from the FPGA compile tools is imported automatically into the docs.

To clean the documentation generated files type:
```
make -C iob_uart_V0.70/ doc-clean [DOC=<doc type name>]
```


## Clean all generated files ##
To clean all generated files, the command is simply
```
make clean
```
