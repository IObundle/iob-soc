#include "iob-lib.h"

//base address
static int base;

void iobnativebridgeif_setbaseaddr(int v)
{
  base = v;
}

void iobnativebridgeif_writereg(int offset, int v)
{
  IO_SET(base, offset, v);
}

int iobnativebridgeif_readreg(int offset)
{
  return IO_GET(base, offset);
}
