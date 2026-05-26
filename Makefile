all: swapdumper.z64
.PHONY: all
.SECONDARY:

BUILD_DIR := build
SOURCE_DIR := src
include $(N64_INST)/include/n64.mk

OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/pif.o $(BUILD_DIR)/accessory.o $(BUILD_DIR)/link_stubs.o

N64_CFLAGS += -std=gnu2x -Os -G0 -DNDEBUG -I../../src

swapdumper.z64: N64_ROM_TITLE = "N64 SwapDumper"
swapdumper.z64: $(BUILD_DIR)/swapdumper.elf
	@echo "    [Z64] $@"
	cp $< $<.stripped
	$(N64_STRIP) -s $<.stripped
	$(N64_ELFCOMPRESS) -o $(dir $<) -c $(N64_ROM_ELFCOMPRESS) $<.stripped
	@rm -f $@
	DFS_FILE="$(filter %.dfs, $^)"; \
	if [ -z "$$DFS_FILE" ]; then \
		$(N64_TOOL) $(N64_TOOLFLAGS) --toc --output $@ --align 256 $<.stripped; \
	else \
		$(N64_TOOL) $(N64_TOOLFLAGS) --toc --output $@ --align 256 $<.stripped --align 16 "$$DFS_FILE"; \
	fi
	if [ ! -z "$(strip $(N64_ED64ROMCONFIGFLAGS))" ]; then \
		$(N64_ED64ROMCONFIG) $(N64_ED64ROMCONFIGFLAGS) $@; \
	fi

$(BUILD_DIR)/swapdumper.elf: $(OBJS)

clean:
	rm -rf $(BUILD_DIR) *.z64
.PHONY: clean

-include $(wildcard $(BUILD_DIR)/*.d)
