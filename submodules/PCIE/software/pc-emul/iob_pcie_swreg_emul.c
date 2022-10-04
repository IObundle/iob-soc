//base address
static int base;

void pcie_setbaseaddr(int v)
{
  return;
}


int pcie[PCIE_ADDR_W];


void pcie_writereg(int offset, int v)
{
  pcie[offset] = v;
}

int pcie_readreg(int offset)
{
  return pcie[offset];
}
