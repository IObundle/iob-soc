def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_demux",
        "name": "iob_demux",
        "version": "0.1",
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "21",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "N",
                "type": "P",
                "val": "21",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "sel",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "sel",
                        "width": "($clog2(N)+($clog2(N)==0))",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "data_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "data",
                        "width": "N*DATA_W",
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
                        "width": "N*DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "snippets": [
            {
                "outputs": ["data_o"],
                "verilog_code": """
    
     // //Select the data to output
   genvar i;
   generate
      for (i = 0; i < N; i = i + 1) begin : gen_demux
         assign data_o[i*DATA_W+:DATA_W] = (sel_i==i)? data_i : {DATA_W{1'b0}};
      end
   endgenerate
             """,
            },
        ],
    }

    return attributes_dict
