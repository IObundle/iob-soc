import cocotb
import os

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
CONSOLE_DIR = '../../../software/console/'

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
async def uartread(dut, cpu_address):
    await Timer(1, units="ns")
    dut.uart_addr.value = cpu_address
    dut.uart_valid.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    #print(dut.uart_rdata.value)
    read_reg = dut.uart_rdata.value.integer
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    dut.uart_valid.value = 0;
    return read_reg;

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
    #os.system('{}console -L'.format(CONSOLE_DIR))

    cocotb.start_soon(Clock(clk_n, CLK_PERIOD, units="ns").start())
    await reset_dut(reset_n, 100*CLK_PERIOD)
    await Timer(10*CLK_PERIOD, units="ns")  # wait a bit
    dut.uart_valid.value = 0
    dut.uart_wstrb.value = 0
    await inituart(dut)

    print('\n\nTESTBENCH: connecting')
    while(char != 4):
        if(dut.trap.value.integer > 0):
            print('TESTBENCH: force cpu trap exit')
            exit()
        RXready = 0
        while(RXready != 1):
            RXready = await uartread(dut, UART_RXREADY_ADDR)
        char = await uartread(dut, UART_RXDATA_ADDR)
        with open('{}soc2cnsl'.format(CONSOLE_DIR), 'wb') as fifo:
            fifo.write(char.to_bytes(1, byteorder='little'))

        with os.open('{}cnsl2soc'.format(CONSOLE_DIR), os.O_RDONLY | os.O_NONBLOCK) as fifo:
            send = ord(fifo.read())
        TXready = 0
        while(TXready != 1):
            TXready = await uartread(dut, UART_TXREADY_ADDR)
        await uartwrite(dut, UART_TXDATA_ADDR, send)
    print('TESTBENCH: finished\n\n')
