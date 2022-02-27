#!/bin/env python3

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

@cocotb.test()
async def files_tb_test(dut):
    char = 0
    number_of_bytes_from_cnsl = 0
    number_of_bytes_from_soc = 0
    RXready = 0
    TXready = 0
    reset_n = dut.reset
    clk_n = dut.clk

    cocotb.start_soon(Clock(clk_n, CLK_PERIOD, units="ns").start())
    #cocotb.start_soon(time_limit(500000))
    await reset_dut(reset_n, 100*CLK_PERIOD)
    await Timer(10*CLK_PERIOD, units="ns")  # wait a bit
    dut.uart_valid.value = 0
    dut.uart_wstrb.value = 0
    await inituart(dut)

    soc2cnsl = open('./soc2cnsl', 'wb+')
    print('\n\nTESTBENCH: connecting')

    while(1):
        if(dut.trap.value.integer > 0):
            print('\nTESTBENCH: force cpu trap exit')
            break
        while(RXready != 1 and TXready != 1):
            RXready = await uartread(dut, UART_RXREADY_ADDR)
            TXready = await uartread(dut, UART_TXREADY_ADDR)
        if(RXready):
            if(soc2cnsl.read(1)==b''):
                char = await uartread(dut, UART_RXDATA_ADDR)
                soc2cnsl.write(char.to_bytes(1,  byteorder='little'))
                RXready = 0
            soc2cnsl.seek(0) # absolute file positioning
        if(TXready):
            try:
                ### IO operation ###
                cnsl2soc = open('./cnsl2soc', 'rb+')
            except IOError as e:
                #print('Could not open file cnsl2soc!')
                soc2cnsl.close()
                break
            aux = cnsl2soc.read(1)
            if(aux!=b''):
                #print(aux, end = '')
                #print('ENTER!')
                send = int.from_bytes(aux, "little")
                await uartwrite(dut, UART_TXDATA_ADDR, send)
                cnsl2soc.seek(0) # absolute file positioning
                cnsl2soc.truncate() # to erase all data
            cnsl2soc.close()
            TXready = 0

    print('TESTBENCH: finished\n\n')
