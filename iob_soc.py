def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_soc",
        "name": "iob_soc",
        "parent": {"core_name": "iob_system", **py_params_dict},
        "version": "0.1",
        "confs": [],
        "ports": [],
    }

    return attributes_dict
