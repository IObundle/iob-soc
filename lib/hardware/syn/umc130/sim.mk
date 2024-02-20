LIBFILE=/opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/verilog/fsc0l_d_generic_core_30.lib

ifneq ($(wildcard $(LIBFILE)),)
VSRC+= $(LIBFILE)
endif
