<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# README #

# iob-regfileif

## What is this repository for? ##

The IObundle REGFILEIF is a RISC-V-based Peripheral written in Verilog, which users can download, modify, simulate and implement in FPGA or ASIC.
This peripheral contains registers to buffer communication between two systems using their respective peripheral buses.
It provides an external IOb-native interface to the secondary system, allowing it to be controlled via registers by another primary system.

This peripheral has two IOb-native interfaces:
- It has the internal IOb-native interface that connects to the peripheral bus of the system that will be controlled and contains the registers.
- It also has an external IOb-native interface that connects to the native peripheral bus of an external (primary) system.

This repository also provides a peripheral for the primary system, that allows it to access registers of the secondary system.
This peripheral, named IOBNATIVEBRIDGEIF is located in the `nativebridgeif_wrappper` directory of this repository.

The IOBNATIVEBRIDGEIF can be used by primary systems like the [IOb-SoC-Tester](https://github.com/IObundle/iob-soc-tester) [project](https://nlnet.nl/project/OpenCryptoTester#ack), to access registers of a secondary system like the [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut).

## Integrate in SoC ##

* Check out [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut)

## Usage

This peripheral receives its register configuration via module parameters.

The module parameters passed to this peripheral should be a dictionary that contains a list of registers as a value to the `regs` key of the dictionary.
The list of the `regs` item has a similar structure to the `regs` list of any IOb-SoC-based peripheral's setup module, such as in the `iob_uart_setup.py` script of the [IOb-uart](https://github.com/IObundle/iob-uart) peripheral.

The `iob_soc_sut_setup.py` script of the [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut) system, has the following example configuration for the REGFILEIF peripheral:
```Python
regfileif_options = {
    'regs':
    [
        {'name': 'regfileif', 'descr':'REGFILEIF software accessible registers.', 'regs': [
            {'name':'REG1','type':'W', 'n_bits':8,  'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':'Write register: 8 bit'},
            {'name':'REG2','type':'W', 'n_bits':16, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':'Write register: 16 bit'},
            {'name':'REG3','type':'R', 'n_bits':8,  'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':'Read register: 8 bit'},
            {'name':'REG4','type':'R', 'n_bits':16, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':'Read register 16 bit'},
            {'name':'REG5','type':'R', 'n_bits':32, 'rst_val':0, 'addr':-1, 'log2n_items':0, 'autologic':True, 'descr':'Read register 32 bit.'},
        ]}
    ]
}
```

These options are then passed to the REGFILEIF peripheral of the system using module parameters.
To do this, use a tuple in the `modules` list of the `submodules` dictionary, where the first element of the tuple is the module name and the second element is the module parameters.

The `iob_soc_sut_setup.py` script uses the following tuple to pass the module parameters above to the REGFILEIF peripheral:
```Python
('REGFILEIF',regfileif_options)
```

To instantiate the peripheral, add a dictionary describing the peripheral in the `peripherals` list of the `blocks` dictionary in the setup python module of the system.

The `iob_soc_sut_setup.py` script uses the following dictionary to instantiate a REGFILEIF peripheral with the instance name `REGFILEIF0`:
```Python
blocks = \
[
    # Other blocks here...

    {'name':'peripherals', 'descr':'peripheral modules', 'blocks': [
        {'name':'REGFILEIF0', 'type':'REGFILEIF', 'descr':'Register file interface', 'params':{}},

        # Other peripheral instances here...
    ]},
]
```

### Connecting peripheral buses of SUT and Tester systems

When using two systems, such as [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut) and [IOb-SoC-Tester](https://github.com/IObundle/iob-soc-tester), the REGFILEIF is a peripheral of the SUT.

The connection between the external IOb-native interface of the system with the REGFILEIF and the peripheral bus of the Tester can be made using the `peripheral_portmap` list of the Tester.

However, to connect using the portmap, the IOb-native bus signals of the Tester must be externally accessible (the portmap configuration can only map signals that can be accessed externally).

To do this, we use the peripheral **IOBNATIVEBRIDGEIF**, located inside the `nativebridgeif_wrappper` directory of this repository.
This peripheral also has two IOb-native interfaces, one internal and one external.
However, unlike REGFILEIF, the external interface of this peripheral is a master interface. This allows it to be connected to the slave IOb-native interface of another module, such as the REGFILEIF.
The IOBNATIVEBRIDGEIF, allows the peripheral bus signals of the system to be accessed externally.

We use the IOBNATIVEBRIDGEIF as a peripheral of the Tester to allow its peripheral bus signals to be accessed externally, and therefore be port mapped.

To instantiate the IOBNATIVEBRIDGEIF peripheral we add a new dictionary to the `peripherals` list of the `blocks` dictionary, similar to the REGFILEIF instantiation.

In the `iob_soc_sut_setup.py` script, the IOBNATIVEBRIDGEIF is a peripheral of the Tester, therefore it is instantiated in the `extra_peripherals` list of the Tester module parameters:
```Python
    'extra_peripherals':
    [
        {'name':'IOBNATIVEBRIDGEIF0', 'type':'IOBNATIVEBRIDGEIF', 'descr':'IOb native interface for communication with SUT. Essentially a REGFILEIF without any registers.', 'params':{}},

        # Other peripheral instances here...
    ],
```

To connect the external IOb-native (slave) interface of the REGFILEIF of the SUT to the external IOb-native (master) interface of the IOBNATIVEBRIDGEIF of the Tester, the `iob_soc_sut_setup.py` script contains the following configuration in the `peripheral_portmap` list of the Tester module parameters:
```Python
    'peripheral_portmap':
    [
        ({'corename':'SUT0', 'if_name':'REGFILEIF0', 'port':'external_iob_valid_i', 'bits':[]}, {'corename':'IOBNATIVEBRIDGEIF0', 'if_name':'iob_m_port', 'port':'iob_valid_o', 'bits':[]}),
        ({'corename':'SUT0', 'if_name':'REGFILEIF0', 'port':'external_iob_addr_i', 'bits':[]}, {'corename':'IOBNATIVEBRIDGEIF0', 'if_name':'iob_m_port', 'port':'iob_addr_o', 'bits':[]}),
        ({'corename':'SUT0', 'if_name':'REGFILEIF0', 'port':'external_iob_wdata_i', 'bits':[]}, {'corename':'IOBNATIVEBRIDGEIF0', 'if_name':'iob_m_port', 'port':'iob_wdata_o', 'bits':[]}),
        ({'corename':'SUT0', 'if_name':'REGFILEIF0', 'port':'external_iob_wstrb_i', 'bits':[]}, {'corename':'IOBNATIVEBRIDGEIF0', 'if_name':'iob_m_port', 'port':'iob_wstrb_o', 'bits':[]}),
        ({'corename':'SUT0', 'if_name':'REGFILEIF0', 'port':'external_iob_rvalid_o', 'bits':[]}, {'corename':'IOBNATIVEBRIDGEIF0', 'if_name':'iob_m_port', 'port':'iob_rvalid_i', 'bits':[]}),
        ({'corename':'SUT0', 'if_name':'REGFILEIF0', 'port':'external_iob_rdata_o', 'bits':[]}, {'corename':'IOBNATIVEBRIDGEIF0', 'if_name':'iob_m_port', 'port':'iob_rdata_i', 'bits':[]}),
        ({'corename':'SUT0', 'if_name':'REGFILEIF0', 'port':'external_iob_ready_o', 'bits':[]}, {'corename':'IOBNATIVEBRIDGEIF0', 'if_name':'iob_m_port', 'port':'iob_ready_i', 'bits':[]}),

        # Other portmap entries here...
    ],
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
