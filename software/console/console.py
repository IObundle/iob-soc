#
# Python adaptation of the console program writen in C.
# By Pedro Antunes:
# https://github.com/PedroAntunes178
#

# importing modules
import os
import sys
import importlib.util
import time
import curses.ascii

package_name = 'serial'
spec = importlib.util.find_spec(package_name)
if spec is None:
    print("IOb-Console: ERROR... py{0} is not installed!".format(package_name))
    exit()
import serial

from FIFO import *

# Global variables
SerialFlag = True
mode = 0o600
PROGNAME = "IOb-Console"
EOT = b'\x04' # End of Transmission in Hexadecimal
ENQ = b'\x05' # Enquiry in Hexadecimal
ACK = b'\x06' # Acknowledgement in Hexadecimal
FTX = b'\x07' # Receive file request
FRX = b'\x08' # Send file request
soc2cnsl = FifoFile('./soc2cnsl')
cnsl2soc = FifoFile('./cnsl2soc')


# configure the serial connections (the parameters differs on the device you are connecting to)

ser = serial.Serial()
ser.port = "/dev/ttyUSB0"
ser.baudrate = 115200
ser.bytesize = serial.EIGHTBITS #number of bits per bytes
ser.parity = serial.PARITY_NONE #set parity check: no parity
ser.stopbits = serial.STOPBITS_ONE #number of stop bits
#ser.timeout = None          #block read
#ser.timeout = 1            #non-block read
ser.timeout = 2              #timeout block read
ser.xonxoff = False     #disable software flow control
ser.rtscts = False     #disable hardware (RTS/CTS) flow control
ser.dsrdtr = False       #disable hardware (DSR/DTR) flow control
ser.writeTimeout = 2     #timeout for write


# Print ERROR
def cnsl_perror(mesg):
    print(PROGNAME, end = '')
    print(": " + str(mesg))
    exit(1)

# Receive file name
def cnsl_recvstr():
    if SerialFlag:
        name = ser.read_until(b'\x00') # reads 80 bytes
    else:
        name = soc2cnsl.read_until(b'\x00')
    print(PROGNAME, end = '')
    print(': file name {0} '.format(name))
    sys.stdout.flush()
    return name

# Send file to target
def cnsl_sendfile():
    file_size = 0
    name = b''
    # receive file name
    name = cnsl_recvstr()[:-1]
    # open file to send
    # print(name)
    f = open(name, 'rb')
    file_size = os.path.getsize(name)
    if SerialFlag:
        ser.write(file_size.to_bytes(4,  byteorder='little')) #send file size
        ser.write(f.read()) #send file
    else:
        cnsl2soc.write(file_size.to_bytes(4,  byteorder='little'))
        cnsl2soc.write(f.read())
    f.close()
    print(PROGNAME, end = '')
    print(': file of size {0} bytes'.format(file_size))
    print(PROGNAME, end = '')
    print(': file sent')

def cnsl_recvfile():
    file_size = 0
    name = ""
    # receive file name
    name = cnsl_recvstr()[:-1]
    # open data file
    f = open(name, 'wb')
    if SerialFlag:
        aux = ser.read(4)
        file_size = int.from_bytes(aux, byteorder='little', signed=False)
        print(PROGNAME, end = ' ')
        print(': file size: {0} bytes'.format(file_size))
        data = ser.read(file_size)
    else:
        file_size = int.from_bytes(soc2cnsl.read(4), byteorder='little', signed=False)
        data = soc2cnsl.read(file_size)
    # print(data)
    f.write(data)
    f.close()
    print(PROGNAME, end = '')
    print(': file of size {0} bytes received'.format(file_size))

def usage(message):
    cnsl_perror("usage: ./console -s <serial port> [ -f ] [ -L/--local ]")
    cnsl_perror(message)

def clean_exit():
    if SerialFlag:
        ser.close()
    cnsl2soc.close()
    soc2cnsl.close()
    exit(0)

def init_print():
    print()
    print('+-----------------------------------------------+')
    print('|                   IOb-Console                 |')
    print('+-----------------------------------------------+')
    print()
    print('  BaudRate = {0}'.format(ser.baudrate))
    print('  StopBits = {0}'.format(ser.stopbits))
    print('  Parity   = None')
    print()
    print(PROGNAME, end = '')
    print(': connecting...')
    print()


# Main function.
def main():
    global SerialFlag
    load_fw = False
    gotENQ = False
    byte = b'\x00'
    if ('-L' in sys.argv or '--local' in sys.argv):
        SerialFlag = False
        # soc2cnsl = FifoFile('./soc2cnsl')
        # cnsl2soc = FifoFile('./cnsl2soc')
    elif ('-s' in sys.argv):
        if (len(sys.argv)<3):
            usage("PROGNAME: not enough program arguments")
        # open connection
        try:
            ser.port = sys.argv[sys.argv.index('-s')+1]
            ser.open()
        except Exception:
            usage("Error open serial port.")
    else:
        usage("PROGNAME: not enough program arguments")
    if ('-f' in sys.argv):
        load_fw = True
    init_print()
    # Reading the data from the serial port or FIFO files. This will be running in an infinite loop.
    while(True):
        # get byte from target
        if (not SerialFlag):
            byte = soc2cnsl.read()
        elif (ser.isOpen()):
            byte = ser.read()
            #if(byte in b'\x04\x05\x06\x07\x08'):
                #print(byte)
        # process command
        if (byte == ENQ):
            if (not gotENQ):
                gotENQ = True
                if (load_fw):
                    if SerialFlag:
                        ser.write(FRX)
                    else:
                        cnsl2soc.write(FRX)
                else:
                    if SerialFlag:
                        ser.write(ACK)
                    else:
                        cnsl2soc.write(ACK)
        elif (byte == EOT):
            print(PROGNAME, end = '')
            print(': exiting...')
            clean_exit()
        elif (byte == FTX):
            print(PROGNAME, end = '')
            print(': got file receive request')
            cnsl_recvfile()
        elif (byte == FRX):
            print(PROGNAME, end = '')
            print(': got file send request')
            cnsl_sendfile()
        else:
            print(str(byte, 'ascii'), end = '')
            sys.stdout.flush()

if __name__ == "__main__":
    main()
