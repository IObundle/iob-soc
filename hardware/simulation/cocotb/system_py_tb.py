import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    reset_n._log.debug("Reset complete")

@cocotb.test()
async def basic_test(dut):
    reset_n = dut.reset
    clk_n = dut.clk
    rdata = dut.uart_rdata
    wdata = dut.uart_wdata

    cocotb.start_soon(Clock(clk_n, 10, units="ns").start())
    await reset_dut(reset_n, 1000)
    await Timer(100, units="ns")  # wait a bit
    dut.uart_valid.value = 0
    dut.uart_wstrb.value = 0
    print('\n\nTESTBENCH: connecting')
    i = 0
    data = b''
    while(i != 10):
      if(dut.trap.value.integer > 0):
        print('TESTBENCH: force cpu trap exit')
        exit()
      i += 1
      char = rdata.value
      data += char.integer.to_bytes(1, byteorder='big')
      await Timer(100, units='ns')
      wdata.value = int.from_bytes(b'\x06', "big")

    print(data)
    print('TESTBENCH: finished\n\n')
