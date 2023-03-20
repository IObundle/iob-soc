# README #

## What is this repository for? ##

The IObundle AXISTREAM is a RISC-V-based Peripheral written in Verilog, which users
can download for free, modify, simulate and implement in FPGA or ASIC. It is
written in Verilog and includes a C software driver.  The IObundle AXISTREAM is a
very compact IP that works at high clock rates if needed. 

This repository contains both the AXISTREAM_IN and AXISTREAM_OUT peripherals.
The configuration and sources for these peripherals are located within the `axistream_in` and `axistream_out` folders, respectivly.

## Integrate in SoC ##

* Check out [IOb-SoC](https://github.com/IObundle/iob-soc)

## Clean all generated files ##
To clean all generated files, the command is simply
```
make clean-all
```
