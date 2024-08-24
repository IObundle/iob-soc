def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_sp_se",
        "name": "iob_ram_sp_se",
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
                "type": "P",
                "val": "8",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "NUM_COL",
                "type": "P",
                "val": "DATA_W / COL_W",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk",
                "descr": "Clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "en_i",
                "descr": "Input",
                "signals": [
                    {"name": "en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "we_i",
                "descr": "Input",
                "signals": [
                    {"name": "we", "width": "DATA_W/COL_W", "direction": "input"},
                ],
            },
            {
                "name": "addr_i",
                "descr": "Input",
                "signals": [
                    {"name": "addr", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "d_i",
                "descr": "Input",
                "signals": [
                    {"name": "d", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "d_o",
                "descr": "Output",
                "signals": [
                    {"name": "d", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "wires": [
            {
                "name": "d_o_int",
                "descr": "d_o_int wire",
                "signals": [
                    {"name": "d_o_int", "width": "DATA_W"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_ram_sp",
                "instantiate": False,
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            // Operation
`ifdef IOB_MEM_NO_READ_ON_WRITE
   localparam file_suffix = {"7", "6", "5", "4", "3", "2", "1", "0"};

   genvar i;
   generate
      for (i = 0; i < NUM_COL; i = i + 1) begin : ram_col
         localparam mem_init_file_int = (HEXFILE != "none") ?
             {HEXFILE, "_", file_suffix[COL_W*(i+1)-1-:COL_W], ".hex"} : "none";

         iob_ram_sp #(
            .HEXFILE(mem_init_file_int),
            .ADDR_W (ADDR_W),
            .DATA_W (COL_W)
         ) ram (
            .clk_i(clk_i),

            .en_i  (en_i),
            .addr_i(addr_i),
            .d_i   (d_i[i*COL_W+:COL_W]),
            .we_i  (we_i[i]),
            .d_o   (d_o[i*COL_W+:COL_W])
         );
      end
   endgenerate
`else  // !IOB_MEM_NO_READ_ON_WRITE
   // this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = {HEXFILE, ".hex"};

   // Core Memory
   reg [DATA_W-1:0] ram_block[(2**ADDR_W)-1:0];

   // Initialize the RAM
   initial
      if (mem_init_file_int != "none.hex")
         $readmemh(mem_init_file_int, ram_block, 0, 2 ** ADDR_W - 1);
   integer              i;
   always @(posedge clk_i) begin
      if (en_i) begin
         for (i = 0; i < NUM_COL; i = i + 1) begin
            if (we_i[i]) begin
               ram_block[addr_i][i*COL_W+:COL_W] <= d_i[i*COL_W+:COL_W];
            end
         end
         d_o_int <= ram_block[addr_i];  // Send Feedback
      end
   end

   assign d_o = d_o_int;
`endif
  
            """,
            },
        ],
    }

    return attributes_dict
