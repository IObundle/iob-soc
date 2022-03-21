#include "iob-lib.h"

//base address
static int base;

void regfileif_setbaseaddr(int v)
{
  base = v;
}

void regfileif_writereg(int offset, int v)
{
  IO_SET(base, offset, v);
}

int regfileif_readreg(int offset)
{
  return IO_GET(base, offset);
}
