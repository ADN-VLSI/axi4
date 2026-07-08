export SHELL=/bin/bash

export AXI4=$(CURDIR)

TOP := hello

GUI := 0

ifeq ($(GUI), 0)
	XSIM_ARGS += -runall
else
	XSIM_ARGS += -gui
endif

BUILD_DIR := $(AXI4)/build
LOG_DIR := $(AXI4)/log
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

.PHONY: FILELIST
FILELIST: $(BUILD_DIR)
	@echo -e "\033[1;33m#\033[0m Generating Filelist"
	@echo "-i $(AXI4)/include" > $(BUILD_DIR)/flist.f
	@echo "$(AXI4)/package/axi4_pkg.sv" >> $(BUILD_DIR)/flist.f
	@find $(AXI4)/source -maxdepth 1 -name "*.sv" >> $(BUILD_DIR)/flist.f
	@find $(AXI4)/testbench -maxdepth 1 -name "*.sv" >> $(BUILD_DIR)/flist.f

.PHONY: all
all: $(BUILD_DIR) $(LOG_DIR) FILELIST
	@echo -e "\033[1;33m#\033[0m Compiling AXI4 testbench"
	@cd $(BUILD_DIR) && $(XVLOG) -sv -f $(BUILD_DIR)/flist.f -log $(LOG_DIR)/xvlog_$(shell date +%Y%m%d_%H%M%S).log $(O_EW)
	@echo -e "\033[1;33m#\033[0m Elaborating AXI4 testbench"
	@cd $(BUILD_DIR) && $(XELAB) $(TOP) -s snap_$(TOP) -debug all -log $(LOG_DIR)/xelab_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(O_EW)
	@echo -e "\033[1;33m#\033[0m Simulating AXI4 testbench"
	@cd $(BUILD_DIR) && $(XSIM) snap_$(TOP) $(XSIM_ARGS) -log $(LOG_DIR)/xsim_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log $(H_EW)

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
