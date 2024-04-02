#!/usr/bin/env python3

# importing modules
import os, sys
import signal
import importlib.util
import time
import select
from threading import Thread
import subprocess

# Global variables
ser = None
SerialFlag = True
tb_read = None
PROGNAME = "IOb-Console"
EOT = b"\x04"  # End of Transmission in Hexadecimal
ENQ = b"\x05"  # Enquiry in Hexadecimal
ACK = b"\x06"  # Acknowledgement in Hexadecimal
FTX = b"\x07"  # Receive file request
FRX = b"\x08"  # Send file request
DC1 = b"\x11"  # Device Control 1 <-> Receive request to disable iob-soc exclusive message identifiers


def tb_write(data, number_of_bytes=1, is_file=False):
    transferred_bytes = 0
    write_percentage = 100
    while transferred_bytes < number_of_bytes:
        while os.path.getsize("./cnsl2soc") != 0:
            pass
        f = open("./cnsl2soc", "wb")
        f.write(data[transferred_bytes].to_bytes(1, byteorder="little"))
        f.flush()
        transferred_bytes += 1
        if is_file:
            new_percentage = int(100 / number_of_bytes * transferred_bytes)
            if write_percentage != new_percentage:
                write_percentage = new_percentage
                if not write_percentage % 10:
                    print("%3d %c" % (write_percentage, "%"))
        f.close()


def tb_read_until(end=b"\x00"):
    data = b""
    while True:
        byte = tb_read.read(1)
        if byte == end:
            return data
        else:
            data += byte


def tb_read_file(number_of_bytes):
    data = b""
    transferred_bytes = 0
    read_percentage = 100
    while transferred_bytes < number_of_bytes:
        byte = tb_read.read(1)
        data += byte
        transferred_bytes += 1
        new_percentage = int(100 / number_of_bytes * transferred_bytes)
        if read_percentage != new_percentage:
            read_percentage = new_percentage
            if not read_percentage % 10:
                print("%3d %c" % (read_percentage, "%"))
    return data


def serial_read(number_of_bytes):
    data = b""
    i = 0
    while i < number_of_bytes:
        byte = ser.read(1)
        data += byte
        i = i + 1
    return data


# Print ERROR
def cnsl_perror(mesg):
    print(PROGNAME, end="")
    print(": " + str(mesg))
    exit(1)


# Receive file name
def cnsl_recvstr():
    if SerialFlag:
        name = ser.read_until(b"\x00")[:-1]  # reads 80 bytes
    else:
        name = tb_read_until(b"\x00")
    print(PROGNAME, end="")
    print(": file name {0} ".format(name))
    return name


# Send file to target
def cnsl_sendfile():
    file_size = 0
    name = b""

    # receive file name
    name = cnsl_recvstr()

    # open file to send
    f = open(name, "rb")
    file_size = os.path.getsize(name)
    print(PROGNAME, end="")
    print(": file of size {0} bytes".format(file_size))
    if SerialFlag:
        ser.write(file_size.to_bytes(4, byteorder="little"))  # send file size
        while ser.read() != ACK:
            pass
        ser.write(f.read())  # send file
    else:
        tb_write(file_size.to_bytes(4, byteorder="little"), 4)
        while tb_read.read(1) != ACK:
            pass
        tb_write(f.read(), file_size, True)
    f.close()
    print(PROGNAME, end="")
    print(": file sent")


def cnsl_recvfile():
    file_size = 0
    name = ""

    # receive file name
    name = cnsl_recvstr()

    # open data file
    f = open(name, "wb")
    if SerialFlag:
        file_size = int.from_bytes(serial_read(4), byteorder="little", signed=False)
        print(PROGNAME, end=" ")
        print(": file size: {0} bytes".format(file_size))
        data = serial_read(file_size)
    else:
        file_size = int.from_bytes(tb_read.read(4), byteorder="little", signed=False)
        print(PROGNAME, end=" ")
        print(": file size: {0} bytes".format(file_size))
        data = tb_read_file(file_size)
    f.write(data)
    f.close()
    print(PROGNAME, end="")
    print(": file received")


def getUserInput():
    stdin = sys.stdin
    while 1:
        if select.select([stdin], [], [], 0.5)[0]:
            user_str = stdin.read(1)
            if user_str != "":
                if SerialFlag:
                    ser.write(bytes(user_str, "UTF-8"))
                else:
                    tb_write(bytes(user_str, "UTF-8"))


def endFileTransfer():
    # unset the Bytes used in IOb-SoC comunication protocol
    global DC1
    global FTX
    global FRX
    DC1 = None
    FTX = None
    FRX = None


def usage(message):
    print(
        "{}:{}".format(
            PROGNAME, "usage: ./console.py -s <serial port> [ -f ] [ -L/--local ]"
        )
    )
    cnsl_perror(message)


