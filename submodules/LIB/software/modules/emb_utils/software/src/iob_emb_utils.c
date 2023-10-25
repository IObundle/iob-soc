void perror(char *s) {
  printf("ERROR: %s", s);
  uart_finish();
}
