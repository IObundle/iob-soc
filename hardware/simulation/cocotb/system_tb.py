import cocotb
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

# address macros
UART_SOFTRESET_ADDR = 0
UART_DIV_ADDR = 1
UART_TXDATA_ADDR = 2
UART_TXEN_ADDR = 3
UART_TXREADY_ADDR = 4
UART_RXDATA_ADDR = 5
UART_RXEN_ADDR = 6
UART_RXREADY_ADDR = 7
# other macros
FREQ = 100000000
BAUD = 5000000
CLK_PERIOD = 10 # 20 ns

# 1-cycle write
async def uartwrite(dut, cpu_address, cpu_data):
    await Timer(1, units="ns")
    dut.uart_addr.value = cpu_address
    dut.uart_valid.value = 1
    dut.uart_wstrb.value = int.from_bytes(b'\x0f', "big")
    dut.uart_wdata.value = cpu_data
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    dut.uart_wstrb.value = 0;
    dut.uart_valid.value = 0;

# 2-cycle read
async def uartread(dut, cpu_address, read_reg):
    await Timer(1, units="ns")
    dut.uart_addr.value = cpu_address
    dut.uart_valid.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    read_reg = dut.uart_rdata.value.integer
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    dut.uart_valid.value = 0;

async def inituart(dut):
    #pulse reset uart
    await uartwrite(dut, UART_SOFTRESET_ADDR, 1)
    await uartwrite(dut, UART_SOFTRESET_ADDR, 0)
    #config uart div factor
    await uartwrite(dut, UART_DIV_ADDR, int(FREQ/BAUD))
    #enable uart for receiving
    await uartwrite(dut, UART_RXEN_ADDR, 1)
    await uartwrite(dut, UART_TXEN_ADDR, 1)

async def reset_dut(reset_n, duration_ns):
    reset_n.value = 1
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    reset_n._log.debug("Reset complete")

@cocotb.test()
async def basic_test(dut):
    reset_n = dut.reset
    clk_n = dut.clk
    char = 0
    reset = 0

    cocotb.start_soon(Clock(clk_n, CLK_PERIOD, units="ns").start())
    await reset_dut(reset_n, 100*CLK_PERIOD)
    await Timer(10*CLK_PERIOD, units="ns")  # wait a bit
    dut.uart_valid.value = 0
    dut.uart_wstrb.value = 0
    await inituart(dut)

    print('\n\nTESTBENCH: connecting')
    j = 0
    data = b'\x00'
    while(data[-1] != b'\x04' and j < 1000):
      #print("traped")
      if(dut.trap.value.integer > 0):
          print('TESTBENCH: force cpu trap exit')
          exit()
      j += 1
      ready = 0
      i = 0
      while(not ready):
          await uartread(dut, UART_RXREADY_ADDR, ready)
      await uartread(dut, UART_RXDATA_ADDR, char)
      data += char.to_bytes(1, byteorder='big')
      send = int.from_bytes(b'\x06', "big")
      ready = 0
      i = 0
      while(not ready):
          await uartread(dut, UART_TXREADY_ADDR, ready)
      await uartwrite(dut, UART_TXDATA_ADDR, send)

    print(data)
    print('TESTBENCH: finished\n\n')
