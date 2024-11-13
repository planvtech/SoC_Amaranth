# Variables
PYTHON          	= python3
VERILOG_GEN_SCRIPT 	= python/top_level.py
GEN_VERILOG_FILE   	= SoC/top.sv
TESTNAME		   	= TestUART
VLOG            	=  vlog
VLOG_FLAGS 			+= -svinputport=compat -incr -64 -nologo -quiet -suppress 13262 -suppress 2583 -suppress 3999
VLOG_FLAGS 			+= -suppress 2986 
VLOG_FLAGS 			+= -suppress 2879 
VSIM_FLAGS 			+= +TESTNAME=$(TESTNAME) 
VSIM_FLAGS 			+= -suppress 3999

# Define directories and library
PERIPHERAL			= modules/peripherals
CPU					= modules/core/scr1
AXI					= modules/axi/axi
APB_DIR         	= $(PERIPHERAL)/apb
APB_UART			= $(PERIPHERAL)/apb_uart_sv
APB_SPI_MASTER		= $(PERIPHERAL)/apb_spi_master
AXI_APB				= modules/axi/axi2apb
AXI_SLICE			= modules/axi/axi_slice
COMMON_CELLS 		= $(PERIPHERAL)/common_cells
MISC            	= misc
TB              	= tb
LIBRARY         	= sim/work
TOP_LEVEL       	= tb_top
VOPT            	= vopt

# Dynamically gather include directories
INCDIR          := $(shell find $(APB_DIR) -name "include" -type d)
INCDIR          += $(shell find $(COMMON_CELLS) -name "include" -type d)
INCDIR          += $(shell find $(AXI) -name "include" -type d)
INCDIR			+= $(shell find $(CPU)/src/ -name "includes" -type d)

# Collecting Verilog files
VERILOG_FILES   += $(filter-out %_pkg.sv %_test.sv, $(wildcard $(APB_DIR)/src/*.sv)) \
				   $(filter-out %_sv.sv, $(wildcard $(APB_UART)/*.sv)) \
				   $(wildcard $(APB_SPI_MASTER)/*.sv) \
				   $(wildcard $(AXI_SLICE)/src/*.sv) \
				   $(wildcard $(AXI_APB)/src/*.sv) \
				   $(wildcard $(CPU)/src/core/*.sv) \
				   $(wildcard $(CPU)/src/core/pipeline/*.sv) \
				   $(wildcard $(CPU)/src/core/primitives/*.sv) \
				   $(wildcard $(CPU)/src/top/*.sv) \
				   $(wildcard $(CPU)/top_cache_axi/src_v/*.v) \
				   $(filter-out %_pkg.sv,$(wildcard $(MISC)/*.sv))	\
				   $(filter-out %_pkg.sv,$(wildcard $(MISC)/*.v))	\
				   $(filter-out %_pkg.sv %_test.sv, $(wildcard $(AXI)/src/*.sv)) \
				   $(filter-out %_pkg.sv,$(wildcard $(COMMON_CELLS)/src/*.sv)) \
				   $(filter-out %_pkg.sv,$(wildcard $(COMMON_CELLS)/src/deprecated/fifo*.sv))

TB_FILES        += $(filter-out %_pkg.sv,$(wildcard $(TB)/*.sv)) 

MISC_PKG        += $(wildcard $(COMMON_CELLS)/src/*_pkg.sv) \
                   $(wildcard $(APB_DIR)/src/*_pkg.sv)	\
				   $(wildcard $(AXI)/src/*_pkg.sv)	\

# Combine sources
SOURCES         += $(VERILOG_FILES) $(GEN_VERILOG_FILE) $(TB_FILES)

# Generate include flags
INC_FLAGS       = $(foreach dir, $(INCDIR), +incdir+$(dir))

# Targets
all: simulate

# Generate Verilog code from Python script
generate: $(GEN_VERILOG_FILE)

$(GEN_VERILOG_FILE): $(VERILOG_GEN_SCRIPT)
	@echo "Generating Verilog code from Amaranth..."
	$(PYTHON) $(VERILOG_GEN_SCRIPT)


# Compile Verilog files
compile: generate $(MISC_PKG) $(SOURCES)
	@echo "Compiling Verilog files..."
	@echo "VLOG_FLAGS: $(VLOG_FLAGS) $(INC_FLAGS)"
	vlib $(LIBRARY)
	$(VLOG) $(VLOG_FLAGS) -work $(LIBRARY) $(MISC_PKG) $(INC_FLAGS)
	$(VLOG) $(VLOG_FLAGS) -timescale "1ns / 1ns" -work $(LIBRARY) -pedanticerrors $(SOURCES) $(INC_FLAGS)

# Optimize RTL
rtl: compile 
	@echo "Optimizing RTL..."
	$(VOPT) $(VLOG_FLAGS) -work $(LIBRARY) $(TOP_LEVEL) -o $(TOP_LEVEL)_optimized +acc +check_synthesis	

# Run simulation
simulate: rtl
	@echo "Running simulation..."
	vsim -c $(VSIM_FLAGS) $(LIBRARY).$(TOP_LEVEL)_optimized -do "run -all; quit"

# Clean up generated files and library
clean:
	@echo "Cleaning up..."
	rm -f  *.v *.vh
	rm -rf $(LIBRARY)
	rm -rf *.vcd
	rm -rf uart transcript

.PHONY: all generate compile rtl simulate clean
