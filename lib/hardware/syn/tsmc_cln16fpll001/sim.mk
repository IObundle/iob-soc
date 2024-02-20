LIBFILE=$(LIBDIR)/sc9mcpp140_base_svt_c35/r0p0/lib/sc9mcpp140_cln28hpc_base_svt_c35_ss_cworst_max_0p81v_m40c.lib

ifneq ($(wildcard $(LIBFILE)),)
VSRC+= $(LIBFILE)
endif
