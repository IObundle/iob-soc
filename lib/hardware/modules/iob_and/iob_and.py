from iob_module import iob_module


class iob_and(iob_module):
    def __init__(self, *args, n_inputs=2, **kwargs):
        self.version = "V0.10"

        self.create_conf(
            name="W",
            type="P",
            val="21",
            min="1",
            max="32",
            descr="IO width",
        ),

        # Create a port_name "a_b_c_d_e_..." based on n_inputs
        # and the corresponding port signals [a, b, c, d, e, ...]
        # and the Verilog snippet to inject that concatenates inputs
        port_name = ""
        port_signals = []
        verilog_inject = "assign in_vec = {"
        for i in range(n_inputs):
            port_name += f"{chr(97+i)}_"
            port_signals.append(
                {"name": chr(97 + i), "width": "W", "direction": "input"},
            )
            verilog_inject += f"{chr(97+i)}_i, "
        verilog_inject += "};\n"

        self.create_port(
            name=port_name,
            descr="Inputs port",
            signals=port_signals,
        )
        self.create_port(
            name="y",
            descr="Output port",
            signals=[
                {"name": "y", "width": "W", "direction": "output"},
            ],
        )

        self.create_wire(
            name="logic_vectors",
            descr="Logic vectors",
            signals=[
                {"name": "in_vec", "width": f"{n_inputs}*W"},
                {"name": "and_vec", "width": f"{n_inputs}*W"},
            ],
        )

        self.insert_verilog(
            verilog_inject
            + f"""
   assign and_vec[0 +: W] = in_vec[0 +: W];

   genvar i;
   generate
      for (i = 1; i < {n_inputs}; i = i + 1) begin : gen_mux
         assign and_vec[i*W +: W] = in_vec[i*W +: W] & and_vec[(i-1)*W +: W];
      end
   endgenerate

   assign y_o = and_vec[({n_inputs}-1)*W +: W];
            """
        )

        super().__init__(*args, **kwargs)
