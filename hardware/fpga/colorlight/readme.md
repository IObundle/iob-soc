# IoB-SoC on Colorlight

## Dependencies
You can program this boards using **a fully open source toolchain**:
- [yosys](https://github.com/YosysHQ/yosys) – Yosys Open Synthesis Suite.
- [nextpnr-ecp5](https://github.com/YosysHQ/nextpnr) - A portable FPGA place and route tool (for Lattice ECP5 FPGA).
- [prjtrellis](https://github.com/YosysHQ/prjtrellis) - Device database and tools for bitstream creation (fully open source flow for ECP5 FPGA).
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader) - Universal utility for programming FPGA

## $REVISION
This board has different revisions: `6.0`, `7.1` and `8.0`.
Each board hardware/pin mapping may differ, so you must set `REVISION` variable to your revision, e.g:

> When building, specify it like this:
```
make fpga-build BOARD=5A-75E REVISION=6.0
```

**or**

> Change it on `config.mk`.

This is important because, the pin constraints file (**`.lpf`**) is auto generated depending on the board revision.

## Logging
When building for these boards, all compilation (synthesis/place&route) logs are stored inside:
- `BOARD/top_system_synthesis.log`
- `BOARD/top_system_pnr.log`

## Adding support for a new Colorlight board
To add support for a new Colorlight board, you must:
- Create its folder (e.g: `5A-75E/`)
- Inside board folder, it must have:
  - `Makefile` (the other examples should be easy to follow and understand)
  - `pin_constraints.tcl`: This file defines possible board revisions and pin mapping for each one
  - `verilog/top_system.v`: Top system Verilog source file
  - `doc/`: Folder with documentation about the board/FPGA