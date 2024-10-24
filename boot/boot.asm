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

section .table
align 4096
table4:
	dq table3
	times 511 dq 0

table3:
	dq table2
	times 511 dq 0

table2:
	dq table1
	times 511 dq 0

table1:
	resb 4096
	
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

	;; Initialize Page Table
	;; rbx = 0
	mov ebx, 0
start_loop:
	;; *(table1 + rbx * 8) := ebx
	mov eax, ebx
	shl eax, 3
	mov ecx, eax
	mov eax, table1
	add eax, ecx
	mov ecx, eax
	mov eax, ebx
	shl eax, 12
	or eax, 0x60
	mov [eax], ebx
	;; ebx := ebx + 1
	inc ebx
	;; if(ebx != 512) goto start_loop
	cmp ebx, 512
	jl start_loop

	mov eax, cr4
	or eax, (1 << 5)
	mov cr4, eax
	
	mov eax, 0xC0000080
	rdmsr
	or eax, 0x00000100
	wrmsr

	mov eax, table4
	mov cr3, eax
	
	mov eax, cr0
	or eax, (1 << 31) | (1 << 0)
	mov cr0, eax

	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

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
stack_bottom:
        ;; 4KB stack
        resb 4096
stack_top:
