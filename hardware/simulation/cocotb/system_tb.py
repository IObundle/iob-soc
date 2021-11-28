import cocotb
import os
import sys
import aiofiles

#import console python module
CONSOLE_DIR = '../../../software/console/'
#sys.path.append(CONSOLE_DIR)
#import console as cnsl
from UART import *

from cocotb.triggers import Timer
from cocotb.clock import Clock

async def reset_dut(reset_n, duration_ns):
    reset_n.value = 1
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    reset_n._log.debug("Reset complete")

#@cocotb.test()
async def basic_test(dut):
    reset_n = dut.reset
    clk_n = dut.clk
    char = 0

    cocotb.start_soon(Clock(clk_n, CLK_PERIOD, units="ns").start())
    await reset_dut(reset_n, 100*CLK_PERIOD)
    await Timer(10*CLK_PERIOD, units="ns")  # wait a bit
    dut.uart_valid.value = 0
    dut.uart_wstrb.value = 0
    await inituart(dut)

    print('\n\nTESTBENCH: connecting')
    while(char != 4):
        #print("traped")
        if(dut.trap.value.integer > 0):
            print('TESTBENCH: force cpu trap exit')
            exit()
        RXready = 0
        while(RXready != 1):
            RXready = await uartread(dut, UART_RXREADY_ADDR)
        char = await uartread(dut, UART_RXDATA_ADDR)
        print(chr(char), end = '')
        if(char == 5):
            send = int.from_bytes(b'\x06', "big")
            TXready = 0
            while(TXready != 1):
                TXready = await uartread(dut, UART_TXREADY_ADDR)
            await uartwrite(dut, UART_TXDATA_ADDR, send)
    print('\nTESTBENCH: finished\n\n')

@cocotb.test()
async def console_test(dut):
    reset_n = dut.reset
    clk_n = dut.clk
    char = 0

    cocotb.start_soon(Clock(clk_n, CLK_PERIOD, units="ns").start())
    await reset_dut(reset_n, 100*CLK_PERIOD)
    await Timer(10*CLK_PERIOD, units="ns")  # wait a bit
    dut.uart_valid.value = 0
    dut.uart_wstrb.value = 0
    await inituart(dut)

    print('\n\nTESTBENCH: connecting')

    while(char != 4):
        #print("traped")
        if(dut.trap.value.integer > 0):
            print('TESTBENCH: force cpu trap exit')
            exit()
        cocotb.start_soon(Clock(clk_n, CLK_PERIOD, units="ns").start())
        RXready = 0
        while(RXready != 1):
            RXready = await uartread(dut, UART_RXREADY_ADDR)
        char = await uartread(dut, UART_RXDATA_ADDR)
        async with aiofiles.open('{0}soc2cnsl'.format(CONSOLE_DIR), mode='w') as f:
            await f.write(char)

        if(char == 5):
            send = int.from_bytes(b'\x06', "big")
            TXready = 0
            while(TXready != 1):
                TXready = await uartread(dut, UART_TXREADY_ADDR)
            await uartwrite(dut, UART_TXDATA_ADDR, send)
    print('TESTBENCH: finished\n\n')
