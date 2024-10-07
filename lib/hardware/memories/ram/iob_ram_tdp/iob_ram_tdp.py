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
                "name": "ADDR_W",
                "type": "P",
                "val": "6",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "8",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "MEM_NO_READ_ON_WRITE",
                "type": "P",
                "val": "1",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "MEM_INIT_FILE_INT",
                "type": "F",
                "val": "HEXFILE",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
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
    reg [DATA_W-1:0] dA_o_reg;
    reg [DATA_W-1:0] dB_o_reg;
    assign dA_o=dA_o_reg;
    assign dB_o=dB_o_reg;
            // Declare the RAM
   reg [DATA_W-1:0] ram[2**ADDR_W-1:0];

   // Initialize the RAM
   initial if (MEM_INIT_FILE_INT != "none") $readmemh(MEM_INIT_FILE_INT, ram, 0, 2 ** ADDR_W - 1);

   generate
      if (MEM_NO_READ_ON_WRITE) begin : with_MEM_NO_READ_ON_WRITE
         always @(posedge clk_i) begin  // Port A
            if (enA_i)
               if (weA_i) ram[addrA_i] <= dA_i;
               else dA_o_reg <= ram[addrA_i];
         end
         always @(posedge clk_i) begin  // Port B
            if (enB_i)
               if (weB_i) ram[addrB_i] <= dB_i;
               else dB_o_reg <= ram[addrB_i];
         end
      end else begin : not_MEM_NO_READ_ON_WRITE
         always @(posedge clk_i) begin  // Port A
            if (enA_i) if (weA_i) ram[addrA_i] <= dA_i;
            dA_o_reg <= ram[addrA_i];
         end
         always @(posedge clk_i) begin  // Port B
            if (enB_i) if (weB_i) ram[addrB_i] <= dB_i;
            dB_o_reg <= ram[addrB_i];
         end
      end
   endgenerate    
            """,
            },
        ],
    }

    return attributes_dict
