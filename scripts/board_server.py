#!/usr/bin/env python3

DEBUG = False


# This is a simple server that will listen for connections on port 50007 from clients that want to use an FPGA board.
# To install and run this server do the following:
# 1. Install Python 3.6 or later
# 2. run the following command from the root of this repository:
#         > sudo make board_server_install

# To uninstall the server run:
#        > sudo make board_server_uninstall
#
# To check if the server is running run:
#        > sudo make board_server_status

import time
import socket

# Define the server's IP, port and version
# Must match the client's IP and port

HOST = "localhost"  # Listen on all available interfaces
PORT = 50007  # Use a non-privileged port
VERSION = "V0.2"

# user and duration board is needed
USER = ""
DURATION = "300"  # 5 minutes

# Init board status
board_status = "idle"


def get_remaining_time():
    global DURATION
    return str(int(DURATION) - (time.time() - grab_time))


def get_response(request):
    global board_status
    global grab_time
    global USER
    global DURATION

    # check client's version
    if VERSION not in request:
        return "ERROR: Wrong version"

    if get_remaining_time() <= "0.1":
        board_status = "idle"
        USER = ""
        if DEBUG:
            print("Board released due to timeout")

    if request.startswith("query"):
        if board_status == "idle":
            response = "Board is idle"
        else:
            time_remaining = get_remaining_time()
            response = f"Board is grabbed by user {USER} for {time_remaining} seconds"

    elif request.startswith("grab"):
        if board_status == "idle":
            board_status = "grabbed"
            grab_time = time.time()
            USER = request.split()[1]
            DURATION = request.split()[2]
            response = f"Success: board grabbed by {USER} for {DURATION} seconds."
        else:
            time_remaining = get_remaining_time()
            response = f"Failure: board grabbed by {USER} for {time_remaining} seconds."

    elif request.startswith("release"):
        if board_status == "idle":
            response = "ERROR: board already idle."
        elif board_status == "grabbed":
            requesting_user = request.split()[1]
            if requesting_user == USER:
                board_status = "idle"
                USER = ""
                response = "Success: board released."
            else:
                response = (
                    f"ERROR: cannot release board in use by another user ({USER})"
                )

    if DEBUG:
        print(f'Returning response: "{response}"')
    return response


if __name__ == "__main__":
    grab_time = time.time()

    # Create a TCP/IP socket
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((HOST, PORT))
    s.listen()

    # Loop forever
    while True:
        conn, addr = s.accept()
        request = conn.recv(1024).decode("utf-8")
        if DEBUG:
            print(f"Received request: {request}")
            response = get_response(request)
        if DEBUG:
            print(f"Got response: {response}")
            conn.sendall(response.encode("utf-8"))
