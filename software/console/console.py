#
# Python adaptation of the console program writen in C.
# By Pedro Antunes:
# https://github.com/PedroAntunes178
#

# importing modules
import os
import sys
import serial
import time

# Global variables
path = "./cnsl2soc"
path2 = "./soc2cnsl"
mode = 0o600
PROGNAME = "IOb-Console"

# configure the serial connections (the parameters differs on the device you are connecting to)

ser = serial.Serial()
#ser.port = "/dev/ttyUSB0"
ser.port = "/dev/ttyUSB7"
#ser.port = "/dev/ttyS2"
ser.baudrate = 9600
ser.bytesize = serial.EIGHTBITS #number of bits per bytes
ser.parity = serial.PARITY_NONE #set parity check: no parity
ser.stopbits = serial.STOPBITS_ONE #number of stop bits
#ser.timeout = None          #block read
ser.timeout = 1            #non-block read
#ser.timeout = 2              #timeout block read
ser.xonxoff = False     #disable software flow control
ser.rtscts = False     #disable hardware (RTS/CTS) flow control
ser.dsrdtr = False       #disable hardware (DSR/DTR) flow control
ser.writeTimeout = 2     #timeout for write


# Print ERROR
def cnsl_error(mesg):
    print(PROGNAME, end = ' ')
    print(": " + str(mesg))
    exit(1)

# Receive file name
def cnsl_recvstr(name):
    name = "".join(map(chr, ser.read_until()))
    print(PROGNAME, end = ' ')
    print('file name: ' + str(name))
    sys.stdout.flush()

# Send file to target
def cnsl_sendfile():
    file_size = 0
    name = ""
    # receive file name
    cnsl_recvstr(name)
    # open file to send
    f = open(name, "rb")
    file_size = os.path.getsize(name)
    ser.write(file_size) #send file size
    ser.write(f.read()) #send file
    ser.write("\n<<EOF>>\n") #send message indicating file transmission complete
    f.close()
    print(PROGNAME, end = ' ')
    print(': file size:' + file_size + 'bytes')

def cnsl_rcvfile():
    file_size = 0
    name = ""
    # receive file name
    cnsl_recvstr(name)
    # open data file
    f = open(name, "wb")
    file_size = int.from_bytes(ser.read(4), byteorder='big', signed=False)
    data = ser.read(file_size)
    print(data, file=f)
    f.close()
    print(PROGNAME, end = ' ')
    print(': file size:' + file_size + 'bytes received')

def open_FIFO(pathi):
    if not os.path.exists(pathi):
        os.mkfifo(pathi, mode)
        print('FIFO named ' + str(pathi) + 'is created successfully.')

def usage(message):
    cnsl_perror("usage: ./console -s <serial port> [ -f <firmware file> ]")
    cnsl_perror(message)

def clean_exit():
    os.remove(path)
    os.remove(path2)
    print('FIFO files deleted')
    ser.close()
    exit(0)

# Main function.
def main():
    open_FIFO(path)
    open_FIFO(path2)
    try:
        ser.open()
    except Exception:
        print("error open serial port.")
    # ser.isOpen()
    # Reading the data from the serial port. This will be running in an infinite loop.
    clean_exit()

main()

