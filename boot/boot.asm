multiboot_start:	
section .multiboot
align 4
        dd 0x1BADB002            ;; magic number
        dd 0x00                  ;; flags
        dd -(0x1BADB002 + 0x00)  ;; checksum

section .text
global _start
extern kmain

section .data
gdt_start:
	dq 0
	dq 0x00CF9A000000FFFF
	dq 0x00CF92000000FFFF
gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_start - 1 ; Limit (size of GDT - 1)
	dq gdt_start                ; Base address of GDT

bits 32
_start:
	;; Read Multiboot Arguments
	mov esi, eax
	mov edi, ebx
	
	;; Load GDT
	lgdt [gdt_descriptor]

	;; Set up segment registers (for 32-bit mode)
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	mov gs, ax

	;; Enter long mode
	cli

	mov eax, cr4
	or eax, 0x20
	mov cr4, eax

	mov eax, 0xC0000080
	rdmsr
	or eax, 0x00000100
	wrmsr

	jmp 0x8:long_mode_entry
	
bits 64
long_mode_entry:
	;; Initialize Stack
	mov rsp, stack_top
	
	;; Enter the kernel
	jmp kmain

	;; Halt the CPU
	cli
	hlt

section .bss
align 4096
	gdt resb 64
	
stack_bottom:
        ;; 4KB stack
        resb 4096
stack_top:
