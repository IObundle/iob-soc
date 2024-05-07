

# Read the Verilog files
read_verilog -v $VSRC
# Synthesize the design
synth

# Optimize the design
opt

# Generate the RTL netlist
write_verilog -noattr -noexpr synthesized_netlist.v