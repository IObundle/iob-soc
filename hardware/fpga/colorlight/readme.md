# IoB-SoC on Colorlight boards

The Colorlight board family is a powerful and versatile solution for managing LED displays. These FPGA-based boards, equipped with Lattice ECP5 FPGA, are primarily designed for the purpose of controlling large LED video panels, but they offer much more than just that: it allows you to leverage a fully open-source FPGA development toolchain.

> For the price of a gourmet hamburger, you get an FPGA that’s big enough to run a RISC-V softcore, two 166 MHz, 2 MB SDRAMS, flash for the FPGA bitstream, a bazillion digital outputs on 5 V level shifters, and two gigabit Ethernet ports. The JTAG port is broken out in 0.1″ headers, and it works with OpenOCD, which is ridiculously convenient. How’s that for a well-stocked budget FPGA dev board that’s served by a completely open source toolchain?

*(Source: https://hackaday.com/2020/01/24/new-part-day-led-driver-is-fpga-dev-board-in-disguise/)*

## Dependencies
You can program these boards using **a fully open source toolchain**:
- [yosys](https://github.com/YosysHQ/yosys) – Yosys Open Synthesis Suite.
- [nextpnr-ecp5](https://github.com/YosysHQ/nextpnr) - A portable FPGA place and route tool (for Lattice ECP5 FPGA).
- [prjtrellis](https://github.com/YosysHQ/prjtrellis) - Device database and tools for bitstream creation (fully open source flow for ECP5 FPGA).
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader) - Universal utility for programming FPGA

## REVISION
Colorlight boards have different revisions, for example, `Colorlight 5A-75E` has revision `6.0`, `7.1` and `8.0`.
In this case, each board hardware/pin mapping may differ, so you if you are using a board with different revisions, you must set `REVISION` variable to your revision, e.g:

> When building, specify it like this:
```
make fpga-build BOARD=COLORLIGHT_5A-75E REVISION=6.0
```

**or**

Change it on `config.mk`.

⚠️ **This is important because, the pin constraints file (`.lpf`) is auto generated depending on the board revision.** You can add/change/remove pin constraints on each board by changing `BOARD_NAME/pin_constraints.tcl` source file. ⚠️

Boards with its revisions:
- Colorlight 5A-75E
  - `6.0` ([hardware information](./COLORLIGHT_5A-75E/doc/hardware_V6.0.md))
  - `7.1` ([hardware information](./COLORLIGHT_5A-75E/doc/hardware_V7.1.md))
  - `8.0` ([hardware information](./COLORLIGHT_5A-75E/doc/hardware_V6.0.md))
- Colorlight i5
  - `7.0`
- Colorlight 5A-75B
  - `6.1` ([hardware information](./COLORLIGHT_5A-75B/doc/hardware_V6.1.md))
  - `7.0` ([hardware information](./COLORLIGHT_5A-75B/doc/hardware_V7.0.md))
  - `8.0` ([hardware information](./COLORLIGHT_5A-75B/doc/hardware_V8.0.md))

## Logging
When building for these boards, all compilation (synthesis/place&route) logs are stored inside:
- `BOARD/top_system_synthesis.log`
- `BOARD/top_system_pnr.log`

## Adding support for a new Colorlight board
To add support for a new Colorlight board, you must:
- Create its folder (e.g: `5A-75E/`)
- Inside board folder, it must have:
  - `Makefile` (the other examples should be easy to follow and understand)
  - `pin_constraints.tcl`: This file needs to define: **possible board revisions**, **pin constraints** and **extra place&route arguments** for each board (check [5A-75E example](5A-75E/pin_constraints.tcl))
  - `verilog/top_system.v`: Top system Verilog source file
  - `doc/`: Folder with documentation about the board/FPGA