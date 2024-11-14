# Directory paths
SYS_DIR = ../../sw/sys
LIB_DIR = libs
INC_DIR = ../../sw/include
SRC_DIR = ../../sw/src

# Includes
INCLUDES = $(foreach d, $(INC_DIR), -I$d)
INCLUDES += $(foreach d, $(SYS_DIR), -I$d)

# Source files
TEST_SRCS := $(shell find . -name "*.c")
SRC_FILES := $(shell find $(SRC_DIR) -name "*.c")
SW_SRCS := $(filter-out $(LIB_DIR)/libintegr.a, $(TEST_SRCS) $(SRC_FILES))

# RISC-V Toolchain
RV_TOOL_PREFIX = riscv64-unknown-elf-
RV_GCC := $(RV_TOOL_PREFIX)gcc
RV_AR := $(RV_TOOL_PREFIX)ar
RV_OBJDUMP := $(RV_TOOL_PREFIX)objdump
RV_OBJCOPY := $(RV_TOOL_PREFIX)objcopy

# Directories and object files
OBJDIR = ./objs
OBJS = $(SW_SRCS:%.c=$(OBJDIR)/%.o)

# Ensure necessary directories exist
$(OBJDIR):
	mkdir -p $(OBJDIR)
$(LIB_DIR):
	mkdir -p $(LIB_DIR)

# Create subdirectories within OBJDIR to mirror SRC_DIR structure
$(OBJDIR)/%.o: %.c | $(OBJDIR)
	@mkdir -p $(dir $@)   # Create subdirectory if it doesn't exist
	$(RV_GCC) $(INCLUDES) -march=rv32i -mabi=ilp32 -Werror -falign-functions=32 -falign-jumps=32 -c $< -o $@

# Build library
$(LIB_DIR)/libintegr.a: $(OBJS) | $(LIB_DIR)
	@mkdir -p $(LIB_DIR)
	$(RV_AR) -rcs $@ $(OBJS)

# Generate ELF file, ensuring libintegr.a is created first
main.riscv : $(TEST_SRCS) $(LIB_DIR)/libintegr.a $(SYS_DIR)/crt.S  $(SYS_DIR)/linker.ld
	$(RV_GCC) -Werror -g -falign-functions=32 -falign-jumps=32 $(INCLUDES) -L$(LIB_DIR) \
		-DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O0 -g \
		-fno-builtin-printf -static -nostdlib $(SYS_DIR)/crt.S -march=rv32i -mabi=ilp32\
		-nostartfiles -lm -lgcc -T $(SYS_DIR)/linker.ld -o $@ $(TEST_SRCS) $(SRC_FILES) -lintegr -Xlinker -Map=main.map

# Disassemble ELF file to create a .dis file
main.dis : main.riscv
	$(RV_OBJDUMP) -d $< > $@

# Shortcut target for generating .dis file
dis : main.dis

# Generate Verilog-compatible .hex file
main.hex : main.riscv
	$(RV_OBJCOPY) -O verilog $< main.vh
	python2 vh2hex.py -m main.vh -o $@ -b 0x00000000 -d 0x00000000 -i 0x00010000 -w 4
	rm main.vh

# Shortcut target for generating .hex file
sw : dis main.hex

# Clean up generated files
clean:
	rm -rf $(OBJDIR) *.riscv *.dis *.hex *.map ../sw libs

# Declare phony targets
.PHONY: all sw clean dis
