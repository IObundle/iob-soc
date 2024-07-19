def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_int_sqrt",
        "name": "iob_int_sqrt",
        "version": "0.1",
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "FRACTIONAL_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "REAL_W",
                "type": "P",
                "val": "DATA_W - FRACTIONAL_W",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "SIZE_W",
                "type": "P",
                "val": "(REAL_W / 2) + FRACTIONAL_W",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "END_COUNT",
                "type": "F",
                "val": "(DATA_W + FRACTIONAL_W) >> 1",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "COUNT_W",
                "type": "F",
                "val": "$clog2(END_COUNT)",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "clk",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "rst",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "rst",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "start",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "start",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "op",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "op",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "done",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "done",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "res",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "res",
                        "width": "SIZE_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "right",
                "descr": "right wire",
                "signals": [
                    {"name": "right", "width": "SIZE_W+2"},
                ],
            },
            {
                "name": "left",
                "descr": "left wire",
                "signals": [
                    {"name": "left", "width": "SIZE_W+2"},
                ],
            },
            {
                "name": "a_in",
                "descr": "",
                "signals": [
                    {"name": "a_in", "width": "DATA_W"},
                ],
            },
            {
                "name": "tmp",
                "descr": "",
                "signals": [
                    {"name": "tmp", "width": "SIZE_W"},
                ],
            },
        ],
        "snippets": [
            {
                "outputs": ["pc", "a", "q", "r"],
                "verilog_code": """
   assign right = {q, r[SIZE_W+1], 1'b1};
   assign left = {r[SIZE_W-1:0], a[DATA_W-1 -: 2]};
   assign a_in = {a[DATA_W-3:0], 2'b00};
   assign tmp = r[SIZE_W+1]? left + right:left - right;

   reg [COUNT_W:0]           counter;
   reg                       pc;
   reg [SIZE_W-1:0]          q;
   reg [SIZE_W+1:0]          r;
   reg [DATA_W-1:0]          a;
   
      always @(posedge clk_i) begin
      if (rst_i) begin
         pc <= 1'd0;
      end else begin
         pc <= pc + 1'b1;

         case (pc)
           0: begin
              if (start_i) begin
                 a <= op_i;
                 q <= 0;
                 r <= 0;

                 counter <= 0;
              end else begin
                 pc <= pc;
              end
           end
           1: begin
              r <= tmp;
              q <= {q[SIZE_W-2:0], ~tmp[SIZE_W+1]};

              a <= a_in;

              if (counter != END_COUNT[COUNT_W:0] - 1) begin
                 counter <= counter + 1'b1;
                 pc <= pc;
              end else begin
                 pc <= 1'b0;
              end
           end
           default:;
         endcase
      end
   end

   assign res_o = q;
   assign done_o = ~pc;
            """,
            },
        ],
    }

    return attributes_dict
