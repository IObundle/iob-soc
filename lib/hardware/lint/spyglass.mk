# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

LINT_SERVER=$(SYNOPSYS_SERVER)
LINT_USER=$(SYNOPSYS_USER)
LINT_SSH_FLAGS=$(SYNOPSYS_SSH_FLAGS)
LINT_SCP_FLAGS=$(SYNOPSYS_SCP_FLAGS)
LINT_SYNC_FLAGS=$(SYNOPSYS_SYNC_FLAGS)


run-lint:
ifeq ($(LINT_SERVER),)
	NAME=$(NAME) CSR_IF=$(CSR_IF) spyglass -licqueue -shell -tcl spyglass.tcl 
else
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --exclude .git $(LINT_SYNC_FLAGS) ../.. $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)
	ssh -t $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) 'make -C $(REMOTE_LINT_DIR) run LINTER=$(LINTER)'
	mkdir -p spyglass_reports
	scp $(LINT_SCP_FLAGS) $(LINT_USER)@$(LINT_SERVER):$(REMOTE_LINT_DIR)/spyglass/consolidated_reports/$(LINT_TOP)_lint_lint_rtl/*.rpt spyglass_reports/.
endif

clean-lint:
	rm -rf $(NAME)_files.list
	rm -rf spyglass_reports spyglass.prj
