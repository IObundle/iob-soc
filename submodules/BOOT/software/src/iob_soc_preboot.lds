SECTIONS {
	.memory : {
		. = 0x00000000;
		*(.init);
		*(.text);
		*(*);
		. = ALIGN(4);
                _heap_start = .;
	}
}
