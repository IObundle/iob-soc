edge = 1


def setup(py_params_dict):
    global edge
    if "RST_POL" in py_params_dict:
        edge = py_params_dict["RST_POL"]
    attributes_dict = {
        "original_name": "iob_rn",
        "name": "iob_rn",
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
                "name": "clk_rst",
                "interface": {
                    "type": "clk_rst",
                    "subtype": "slave",
                },
                "descr": "Clock and reset",
            },
            {
                "name": "iob_rn_data_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "iob_rn_data",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "iob_rn_data_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "iob_rn_data",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": f"""
    reg [DATA_W-1:0] iob_rn_data_o_reg;
    assign iob_rn_data_o = iob_rn_data_o_reg;
    always @(posedge clk_i, {"posedge" if edge else "negedge"} arst_i) begin
            if (arst_i) begin
               iob_rn_data_o_reg <= RST_VAL;
            end else begin
               iob_rn_data_o_reg <= iob_rn_data_i;
            end
         end
         """,
            },
        ],
    }

    return attributes_dict
