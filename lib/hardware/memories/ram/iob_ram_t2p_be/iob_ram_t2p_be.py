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
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
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
                "name": "clk_i",
                "descr": "Clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "w_en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_en", "width": "DATA_W/8", "direction": "input"},
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
        "blocks": [
            {
                "core_name": "iob_ram_t2p",
                "instantiate": False,
            },
        ],
        "snippets": [
            {
                "verilog_code": """
                reg [DATA_W-1:0] r_data_o_reg;
                assign r_data_o=r_data_o_reg;
            `ifdef IOB_MEM_NO_READ_ON_WRITE
   localparam file_suffix = {"7", "6", "5", "4", "3", "2", "1", "0"};

   genvar i;
   generate
      for (i = 0; i < NUM_COL; i = i + 1) begin : ram_col
         localparam mem_init_file_int = (HEXFILE != "none") ?
             {HEXFILE, "_", file_suffix[8*(i+1)-1-:8], ".hex"} : "none";

         iob_ram_t2p #(
            .HEXFILE(mem_init_file_int),
            .ADDR_W (ADDR_W),
            .DATA_W (COL_W)
         ) ram (
            .clk_i(clk_i),

            .w_en_i  (w_en_i[i]),
            .w_addr_i(w_addr_i),
            .w_data_i(w_data_i[i*COL_W+:COL_W]),
            .r_en_i  (r_en_i),
            .r_addr_i(r_addr_i),
            .r_data_o(r_data_o_reg[i*COL_W+:COL_W])
         );
      end
   endgenerate
`else  // !IOB_MEM_NO_READ_ON_WRITE
   //this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;

   // Declare the RAM
   reg [DATA_W-1:0] mem[(2**ADDR_W)-1:0];

   // Initialize the RAM
   initial if (mem_init_file_int != "none") $readmemh(mem_init_file_int, mem, 0, (2 ** ADDR_W) - 1);

   //read port
   always @(posedge clk_i) if (r_en_i) r_data_o_reg <= mem[r_addr_i];

   //write port
   integer i;
   always @(posedge clk_i) begin
      for (i = 0; i < NUM_COL; i = i + 1) begin
         if (w_en_i[i]) begin
            mem[w_addr_i][i*COL_W+:COL_W] <= w_data_i[i*COL_W+:COL_W];
         end
      end
   end
`endif
            """,
            },
        ],
    }

    return attributes_dict
