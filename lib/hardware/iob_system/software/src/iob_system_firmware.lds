/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

SECTIONS {
  /* Program code */
  INCLUDE auto_iob_system_firmware.lds
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
