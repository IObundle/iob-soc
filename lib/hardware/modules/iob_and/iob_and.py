from iob_module import iob_module


class iob_and(iob_module):
    def __init__(self, *args, **kwargs):
        self.version = "V0.10"

        self.create_conf(
            name="W",
            type="P",
            val="21",
            min="1",
            max="32",
            descr="IO width",
        ),
        self.create_conf(
            name="N",
            type="P",
            val="21",
            min="1",
            max="32",
            descr="Number of inputs",
        ),

        self.create_port(
            name="inputs",
            descr="Inputs port",
            elements=[
                {"name": "in", "width": "N*W", "direction": "input"},
            ]
        )
        self.create_port(
            name="output",
            descr="Output port",
            elements=[
                {"name": "out", "width": "W", "direction": "output"},
            ]
        )

        self.create_wire(
            name="and_vector",
            descr="Logic vector",
            elements=[
                {"name": "and_vec", "width": "N*W"},
            ],
        )

        self.insert_verilog(
            """
   assign and_vec[0 +: W] = in_i[0 +: W];

   genvar i;
   generate
      for (i = 1; i < N; i = i + 1) begin : gen_mux
         assign and_vec[i*W +: W] = in_i[i*W +: W] & and_vec[(i-1)*W +: W];
      end
   endgenerate

   assign out_o = and_vec[(N-1)*W +: W];
            """
        )

        super().__init__(*args, **kwargs)
