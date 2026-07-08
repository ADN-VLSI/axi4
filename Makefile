export SHELL=/bin/bash

export AXI4=$(CURDIR)

TOP := hello

BUILD_DIR    := $(AXI4)/build
LOG_DIR      := $(AXI4)/logs
COVERAGE_DIR := $(AXI4)/coverage

XVLOG ?= xvlog
XELAB ?= xelab
XSIM  ?= xsim

O_EW :=  | (grep -iE "Error|Warning" --color=auto || true)
H_EW :=  | (grep -iE "Error|Warning|" --color=auto)

$(BUILD_DIR) $(LOG_DIR) $(COVERAGE_DIR):
	@echo -e "\033[1;33m#\033[0m Creating directory $@"
	@mkdir -p $@
	@echo "*" > $@/.gitignore

.PHONY: all
all: $(AXI4)/axi4.f $(AXI4)/test.f $(BUILD_DIR) $(LOG_DIR)
	@echo -e "\033[1;33m#\033[0m Compiling AXI4 testbench"
	@cd $(BUILD_DIR) && $(XVLOG) -sv -f $(AXI4)/axi4.f -f $(AXI4)/test.f -log $(LOG_DIR)/xvlog_$(shell date +%Y%m%d_%H%M%S).log $(O_EW)
	@echo -e "\033[1;33m#\033[0m Elaborating AXI4 testbench"
	@cd $(BUILD_DIR) && $(XELAB) $(TOP) -s snap_$(TOP) -debug all -log $(LOG_DIR)/xelab_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(O_EW)
	@echo -e "\033[1;33m#\033[0m Simulating AXI4 testbench"
	@cd $(BUILD_DIR) && $(XSIM) snap_$(TOP) -runall -log $(LOG_DIR)/xsim_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(H_EW)

.PHONY: clean
clean:
	@echo -e "\033[1;33m#\033[0m Cleaning build directory"
	@rm -rf $(BUILD_DIR)

.PHONY: clean_full
clean_full:
	@make -s clean
	@echo -e "\033[1;33m#\033[0m Cleaning log directories"
	@rm -rf $(LOG_DIR)
	@echo -e "\033[1;33m#\033[0m Cleaning coverage directories"
	@rm -rf $(COVERAGE_DIR)
