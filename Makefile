arch ?= i686
target ?= $(arch)-sel4-unknown

kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso
shroom_os := target/$(target)/debug/libshroom_os.a
linker_script := src/arch/$(arch)/linker.ld
grub_cfg := src/arch/$(arch)/grub.cfg
assembly_source_files := $(wildcard src/arch/$(arch)/*.asm)
assembly_object_files := $(patsubst src/arch/$(arch)/%.asm, \
  build/arch/$(arch)/%.o, $(assembly_source_files))

RUSTC := rustc
NASM := nasm
CARGO := cargo
LD := ld
GRUB := grub-mkrescue
QEMU := qemu-system-x86_64

LDFLAGS += -n --gc-sections -m elf_i386

CFLAGS += -Z no-landing-pads
CFLAGS += -L . #include libcore TODO clean up
CFLAGS += -L rust-sel4/target/i686-sel4-unknown/debug/
#TODO automatically build and configure rust-sel4

ENTRY_POINT ?= _start
LDFLAGS += -u ${ENTRY_POINT} # force link
LDFLAGS += -e ${ENTRY_POINT} # set entry point

.PHONY: all clean run iso cargo rust-sel4

all: rust-sel4 $(kernel)

clean:
	$(CARGO) clean
	@rm -r build

run: $(iso)
	$(QEMU) -hda $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp $(grub_cfg) build/isofiles/boot/grub
	$(GRUB) -o $(iso) build/isofiles 2> /dev/null
	@rm -r build/isofiles

$(kernel): cargo $(shroom_os) $(assembly_object_files) $(linker_script)
	$(LD) $(LDFLAGS) -T $(linker_script) \
	  -o $(kernel) $(assembly_object_files) $(shroom_os)

rust-sel4:
	$(CARGO) $(RUSTC) --manifest-path rust-sel4/Cargo.toml --target $(target) --features=SEL4_DEBUG -- -L .

cargo:
	$(CARGO) $(RUSTC) --target $(target) -- $(CFLAGS)

# compile assembly files
build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	@mkdir -p $(shell dirname $@)
	$(NASM) -felf32 $< -o $@
