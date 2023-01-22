# IoB-SoC on Colorlight 5A-75E board (Lattice ECP5 FPGA)

## Dependencies
You can program this board FPGA using **a fully open source toolchain**:
- [yosys](https://github.com/YosysHQ/yosys) – Yosys Open Synthesis Suite.
- [nextpnr-ecp5](https://github.com/YosysHQ/nextpnr) - A portable FPGA place and route tool (for Lattice ECP5 FPGA).
- [prjtrellis](https://github.com/YosysHQ/prjtrellis) - Device database and tools for bitstream creation (fully open source flow for ECP5 FPGA).
- [openFPGALoader](https://github.com/trabucayre/openFPGALoader) - Universal utility for programming FPGA

## Info

### REVISION
This board has different revisions: `6.0`, `7.1` and `8.0`.
Each board hardware/pin mapping may differ, so you must set `REVISION` variable to your revision, e.g:

> When building, specify it like this:
```
make fpga-build BOARD=5A-75E REVISION=6.0
```

**or**

> Change it on `config.mk`.

This is important because, the pin constraints file (**`.lpf`**) is auto generated depending on the board revision.

### Logging
When building for this board, all compilation logs are stored inside:
- `top_system_synthesis.log`
- `top_system_pnr.log`