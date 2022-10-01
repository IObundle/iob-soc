

The simulation example design is available for both Verilog and VHDL.



To generate the Verilog example design, open the Quartus project "generate_sim_example_design.qpf" and
select Tools -> Tcl Scripts... -> generate_sim_verilog_example_design.tcl and click "Run".
Alternatively, you can run "quartus_sh -t generate_sim_verilog_example_design.tcl"
at a Windows or Linux command prompt.

The generated files will be found in the subdirectory "verilog".



To generate the VHDL example design, open the Quartus project "generate_sim_example_design.qpf" and
select Tools -> Tcl Scripts... -> generate_sim_vhdl_example_design.tcl and click "Run".
Alternatively, you can run "quartus_sh -t generate_sim_vhdl_example_design.tcl"
at a Windows or Linux command prompt.

The generated files will be found in the subdirectory "vhdl".



To simulate the example design using Modelsim AE/SE:

1) Move into the directory ./verilog/mentor or ./vhdl/mentor
2) Start Modelsim and run the "run.do" script: in Modelsim, enter "do run.do".

