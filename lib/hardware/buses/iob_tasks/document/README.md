<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# IOb-interface

The IOb Native Interface, or IOb interface shortly, has the following signals
from the slave perspective. (Note that the `_i` and `_o` suffixes denote input
and output, respectively.)
- `clk_i`: interface input clock
- `valid_i`: source signal valid transaction from master input
- `addr_i`: address for read or write access input
- `wdata_i`: data to write
- `wstrb_i`: byte write strobe input
- `rdata_o`: read data
- `rvalid_o`: valid read data
- `ready_o`: slave ready for transaction output

Transactions occur when both `valid_i` and `ready_o` are HIGH for one `clk_i`
period.

Use `wstrb_i` to distinguish between READ and WRITE operations. READ operations
occur when all `wstrb_i` bits are LOW.
Byte `i` is written if `wstrb_i[i]` is HIGH and not otherwise.

## Read Transaction
For READ operations: when `valid_i` and `ready_o` are HIGH, address `addr_i` is
read. The data on `rdata_o` is available when `rvalid_o` is HIGH.

![Example Read Transaction](iob_if_read.png "Read Transaction")

## Write Transaction
For WRITE operations: when `valid_i` and `ready_o` are HIGH, the bytes in
`wdata_i` validated by `wstrb_i` are written to address `addr_i.`

![Example Write Transaction](iob_if_write.png "Write Transaction")
