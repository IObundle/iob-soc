#!/usr/bin/env python3
# Joins two hex files, one starting at address 0 and one starting at address TOTALSIZE/2

from sys import argv
import os

total_number_of_lines = 2 ** (int(argv[3]) - 2)

if os.path.isfile(argv[1]):
    with open(argv[1], "r") as f:
        file1_contents = f.readlines()
else:
    file1_contents = []


if os.path.isfile(argv[2]):
    with open(argv[2], "r") as f:
        file2_contents = f.readlines()
else:
    file2_contents = []


# Trim lines of zeros from end of file
def trimEndingZeros(data):
    data_size = len(data)
    for j in reversed(range(data_size)):
        if data[j] == "00000000\n":
            data.pop(j)
        else:
            break
    return data


file1_contents = trimEndingZeros(file1_contents)
file2_contents = trimEndingZeros(file2_contents)

# Check that we can join two hex files, without exceding range
if (
    len(file1_contents) > total_number_of_lines / 2
    or len(file2_contents) > total_number_of_lines / 2
):
    raise Exception(
        "Can't fit both hexfile contents in a new hexfile of size {}".format(argv[3])
    )

# Print first half of desired hex file
for i in range(len(file1_contents)):
    print(file1_contents[i], end="")
for i in range(int(total_number_of_lines / 2) - len(file1_contents)):
    print("00000000")
# Print second half of desired hex file
for i in range(len(file2_contents)):
    print(file2_contents[i], end="")
for i in range(int(total_number_of_lines / 2) - len(file2_contents)):
    print("00000000")
