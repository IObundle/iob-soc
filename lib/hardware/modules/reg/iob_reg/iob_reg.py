def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_reg",
        "name": "iob_reg",
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
            {
                "name": "RST_POL",
                "type": "F",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Reset polarity.",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "descr": "Clock, enable, and reset",
                "signals": [],
            },
            {
                "name": "io",
                "type": "master",
                "descr": "Input and output",
                "signals": [
                    {
                        "name": "data",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "Input",
                    },
                    {
                        "name": "data",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "Output",
                    },
                ],
            },
        ],
        "snippets": [
            {
                "outputs": ["data_o_reg", "data_o"],
                "verilog_code": """
    reg [DATA_W-1:0] data_o_reg;
    assign data_o = data_o_reg;
  generate
    if (RST_POL == 1) begin : g_rst_pol_1
      always @(posedge clk_i, posedge arst_i) begin
        if (arst_i) begin
          data_o_reg <= RST_VAL;
        end else if (cke_i) begin
          data_o_reg <= data_i;
        end
      end
    end else begin : g_rst_pol_0
      always @(posedge clk_i, negedge arst_i) begin
        if (~arst_i) begin
          data_o_reg <= RST_VAL;
        end else if (cke_i) begin
          data_o_reg <= data_i;
        end
      end
    end
  endgenerate
         """,
            },
        ],
    }

    return attributes_dict
