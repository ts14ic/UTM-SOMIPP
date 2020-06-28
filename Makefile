COMPILE=fasm

.PHONY: all run clean
.SILENT: clean

all: build_dir build/image.img

run: all
	qemu-system-x86_64 -drive format=raw,file=./build/image.img

clean:
	test -d ./build && (rm ./build/*.bin; rm ./build/image.img; rmdir ./build) || echo "Build dir already clean"

build_dir:
	$(shell mkdir -p build)

build/image.img: build/loader.bin build/kernel.bin
	dd if=/dev/zero of=build/image.img bs=1024 count=1440
	dd if=build/loader.bin of=build/image.img bs=512 seek=0 conv=notrunc
	# ??? Don't remeber the correct commands anymore, kernel is not in correct place?
	dd if=build/kernel.bin of=build/image.img bs=512 seek=4 conv=notrunc

build/%.bin: %.asm
	$(COMPILE) $< $@
