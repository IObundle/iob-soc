import cocotb
import os
import sys, errno
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
            sys.stdout.flush()
        elif(TXready):
            if(char == 5):
                send = 6
                await uartwrite(dut, UART_TXDATA_ADDR, send)
    print('\nTESTBENCH: finished\n\n')

@cocotb.test()
async def console_test(dut):
    char = 0
    number_of_bytes_from_cnsl = 0
    number_of_bytes_from_soc = 0
    reset_n = dut.reset
    clk_n = dut.clk
    while((not os.path.exists('soc2cnsl')) and (not os.path.exists('cnsl2soc'))):
        print('Waiting for console to create FIFO\'s')
        await Timer(CLK_PERIOD, units="ns")
    soc2cnsl = open('soc2cnsl', 'wb+', 0)
    cnsl2soc = open('cnsl2soc', 'wb+', 0)
    ##aux = open('aux.bin', 'a')
    os.set_blocking(cnsl2soc.fileno(), False)

    cocotb.start_soon(Clock(clk_n, CLK_PERIOD, units="ns").start())
    #cocotb.start_soon(time_limit(500000))
    await reset_dut(reset_n, 100*CLK_PERIOD)
    await Timer(10*CLK_PERIOD, units="ns")  # wait a bit
    dut.uart_valid.value = 0
    dut.uart_wstrb.value = 0
    await inituart(dut)

    print('\n\nTESTBENCH: connecting')

    while((os.path.exists('soc2cnsl'))):
        if(dut.trap.value.integer > 0):
            print('TESTBENCH: force cpu trap exit')
            exit()
        RXready = 0
        TXready = 0
        while(RXready != 1 and TXready != 1):
            RXready = await uartread(dut, UART_RXREADY_ADDR)
            TXready = await uartread(dut, UART_TXREADY_ADDR)
        if(RXready):
            char = await uartread(dut, UART_RXDATA_ADDR)
            soc2cnsl.write(char.to_bytes(1,  byteorder='little'))
            number_of_bytes_from_soc += 1
            if(number_of_bytes_from_soc%1000 == 0):
                print('.', end = '')
                sys.stdout.flush()
            try:
                ### IO operation ###
                soc2cnsl.flush()
            except IOError as e:
                if e.errno == errno.EPIPE:
                    ### Handle the error ###
                    print('Error flushing soc2cnsl!')
        elif(TXready):
            try:
                ### IO operation ###
                aux = cnsl2soc.read(1)
                if(aux != None):
                    send = int.from_bytes(aux, "little")
                    #print(chr(send), end = '')
                    number_of_bytes_from_cnsl += 1
                    if(number_of_bytes_from_cnsl%1000 == 0):
                        print('.', end = '')
                        sys.stdout.flush()
                    await uartwrite(dut, UART_TXDATA_ADDR, send)
            except IOError as e:
                if e.errno == errno.EPIPE:
                    ### Handle the error ###
                    print('Error writing to Pipe cnsl2soc!')


        #print("traped")

    print('TESTBENCH: finished\n\n')
    soc2cnsl.close()
    cnsl2soc.close()
