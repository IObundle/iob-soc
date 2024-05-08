def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_regfile_2p",
        "name": "iob_regfile_2p",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and reset",
                "signals": [],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_ctls",
                "instance_name": "iob_ctls_inst",
            },
        ],
    }

    return attributes_dict
