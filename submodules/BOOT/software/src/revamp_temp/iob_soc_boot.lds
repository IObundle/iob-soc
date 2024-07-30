MEMORY
{
    RAM (xrw)       : ORIGIN = 0x10000100, LENGTH = 0x1000 
}

SECTIONS {
	.memory : {
		. = 0x00000000;
		*(.init);
		*(.text);
		*(*);
		. = ALIGN(4);
                _heap_start = .; 
	} > RAM
}
