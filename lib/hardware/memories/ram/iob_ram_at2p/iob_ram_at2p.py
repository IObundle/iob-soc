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
                "name": "w_clk_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "w_en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "w_addr_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_addr", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "w_data_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_data", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "r_clk_i",
                "descr": "Input port",
                "signals": [
                    {"name": "r_clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "r_en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "r_en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "r_addr_i",
                "descr": "Input port",
                "signals": [
                    {"name": "r_addr", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "r_data_o",
                "descr": "Output port",
                "signals": [
                    {"name": "r_data", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            // Declare the RAM
   reg [DATA_W-1:0] ram[(2**ADDR_W)-1:0];
   reg [DATA_W-1:0] r_data_o_reg;
   assign r_data_o=r_data_o_reg;

   // Initialize the RAM
   initial begin
       if (MEM_INIT_FILE_INT != "none") begin
           $readmemh(MEM_INIT_FILE_INT, ram, 0, (2 ** ADDR_W) - 1);
       end
   end

   //write
   always @(posedge w_clk_i) begin
       if (w_en_i) begin
           ram[w_addr_i] <= w_data_i;
       end
   end

   //read
   always @(posedge r_clk_i) begin
       if (r_en_i) begin
           r_data_o_reg <= ram[r_addr_i];
       end
   end
            """,
            },
        ],
    }

    return attributes_dict
