def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_reset",
        "name": "iob_reset",
        "version": "0.1",
        "confs": [
            {
                "name": "PRE",
                "type": "P",
                "val": "1",
                "min": "",
                "max": "",
                "descr": "Clock period",
            },
            {
                "name": "DURATION",
                "type": "P",
                "val": "0",
                "min": "",
                "max": "",
                "descr": "",
            },
            {
                "name": "POST",
                "type": "P",
                "val": "0",
                "min": "",
                "max": "",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk",
                "descr": "Input clock",
                "signals": [
                    {"name": "clk", "width": "1", "direction": "input"},
                ],
            },
            {
                "name": "reset",
                "descr": "Output reset",
                "signals": [
                    {"name": "pulse", "width": "1", "direction": "output"},
                ],
            },
        ],
        "snippets": [
            {
                "outputs": ["reset"],
                "verilog_code": """
   reg reset;
   assign reset_o = reset;

   initial begin
      reset = ~`IOB_REG_RST_POL;
      #PRE reset = `IOB_REG_RST_POL;
      #DURATION reset = ~`IOB_REG_RST_POL;
      #POST;
      @(posedge clk_i) #1;
   end
                """,
            }
        ],
    }

    return attributes_dict