def clean_exit():
    if SerialFlag:
        ser.close()
    else:
        if tb_read != None:
            tb_read.close()
        os.remove("./cnsl2soc")
        os.remove("./soc2cnsl")
    if DC1 is None:
        script_arguments = ["python3", "../../scripts/terminalMode.py"]
        subprocess.run(script_arguments)
    sys.exit(0)


def cleanup_before_exit(signum, frame):
    print(f"\n{PROGNAME}: Received signal {signum}. Ending...")
    clean_exit()


# Register the cleanup function for SIGTERM and SIGINT signals
signal.signal(signal.SIGTERM, cleanup_before_exit)
signal.signal(signal.SIGINT, cleanup_before_exit)


def init_print():
    print()
    print("+-----------------------------------------------+")
    print("|                   IOb-Console                 |")
    print("+-----------------------------------------------+")
    print()
    if SerialFlag:
        print("  BaudRate = {0}".format(ser.baudrate))
        print("  StopBits = {0}".format(ser.stopbits))
        print("  Parity   = None")
        print()
    print(PROGNAME, end="")
    print(": connecting...")
    print("", flush=True)


def init_serial():
    global ser

    package_name = "serial"
    spec = importlib.util.find_spec(package_name)
    if spec is None:
        print(PROGNAME, end="")
        print(": ERROR... py{0} is not installed!".format(package_name))
        exit(-1)

    import serial

    # configure the serial connections (the parameters differs on the device connected to)
    ser = serial.Serial()
    ser.port = sys.argv[sys.argv.index("-s") + 1]  # serial port from -s argument
    if "-b" in sys.argv:
        if len(sys.argv) < 5:
            usage("PROGNAME: not enough program arguments")
        ser.baudrate = sys.argv[sys.argv.index("-b") + 1]  # baudrate
    else:
        ser.baudrate = 115200  # baudrate
    ser.bytesize = serial.EIGHTBITS  # number of bits per bytes
    ser.parity = serial.PARITY_NONE  # set parity check: no parity
    ser.stopbits = serial.STOPBITS_ONE  # number of stop bits
    ser.timeout = None  # block read
    ser.xonxoff = False  # disable software flow control
    ser.rtscts = False  # disable hardware (RTS/CTS) flow control
    ser.dsrdtr = False  # disable hardware (DSR/DTR) flow control
    ser.writeTimeout = None  # block write


def init_files():
    read = "./soc2cnsl"
    os.mkfifo(read)
    global tb_read
    f = open("./cnsl2soc", "w")
    f.close()
    print(PROGNAME, end="")
    print(": waiting for connection from SoC testbench...")
    tb_read = open(read, "rb")


def init_console():
    global SerialFlag
    global ser

    if "-L" in sys.argv or "--local" in sys.argv:
        SerialFlag = False
        init_files()
    elif "-s" in sys.argv:
        if len(sys.argv) < 3:
            usage("PROGNAME: not enough program arguments")

        # open connection
        try:
            init_serial()
        except Exception:
            cnsl_perror("Error init serial port.")
        try:
            time.sleep(2)
            ser.port = sys.argv[sys.argv.index("-s") + 1]
            ser.open()
            ser.reset_input_buffer()
            ser.reset_output_buffer()
        except Exception:
            cnsl_perror("Error open serial port.")
    else:
        usage("PROGNAME: not enough program arguments")

    init_print()


# Main function.
def main():
    init_console()
    gotENQ = False
    input_thread = Thread(target=getUserInput, args=[], daemon=True)

    # Reading the data from the serial port or FIFO files. This will be running in an infinite loop.
    while True:
        byte = b"\x00"

        # get byte from target
        if not SerialFlag:
            byte = tb_read.read(1)
        elif ser.isOpen():
            byte = ser.read()

        # process command
        if byte == ENQ:
            if not gotENQ:
                gotENQ = True
                if SerialFlag:
                    ser.write(ACK)
                else:
                    tb_write(ACK)
        elif byte == EOT:
            print(f"{PROGNAME}: exiting...")
            clean_exit()
        elif byte == FTX:
            print(f"{PROGNAME}: got file receive request")
            cnsl_recvfile()
        elif byte == FRX:
            print(f"{PROGNAME}: got file send request")
            cnsl_sendfile()
        elif byte == DC1:
            print(f"{PROGNAME}: disabling IOB-SOC exclusive identifiers")
            endFileTransfer()
            script_arguments = ["python3", "../../scripts/terminalMode.py"]
            subprocess.run(script_arguments)
            print(f"{PROGNAME}: start reading user input")
            input_thread.start()
        else:
            print(str(byte, "iso-8859-1"), end="", flush=True)


if __name__ == "__main__":
    main()
