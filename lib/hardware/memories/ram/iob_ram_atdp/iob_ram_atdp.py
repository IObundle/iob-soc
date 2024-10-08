# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "HEXFILE",
                "type": "P",
                "val": '"none"',
                "min": "NA",
                "max": "NA",
                "descr": "Name of file to load into RAM",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "0",
                "min": "NA",
                "max": "NA",
                "descr": "DATA width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "0",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "MEM_INIT_FILE_INT",
                "type": "F",
                "val": "HEXFILE",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clkA_i",
                "descr": "Input port",
                "signals": [
                    {"name": "clkA", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "dA_i",
                "descr": "Input port",
                "signals": [
                    {"name": "dA", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "addrA_i",
                "descr": "Input port",
                "signals": [
                    {"name": "addrA", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "enA_i",
                "descr": "Input port",
                "signals": [
                    {"name": "enA", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "weA_i",
                "descr": "Input port",
                "signals": [
                    {"name": "weA", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "dA_o",
                "descr": "Output port",
                "signals": [
                    {"name": "dA", "width": "DATA_W", "direction": "output"},
                ],
            },
            {
                "name": "clkB_i",
                "descr": "Input port",
                "signals": [
                    {"name": "clkB", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "dB_i",
                "descr": "Input port",
                "signals": [
                    {"name": "dB", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "addrB_i",
                "descr": "Input port",
                "signals": [
                    {"name": "addrB", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "enB_i",
                "descr": "Input port",
                "signals": [
                    {"name": "enB", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "weB_i",
                "descr": "Input port",
                "signals": [
                    {"name": "weB", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "dB_o",
                "descr": "Output port",
                "signals": [
                    {"name": "dB", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            // Declare the RAM
   reg [DATA_W-1:0] ram[2**ADDR_W-1:0];
   reg [DATA_W-1:0] dA_o_reg;
   reg [DATA_W-1:0] dB_o_reg;
    assign dA_o=dA_o_reg;
    assign dB_o=dB_o_reg;

   // Initialize the RAM
   initial if (MEM_INIT_FILE_INT != "none") $readmemh(MEM_INIT_FILE_INT, ram, 0, 2 ** ADDR_W - 1);

   //read port
   always @(posedge clkA_i) begin  // Port A
      if (enA_i)
`ifdef IOB_MEM_NO_READ_ON_WRITE
         if (weA_i) ram[addrA_i] <= dA_i;
         else dA_o_reg <= ram[addrA_i];
`else
         if (weA_i) ram[addrA_i] <= dA_i;
         dA_o_reg <= ram[addrA_i];
`endif
   end

   //write port
   always @(posedge clkB_i) begin  // Port B
      if (enB_i)
`ifdef IOB_MEM_NO_READ_ON_WRITE
         if (weB_i) ram[addrB_i] <= dB_i;
         else dB_o_reg <= ram[addrB_i];
`else
         if (weB_i) ram[addrB_i] <= dB_i;
         dB_o_reg <= ram[addrB_i];
`endif
   end
            """,
            },
        ],
    }

    return attributes_dict
