//base address
static int base;

void nativebridgeif_setbaseaddr(int v)
{
  return;
}


int nativebridge[NATIVEBRIDGEIF_ADDR_W];


void nativebridgeif_writereg(int offset, int v)
{
  nativebridge[offset] = v;
}

int nativebridgeif_readreg(int offset)
{
  return nativebridge[offset];
}
