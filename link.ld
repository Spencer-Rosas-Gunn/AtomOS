ENTRY(_start)
OUTPUT_FORMAT(elf64-x86-64)

PHDRS
{
    text PT_LOAD FILEHDR PHDRS;
    data PT_LOAD;
}

SECTIONS
{
    . = 1M + SIZEOF_HEADERS;

    .multiboot : {
        KEEP(*(.multiboot))  /* Use KEEP to ensure this section is not discarded */
    } :text

    . = ALIGN(0x1000);  /* Align to 4KB for the next sections */

    .text : {
        *(.text*)
        *(.gnu.linkonce.r.* .rodata .rodata*);
    }

    IDTData : {
        *(IDT*);
    }

    . = ALIGN(0x1000);
    .data : {
        *(.data*)
    } :data

    . = ALIGN(64);
    .bss : {
        *(.dynbss .bss .bss* COMMON .gnu.linkonce.b.*)
    }

    _end_kernel = .;  /* Define the end of the kernel */
}
