//base address
static int base;

void regfileif_setbaseaddr(int v)
{
  return;
}


int regfile[REGFILEIF_ADDR_W];


void regfileif_writereg(int offset, int v)
{
  regfile[offset] = v;
}

int regfileif_readreg(int offset)
{
  return regfile[offset];
}
