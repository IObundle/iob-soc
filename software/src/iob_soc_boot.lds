SECTIONS {
  /* Program code */
  . = 0x00000000;
  .init : { *(.init) }
  .text : { *(.text) }

  /* Read-only data */
  .rodata : { *(.rodata) }

  /* Initialized data */
  .data : { *(.data) }

  /* Uninitialized data */
  .bss : { *(.bss) }

  /* Stack */
  stack_start = .;
  .stack : { *(.stack) }
  stack_end = .;

  . = ALIGN(4);
  _heap_start = .; 
  end = .;
}
