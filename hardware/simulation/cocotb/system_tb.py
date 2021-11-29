import cocotb
import os

from UART import *

from cocotb.triggers import Timer
from cocotb.clock import Clock

async def reset_dut(reset_n, duration_ns):
    reset_n.value = 1
    await Timer(duration_ns, units="ns")
    reset_n.value = 0
    reset_n._log.debug("Reset complete")

async def time_limit(duration_ns):
    await Timer(duration_ns, units="ns")
    exit()

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
        TXready = 0
        while(RXready != 1 and TXready != 1):
            RXready = await uartread(dut, UART_RXREADY_ADDR)
            TXready = await uartread(dut, UART_TXREADY_ADDR)
            #print(":p")
        if(RXready):
            char = await uartread(dut, UART_RXDATA_ADDR)
            print(chr(char), end = '')
        elif(TXready):
            if(char == 5):
                send = int.from_bytes(b'\x06', "little")
                await uartwrite(dut, UART_TXDATA_ADDR, send)
    print('\nTESTBENCH: finished\n\n')

@cocotb.test()
async def console_test(dut):
    char = 0
    reset_n = dut.reset
    clk_n = dut.clk
    soc2cnsl = open(CONSOLE_DIR+'soc2cnsl', 'w')
    #cnsl2soc = open(CONSOLE_DIR+'cnsl2soc', 'rb')
    #os.set_blocking(cnsl2soc.fileno(), False)
    #GETS TRAPED WHEN TRYING TO OPEN CNSL2SOC...
    #print("not yet traped")

    cocotb.start_soon(Clock(clk_n, CLK_PERIOD, units="ns").start())
    cocotb.start_soon(time_limit(500000))
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
        TXready = 0
        while(RXready != 1 and TXready != 1):
            RXready = await uartread(dut, UART_RXREADY_ADDR)
            TXready = await uartread(dut, UART_TXREADY_ADDR)
            #print(":p")
        if(RXready):
            char = await uartread(dut, UART_RXDATA_ADDR)
            print(chr(char), end = '')
            #print("traped")
            soc2cnsl.write(chr(char))
            soc2cnsl.flush()
        elif(TXready):
            if(char == 5):
                send = int.from_bytes(b'\x06', "little")
                await uartwrite(dut, UART_TXDATA_ADDR, send)
            '''
            print("traped")
            with open(CONSOLE_DIR+'cnsl2soc', 'rb') as f:
                os.set_blocking(f.fileno(), False)
                print("traped")
                send = f.read()
            await uartwrite(dut, UART_TXDATA_ADDR, send)'''


        #print("traped")

    print('TESTBENCH: finished\n\n')
    soc2cnsl.close()
