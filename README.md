# AXI4-Stream #

## What is this repository for? ##

The IObundle AXISTREAM is a RISC-V-based Peripheral written in Verilog, which users
can download for free, modify, simulate and implement in FPGA or ASIC. 
This peripheral provides an AXI4-Stream interface for communication with external systems.
It also provides a [Direct Memory Access (DMA)](#direct-memory-access-dma) interface using on another AXI4-Stream interface.

This repository contains both the AXISTREAM_IN and AXISTREAM_OUT peripherals.
The configuration and sources for these peripherals are located within the `axistream_in` and `axistream_out` folders, respectively.

## Integrate in SoC ##

* Check out [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut)

## Usage

The main classes that describe these cores are located in the `iob_axistream_in.py` and `iob_axistream_out.py` Python modules. They contain a set of methods useful to set up and instantiate these cores.

The following steps describe the process of creating an AXISTREAMIN peripheral in an IOb-SoC-based system (the steps for the AXISTREAMOUT peripheral are similar):
1) Import the `iob_axistream_in` class
2) Run the `iob_axistream_in.setup()` method to copy the required sources of this module to the build directory.
3) Run the `iob_axistream_in(...)` method to create a Verilog instance of the AXISTREAMIN peripheral.
4) Use this core as a peripheral of an IOb-SoC-based system:
    1) Add the created instance to the peripherals list of the IOb-SoC-based system.
    2) Write the firmware to run in the system, including the `iob-axistream-in.h` C header and use its driver functions to control this core.

## Example configuration

The `iob_soc_sut.py` script of the [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut) system, uses the following lines of code to instantiate an AXISTREAMIN peripheral with the instance name `AXISTREAMIN0`:
```Python
# Import the iob_axistream_in class
from iob_axistream_in import iob_axistream_in

# Class of the SUT system
class iob_soc_sut(iob_soc):
  ...
  # Method that runs the setup process of the SUT system
  @classmethod
  def _post_setup(cls):
    ...
    # Setup the AXISTREAMIN module (Copies every file and dependency required to the build directory)
    iob_axistream_in.setup()
    ...
    # Create a Verilog instance of this module, named 'AXISTREAMIN0', and add it to the peripherals list of the system.
    cls.peripherals.append(
        iob_axistream_in(
            "AXISTREAMIN0", # Verilog instance name
            "SUT AXI input stream interface", # Instance description

            # Verilog parameters to pass to this instance.
            # In this example, we use a 32-bit TDATA signal.
            parameters={"TDATA_W": "32"},
        )
    )
```

## Direct Memory Access (DMA)

This peripheral provides a DMA interface using AXI4-Stream.
Is also contains the `fifo_threshold` port to be used as an interrupt for the CPU.
This signal can be used to trigger data transfers via DMA.

* Check out [IOb-DMA](https://github.com/IObundle/iob-dma) for more details.

The `iob_soc_tester.py` script of the [IOb-SoC-SUT](https://github.com/IObundle/iob-soc-sut) system, provides examples of AXISTREAM peripherals configured to use the DMA interface.

## Brief description of C interface ##

The AXISTREAM cores store the values in an internal FIFO buffer, which can be accessed via software.

An example of some C code is given, with explanations:

For the AXISTREAMIN peripheral:
```C
//Set AXISTREAMIN base address
axistream_in_init(int base_address);

//Get a 32-bit word from FIFO
uint32_t received_word = axistream_in_pop_word();

//Signal when FIFO empty
bool is_empty = axistream_in_empty();

//Returns if the last value of read from FIFO was the end of frame (by TLAST signal) and gets rstrb from that value
bool was_last = axistream_in_was_last(char *rstrb);

//Pulse soft reset
axistream_in_reset();

//Enable peripheral
axistream_in_enable();

//Disable the tready signal, preventing new transfers
axistream_in_disable();

//Get value from FIFO [can be used instead of axistream_in_pop_word() and axistream_in_was_last()]
//Returns true if this word was tlast, false otherwise
//Arguments:
//    byte_array: byte array to be filled with 4 bytes popped from FIFO word
//    n_valid_bytes: Number of valid bytes in this word (will always be 4 if tlast is not active)
bool is_last = axistream_in_pop(uint8_t *byte_array, uint8_t *n_valid_bytes);

//Set the FIFO threshold level
//If the FIFO level is equal or higher than the threshold, trigger an interrupt
axistream_in_set_fifo_threshold(uint32_t threshold);

//Get current FIFO level
uint32_t fifo_level = axistream_in_fifo_level();
```

For the AXISTREAMOUT peripheral:
```C
//Set AXISTREAMOUT base address
//If the instance has tdata_w > 1 byte, don't use this function to initialize it. Use function: axistream_out_init_tdata_w()
axistream_out_init(int base_address);

//Set AXISTREAMOUT base address and tdata width
axistream_out_init_tdata_w(int base_address, int tdata_w);

//Free memory from initialized instances
axistream_out_free();

//Place value in FIFO, also place wstrb for a word with TLAST signal.
//If tlast_wstrb is zero then all bytes are valid and don't send TLAST signal
//tlast_wstrb has 1 up to 4 bits depending on the output width of the FIFO (width of TDATA signal). 
//If TDATA has 8 bits, then tlast_wstrb has 4 bits (1 for each valid byte of the last 32bit word in FIFO);
//If TDATA has 16 bits, then tlast_wstrb has 2 bits (1 for each valid 16-bit word of the last 32bit word in FIFO);
//If TDATA has 32 bits, then tlast_wstrb has 1 bit (in this case, 32 bits are always valid independently of tlast_wstrb, this bit only selects if we send TLAST signal)
axistream_out_push_word(uint32_t value, char tlast_wstrb);

//Place value in FIFO, also place wstrb for a word with TLAST signal. [can be used instead of axistream_out_push_word()]
//Arguments:
//    byte_array: bytes to insert in fifo
//    n_valid_bytes: number of valid bytes in value, should be multiple of tdata_w
//    is_tlast: if value contains tlast
axistream_out_push(uint8_t *byte_array, uint8_t n_valid_bytes, bool is_tlast);

//Signal when FIFO is full
bool full = axistream_out_full();

//pulse soft reset
axistream_out_reset();

//Enable peripheral
axistream_out_enable();

//Disable peripheral, preventing new transfers
axistream_out_disable();

//Set the FIFO threshold level
//If the FIFO level is equal or lower than the threshold, trigger an interrupt
axistream_out_set_fifo_threshold(uint32_t threshold);

//Get current FIFO level
uint32_t fifo_level = axistream_out_fifo_level();
```
