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
                "val": "10",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "COL_W",
                "type": "F",
                "val": "DATA_W / 4",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "NUM_COL",
                "type": "F",
                "val": "DATA_W / COL_W",
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "mem_init_file_int",
                "type": "F",
                "val": '{HEXFILE, ".hex"}',
                "min": "NA",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "Clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "port_a",
                "descr": "Memory interface A",
                "signals": [
                    {"name": "enA", "width": 1, "direction": "input"},
                    {"name": "weA", "width": "DATA_W/8", "direction": "input"},
                    {"name": "addrA", "width": "ADDR_W", "direction": "input"},
                    {"name": "dA", "width": "DATA_W", "direction": "input"},
                    {"name": "dA", "width": "DATA_W", "direction": "output"},
                ],
            },
            {
                "name": "port_b",
                "descr": "Memory interface B",
                "signals": [
                    {"name": "enB", "width": 1, "direction": "input"},
                    {"name": "weB", "width": "DATA_W/8", "direction": "input"},
                    {"name": "addrB", "width": "ADDR_W", "direction": "input"},
                    {"name": "dB", "width": "DATA_W", "direction": "input"},
                    {"name": "dB", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
             // Core Memory
   reg [DATA_W-1:0] ram_block[(2**ADDR_W)-1:0];

   // Initialize the RAM
   initial
      if (MEM_INIT_FILE_INT != "none.hex")
         $readmemh(MEM_INIT_FILE_INT, ram_block, 0, 2 ** ADDR_W - 1);

   // Port-A Operation
   reg     [DATA_W-1:0] dA_o_int;
   integer              i;
   always @(posedge clk_i) begin
      if (enA_i) begin
         for (i = 0; i < NUM_COL; i = i + 1) begin
            if (weA_i[i]) begin
               ram_block[addrA_i][i*COL_W+:COL_W] <= dA_i[i*COL_W+:COL_W];
            end
         end
         dA_o_int <= ram_block[addrA_i];  // Send Feedback
      end
   end

   assign dA_o = dA_o_int;

   // Port-B Operation
   reg     [DATA_W-1:0] dB_o_int;
   integer              j;
   always @(posedge clk_i) begin
      if (enB_i) begin
         for (j = 0; j < NUM_COL; j = j + 1) begin
            if (weB_i[j]) begin
               ram_block[addrB_i][j*COL_W+:COL_W] <= dB_i[j*COL_W+:COL_W];
            end
         end
         dB_o_int <= ram_block[addrB_i];  // Send Feedback
      end
   end

   assign dB_o = dB_o_int;
            """,
            },
        ],
    }

    return attributes_dict
