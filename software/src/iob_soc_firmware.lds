SECTIONS {
	.memory : {
		. = 0x000000;
		*(.init);
		*(.text);
		*(*);
		. = ALIGN(4);
                _heap_start = .; 
		end = .;
	}
}
