run: AtomOS.iso Makefile
	@qemu-system-x86_64 -cdrom AtomOS.iso

debug: AtomOS.iso Makefile
	@qemu-system-x86_64 -s -S -cdrom AtomOS.iso &
	@echo "target remote localhost:1234"
	@gdb build/os.bin

push: clean
	@git commit -m "$(m)"
	@git push -u main

clean:
	@rm -rf build
	@mkdir build
	@rm AtomOS.iso

build/boot.o: boot/boot.asm
	@nasm -f elf64 boot/boot.asm -o build/boot.o

build/kernel.o: src/ arch/
	@zig build-obj -O ReleaseFast -target x86_64-freestanding -femit-bin=build/kernel.o src/main.zig

build/os.bin: build/kernel.o build/boot.o
	@ld -n -o build/os.bin -T link.ld build/boot.o build/kernel.o

AtomOS.iso: build/os.bin
	@mkdir -p build/iso/boot/grub
	@cp grub.cfg build/iso/boot/grub
	@cp build/os.bin build/iso/boot
	@grub-mkrescue -o AtomOS.iso build/iso
