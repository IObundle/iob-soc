SECTIONS {
  /* Program code */
  . = 0x00001000; /* 2^IOB_SOC_BOOT_BOOT_ROM_ADDR_W = 2^12 = 4096 = 0x1000 */
  .init : { *(.init) }
  .text : { *(.text) }

  .memory : {
    /* Read-only data */
    *(.rodata);

    /* Initialized data */
    *(.data);

    /* Uninitialized data */
    *(.bss);

    /* Any symbols not explicitly mentioned in previous sections are included in this section */
    *(*);
  }

  /* Stack */
  stack_start = .;
  .stack : { *(.stack) }
  stack_end = .;

  . = ALIGN(4);
  _heap_start = .;
  end = .;
}
