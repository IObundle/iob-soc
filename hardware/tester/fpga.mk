#Replace top_system.v with tester_top_system.v
VSRC:=$(filter-out ./verilog/top_system.v, $(VSRC))
VSRC+=./verilog/tester_top_system.v

BUILD_DEPENDENCIES+=tester-sw
