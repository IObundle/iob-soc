//receive msg after program started
do begin 
   cpu_getchar(cpu_char);
   $write("%c", cpu_char);
end while (cpu_char != "\n"); 
