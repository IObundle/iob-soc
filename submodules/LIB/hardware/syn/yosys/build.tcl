 

# Read the Verilog files

yosys read_verilog -I./src -I../src ../src/*.v
# Synthesize the design
yosys synth -top iob_soc

# Optimize the design
yosys opt

# Generate the RTL netlist
yosys write_verilog -noattr -noexpr iob_soc_synthesized.v
