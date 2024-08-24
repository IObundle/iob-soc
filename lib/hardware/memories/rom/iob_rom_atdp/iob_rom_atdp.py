def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_rom_atdp",
        "name": "iob_rom_atdp",
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
                "val": "32",
                "min": "1",
                "max": "NA",
                "descr": "DATA width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "11",
                "min": "1",
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
                "name": "clk_a_i",
                "descr": "Input port",
                "signals": [
                    {"name": "clk_a", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "addr_a_i",
                "descr": "Input port",
                "signals": [
                    {"name": "addr_a", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "r_en_a_i",
                "descr": "Input port",
                "signals": [
                    {"name": "r_en_a", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "clk_b_i",
                "descr": "Input port",
                "signals": [
                    {"name": "clk_b", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "addr_b_i",
                "descr": "Input port",
                "signals": [
                    {"name": "addr_b", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "r_en_b_i",
                "descr": "Input port",
                "signals": [
                    {"name": "r_en_b", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "r_data_a_o",
                "descr": "Output port",
                "signals": [
                    {"name": "r_data_a", "width": "DATA_W", "direction": "output"},
                ],
            },
            {
                "name": "r_data_b_o",
                "descr": "Output port",
                "signals": [
                    {"name": "r_data_b", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            // Declare the ROM
   reg [DATA_W-1:0] rom[2**ADDR_W-1:0];

   // Initialize the ROM
   initial if ( MEM_INIT_FILE_INT != "none") $readmemh( MEM_INIT_FILE_INT, rom, 0, 2 ** ADDR_W - 1);

   always @(posedge clk_a_i)  // Port A
      if (r_en_a_i)
         r_data_a_o <= rom[addr_a_i];

   always @(posedge clk_b_i)  // Port B
      if (r_en_b_i)
         r_data_b_o <= rom[addr_b_i];
            """,
            },
        ],
    }

    return attributes_dict
