def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_tdp",
        "name": "iob_ram_tdp",
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
                "name": "MEM_INIT_FILE_INT",
                "type": "P",
                "val": "HEXFILE",
                "min": "0",
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
                "descr": "Input",
                "signals": [
                    {"name": "dA", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "addrA_i",
                "descr": "Input",
                "signals": [
                    {"name": "addrA", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "enA_i",
                "descr": "Input",
                "signals": [
                    {"name": "enA", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "weA_i",
                "descr": "Input",
                "signals": [
                    {"name": "weA", "width": 1, "direction": "input"},
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
                "descr": "Input",
                "signals": [
                    {"name": "dB", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "addrB_i",
                "descr": "Input",
                "signals": [
                    {"name": "addrB", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "enB_i",
                "descr": "Input",
                "signals": [
                    {"name": "enB", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "weB_i",
                "descr": "Input",
                "signals": [
                    {"name": "weB", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "dA_o",
                "descr": "Output",
                "signals": [
                    {"name": "dA", "width": "DATA_W", "direction": "output"},
                ],
            },
            {
                "name": "dB_o",
                "descr": "Output",
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

   // Initialize the RAM
   initial if (MEM_INIT_FILE_INT != "none") $readmemh(MEM_INIT_FILE_INT, ram, 0, 2 ** ADDR_W - 1);

   //read port
   always @(posedge clkA_i) begin  // Port A
      if (enA_i)
`ifdef IOB_MEM_NO_READ_ON_WRITE
         if (weA_i) ram[addrA_i] <= dA_i;
         else dA_o <= ram[addrA_i];
`else
         if (weA_i) ram[addrA_i] <= dA_i;
         dA_o <= ram[addrA_i];
`endif
   end

   //write port
   always @(posedge clkB_i) begin  // Port B
      if (enB_i)
`ifdef IOB_MEM_NO_READ_ON_WRITE
         if (weB_i) ram[addrB_i] <= dB_i;
         else dB_o <= ram[addrB_i];
`else
         if (weB_i) ram[addrB_i] <= dB_i;
         dB_o <= ram[addrB_i];
`endif
   end
  
            """,
            },
        ],
    }

    return attributes_dict
