#include "interconnect.h"

//base address
static int base;

void nativebridgeif_setbaseaddr(int v)
{
  base = v;
}

void nativebridgeif_writereg(int offset, int v)
{
  IO_SET(base, offset, v);
}

int nativebridgeif_readreg(int offset)
{
  return IO_GET(base, offset);
}
