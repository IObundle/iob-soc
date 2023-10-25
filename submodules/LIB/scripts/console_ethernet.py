#!/usr/bin/env python3

# importing modules
import os
import sys
import importlib.util
import importlib.machinery

if __name__ == "__main__":
    if "-e" in sys.argv:
        # Get ethernet dir from string in arguments after '-e' flag
        ethernet_dir = os.path.realpath(sys.argv[sys.argv.index("-e") + 1])

        sys.path.append(ethernet_dir)
        # Save argv and override it with new values because ethBase requires them
        saved_argv = sys.argv
        try:
            sys.argv = [
                "eth_comm.py",
                sys.argv[sys.argv.index("-i") + 1] if "-i" in sys.argv else "eno1",
                sys.argv[sys.argv.index("-m") + 1]
                if "-m" in sys.argv
                else "4437e6a6893b",
                "randomFile",
            ]
            from software.python.ethBase import CreateSocket, SyncAckFirst, SyncAckLast
            from software.python.ethRcvData import RcvFile
            from software.python.ethSendData import SendFile
        finally:
            sys.argv = saved_argv
    else:
        ethernet_dir = ""

    if "-c" in sys.argv:
        # Get console filepath
        console_path = os.path.realpath(sys.argv[sys.argv.index("-c") + 1])
        # Save current __name__ and override it to run code from console module
        name_backup = __name__
        __name__ = "console"
        # Run code from console module
        exec(open(console_path).read())
        # Restore __name__
        __name__ = name_backup
        del name_backup
    else:
        console_path = ""

# Global variables
EFTX = b"\x11"  # Receive file by ethernet request
EFRX = b"\x12"  # Send file by ethernet request


# Send file to target by ethernet
def cnsl_sendfile_ethernet():
    file_size = 0
    name = b""
    socket = CreateSocket()

    # receive file name
    name = cnsl_recvstr()

    file_size = os.path.getsize(name)

    print(PROGNAME, end="")
    print(": file of size {0} bytes".format(file_size))
    if SerialFlag:
        ser.write(file_size.to_bytes(4, byteorder="little"))  # send file size
        while ser.read() != ACK:
            pass
    else:
        tb_write(file_size.to_bytes(4, byteorder="little"), 4)
        while tb_read(1) != ACK:
            pass

    # Send Data File
    SyncAckFirst(socket)
    SendFile(socket, name)

    print(PROGNAME, end="")
    print(": file sent")

    # Close Socket
    socket.close()


def cnsl_recvfile_ethernet():
    file_size = 0
    name = ""
    socket = CreateSocket()

    # receive file name
    name = cnsl_recvstr()

    if SerialFlag:
        file_size = int.from_bytes(serial_read(4), byteorder="little", signed=False)
        print(PROGNAME, end=" ")
        print(": file size: {0} bytes".format(file_size))
    else:
        file_size = int.from_bytes(tb_read(4), byteorder="little", signed=False)
        print(PROGNAME, end=" ")
        print(": file size: {0} bytes".format(file_size))

    # Receive Data File
    SyncAckLast(socket)
    RcvFile(socket, name, file_size)

    print(PROGNAME, end="")
    print(": file received".format(file_size))

    # Close Socket
    socket.close()


def usage(message):
    print(
        "{}:{}".format(
            PROGNAME,
            "usage: ./console_ethernet.py -s <serial port> -c <console path> [ -f ] [ -L/--local ] -e <ethernet submodule directory> -i <ethernet interface> -m <ethernet mac address>",
        )
    )
    cnsl_perror(message)


# Main function.
def main():
    if not console_path or not ethernet_dir:
        usage("PROGNAME: requires ethernet dir and console path")

    load_fw = init_console()
    gotENQ = False
    input_thread = Thread(target=getUserInput, args=[], daemon=True)

    # Reading the data from the serial port or FIFO files. This will be running in an infinite loop.
    while True:
        byte = b"\x00"

        # get byte from target
        if not SerialFlag:
            byte = tb_read(1)
        elif ser.isOpen():
            byte = ser.read()
        # process command
        if byte == ENQ:
            if not gotENQ:
                gotENQ = True
                if load_fw:
                    if SerialFlag:
                        ser.write(FRX)
                    else:
                        tb_write(FRX)
                else:
                    if SerialFlag:
                        ser.write(ACK)
                    else:
                        tb_write(ACK)
        elif byte == EOT:
            print(PROGNAME, end="")
            print(": exiting...")
            clean_exit()
        elif byte == FTX:
            print(PROGNAME, end="")
            print(": got file receive request")
            cnsl_recvfile()
        elif byte == FRX:
            print(PROGNAME, end="")
            print(": got file send request")
            cnsl_sendfile()
        elif byte == EFTX:
            print(PROGNAME, end="")
            print(": got file receive by ethernet request")
            cnsl_recvfile_ethernet()
        elif byte == EFRX:
            print(PROGNAME, end="")
            print(": got file send by ethernet request")
            cnsl_sendfile_ethernet()
        elif byte == DC1:
            print(PROGNAME, end="")
            print(": end of file transfer")
            endFileTransfer()
            print(PROGNAME, end="")
            print(": start reading user input")
            input_thread.start()
        else:
            print(str(byte, "iso-8859-1"), end="", flush=True)


if __name__ == "__main__":
    main()
