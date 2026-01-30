CC 			= ${CROSSCOMPILE}gcc

BUILD_DIR 		= ./build
POLYBENCH_DIR	= $(abspath ./)
DRIVERS_DIR		= $(abspath ../drivers)
ROOT_PATH		= $(abspath ../)
SRC_DIRC := $(POLYBENCH_DIR) $(DRIVERS_DIR)

ifeq ($(RV64),1)
	# ariane
	CROSSCOMPILE 	?= riscv64-unknown-elf-
	MACHINEFLAGS 	= -march=rv64gc -mabi=lp64d -lm -lgcc -Wall
	LINKER 			= $(POLYBENCH_DIR)/linker_ariane.lds
else
	# snitch
	CROSSCOMPILE 	?= riscv64-unknown-elf-
	MACHINEFLAGS  	= -march=rv32g -mabi=ilp32d -lm -lgcc -Wall
	LINKER 			= $(POLYBENCH_DIR)/linker_snitch.lds
endif

CFLAGS = $(MACHINEFLAGS)\
	-Wall \
	-fmessage-length=0 \
	-ffunction-sections \
	-fdata-sections \
	-fno-builtin-printf \
	-static \
	-std=gnu99

# must compile con -O0 to compile for memory addresses higher then 0x8000_0000
# gcc 13.2.0 actually doesn't support medany, so it will fail to relocate while optimizing jumps
CFLAGS 	+= -O0 -ggdb -mcmodel=medany -mexplicit-relocs

LDFLAGS 	= -nostartfiles

# Find all the C and C++ files we want to compile
# Note the single quotes around the * expressions. The shell will incorrectly expand these otherwise, but we want to send the * directly to the find command.
SRCS := $(shell find $(POLYBENCH_DIR) -name '$(TEST).c' -or -name 'startup.S' -or -name 'bench_wrap.c')
SRCS += $(shell find $(DRIVERS_DIR) -name 'uart.c')
# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into ./build/./your_dir/hello.cpp.o
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

# String substitution (suffix version without %).
# As an example, ./build/hello.cpp.o turns into ./build/hello.cpp.d
DEPS := $(OBJS:.o=.d)

# Every folder in ./src will need to be passed to GCC so that it can find header files
INC_DIRS := $(shell find $(SRC_DIRS) -type d)
# Add a prefix to INC_DIRS. So moduleA would become -ImoduleA. GCC understands this -I flag
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

# The -MMD and -MP flags together generate Makefiles for us!
# These files will have .d instead of .o as the output.
CPPFLAGS := $(INC_FLAGS) -MMD -MP

# The final build step.
$(BUILD_DIR)/$(TEST)_$(CPU).elf: $(OBJS)
	$(CC) -E -P -x c $(CPPFLAGS) $(CFLAGS) -D CPU=$(CPU) $(LINKER) > $(LINKER).tmp
	$(CC) $(OBJS) $(LDFLAGS) -T$(LINKER).tmp -o $@ $(LDFLAGS)

# Build step for C source
$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Build step for C++ source
$(BUILD_DIR)/%.S.o: %.S
	mkdir -p $(dir $@)
	$(CC) $(MACHINEFLAGS) -c $< -o $@


.PHONY: clean all
all: $(BUILD_DIR)/$(TEST)_$(CPU).elf
clean:
	rm -r $(BUILD_DIR)
	rm -r $(LINKER).tmp

# Include the .d makefiles. The - at the front suppresses the errors of missing
# Makefiles. Initially, all the .d files will be missing, and we don't want those
# errors to show up.
-include $(DEPS)
