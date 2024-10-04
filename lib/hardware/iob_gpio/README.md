<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# README #

# iob-gpio

## What is this repository for? ##

The IObundle GPIO is a RISC-V-based Peripheral written in Verilog, which users can download, modify, simulate and implement in FPGA or ASIC.
This peripheral provides a General Purpose Input/Output interface with up to 32 inputs and 32 outputs.
The tri-state output logic is supported via external tri-state buffers using the output enable interface of this peripheral.

This peripheral can be used as a verification tool of the [OpenCryptoTester](https://nlnet.nl/project/OpenCryptoTester#ack) project.

## Integrate in SoC ##

* Check out [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut)

## Usage

This peripheral has three 32-bit registers, one for each interface it provides.
It has three interfaces with up to 32 ports:
- The `input_ports` input contains a set of ports, whose value can be read via `gpio_get()` function. This function returns a 32-bit value, where each bit corresponds to the value of the corresponding input port.
- The `output_ports` output contains a set of ports, whose value can be set via `gpio_set(value)` function. This function sets a 32-bit value, where each bit corresponds to the value of the corresponding output port. 
- The `output_enable` output contains a set of ports, whose value can be set via `gpio_set_output_enable(value)` function. This function sets a 32-bit value, where each bit corresponds to the value of the corresponding output port. 

The `output_enable` interface is used to trigger external tri-state buffers for the `output_ports`.

The number of ports is configurable via the `GPIO_W` Verilog parameter. If the `GPIO_W` parameter is less than 32, the most significant bits of the functions above will be ignored, as they will not match an existing port.


To instantiate the peripheral, add a dictionary describing the peripheral in the `peripherals` list of the `blocks` dictionary in the setup Python module of the system.

The `iob_soc_sut_setup.py` script of the [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut) system, uses the following dictionary to instantiate a GPIO peripheral with the instance name `GPIO0`:
```Python
blocks = \
[
    # Other blocks here...

    {'name':'peripherals', 'descr':'peripheral modules', 'blocks': [
        {'name':'GPIO0', 'type':'GPIO', 'descr':'GPIO interface', 'params':{}},

        # Other peripheral instances here...
    ]},
]
```

# Acknowledgement
The [OpenCryptoTester](https://nlnet.nl/project/OpenCryptoTester#ack) project is funded through the NGI Assure Fund, a fund established by NLnet
with financial support from the European Commission's Next Generation Internet
programme, under the aegis of DG Communications Networks, Content and Technology
under grant agreement No 957073.

<table>
    <tr>
        <td align="center" width="50%"><img src="https://nlnet.nl/logo/banner.svg" alt="NLnet foundation logo" style="width:90%"></td>
        <td align="center"><img src="https://nlnet.nl/image/logos/NGIAssure_tag.svg" alt="NGI Assure logo" style="width:90%"></td>
    </tr>
</table>
