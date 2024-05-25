def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_pulse",
        "name": "iob_pulse",
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
                "name": "pulse",
                "descr": "Output pulse",
                "signals": [
                    {"name": "pulse", "width": "1", "direction": "output"},
                ],
            },
        ],
        "snippets": [
            {
                "outputs": ["pulse"],
                "verilog_code": """
   reg pulse;
   assign pulse_o = pulse;

   initial begin
      pulse=0;
      #PRE pulse=1;
      #DURATION pulse=0;
      #POST;
   end
                """,
            }
        ],
    }

    return attributes_dict
