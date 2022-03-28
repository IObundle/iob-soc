//base address
static int base;

void iobnativebridgeif_setbaseaddr(int v)
{
  return;
}


int iobnativebridge[IOBNATIVEBRIDGEIF_ADDR_W];


void iobnativebridgeif_writereg(int offset, int v)
{
  iobnativebridge[offset] = v;
}

int iobnativebridgeif_readreg(int offset)
{
  return iobnativebridge[offset];
}
