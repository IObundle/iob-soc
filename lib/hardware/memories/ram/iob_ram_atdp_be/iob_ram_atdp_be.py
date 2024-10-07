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
                "val": "10",
                "min": "NA",
                "max": "NA",
                "descr": "DATA width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "COL_W",
                "type": "F",
                "val": "8",
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
                    {"name": "weA", "width": "DATA_W/8", "direction": "input"},
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
                "name": "dA_i",
                "descr": "Input port",
                "signals": [
                    {"name": "dA", "width": "DATA_W", "direction": "input"},
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
                    {"name": "weB", "width": "DATA_W/8", "direction": "input"},
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
                "name": "dB_i",
                "descr": "Input port",
                "signals": [
                    {"name": "dB", "width": "DATA_W", "direction": "input"},
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
        "blocks": [
            {
                "core_name": "iob_ram_atdp",
                "instantiate": False,
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            `ifdef IOB_MEM_NO_READ_ON_WRITE
   localparam file_suffix = {"7", "6", "5", "4", "3", "2", "1", "0"};

   genvar i;
   generate
      for (i = 0; i < NUM_COL; i = i + 1) begin : ram_col
         localparam mem_init_file_int = (HEXFILE != "none") ?
             {HEXFILE, "_", file_suffix[8*(i+1)-1-:8], ".hex"} : "none";

         iob_ram_atdp #(
            .HEXFILE(mem_init_file_int),
            .ADDR_W (ADDR_W),
            .DATA_W (COL_W)
         ) ram (
            .clkA_i (clkA_i),
            .enA_i  (enA_i),
            .addrA_i(addrA_i),
            .dA_i   (dA_i[i*COL_W+:COL_W]),
            .weA_i  (weA_i[i]),
            .dA_o   (dA_o[i*COL_W+:COL_W]),

            .clkB_i (clkB_i),
            .enB_i  (enB_i),
            .addrB_i(addrB_i),
            .dB_i   (dB_i[i*COL_W+:COL_W]),
            .weB_i  (weB_i[i]),
            .dB_o   (dB_o[i*COL_W+:COL_W])
         );
      end
   endgenerate
`else  // !IOB_MEM_NO_READ_ON_WRITE
   // this allow ISE 14.7 to work; do not remove
   localparam mem_init_file_int = {HEXFILE, ".hex"};

   // Core Memory
   reg [DATA_W-1:0] ram_block[(2**ADDR_W)-1:0];

   // Initialize the RAM
   initial
      if (mem_init_file_int != "none.hex")
         $readmemh(mem_init_file_int, ram_block, 0, 2 ** ADDR_W - 1);

   // Port-A Operation
   reg     [DATA_W-1:0] dA_o_int;
   integer              i;
   always @(posedge clkA_i) begin
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
   always @(posedge clkB_i) begin
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
`endif
            """,
            },
        ],
    }

    return attributes_dict
