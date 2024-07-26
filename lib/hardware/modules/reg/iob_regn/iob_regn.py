edge = 1


def setup(py_params_dict):
    global edge
    if "RST_POL" in py_params_dict:
        edge = py_params_dict["RST_POL"]
    attributes_dict = {
        "original_name": "iob_regn",
        "name": "iob_regn",
        "version": "0.1",
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "1",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "RST_VAL",
                "type": "P",
                "val": "{DATA_W{1'b0}}",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "data_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "data",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "data_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "data",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": f"""
    reg [DATA_W-1:0] data_o_reg;
    assign data_o = data_o_reg;
    always @(posedge clk_i, {"posedge" if edge else "negedge"} arst_i) begin
      if (arst_i) begin
        data_o_reg <= RST_VAL;
      end else if (cke_i) begin
        data_o_reg <= data_i;
      end
    end
         """,
            },
        ],
    }

    return attributes_dict
