
#Tester peripherals' base addresses
tester_periphs.h: tester_periphs_tmp.h
	@is_diff=`diff -q -N $@ $<`; if [ "$$is_diff" ]; then cp $< $@; fi
	@rm tester_periphs_tmp.h

tester_periphs_tmp.h:
	$(SW_DIR)/tester/tester_periphs_tmp.py $P $(ROOT_DIR)

