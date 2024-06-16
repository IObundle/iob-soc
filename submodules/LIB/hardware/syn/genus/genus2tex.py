#!/usr/bin/env python3

import sys
import os
import subprocess
import math

#
# File names
#
gates_rpt = "gates.rpt"
timing_rpt = "timing.rpt"
output_file = "asic.tex"

#
# Variables
#
area = 0  # um^2
nands = 0
nands_area = 0  # um^2
ffs = 0
per = 0  # ns
slack = 0  # ns
gates = 0
freq = 0  # MHz

#
# Functions
#


def run_command(command):
    res = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True
    )
    return res.stdout.decode("utf-8")


def process_reports():
    global area, nands, nands_area, ffs, per, slack

    # Process gates report
    if not os.path.exists(gates_rpt):
        return -1
    area = float(run_command("grep -m1 'total' " + gates_rpt + " | awk '{print $3}'"))
    nands = int(run_command("grep -m1 'ND2CLD' " + gates_rpt + " | awk '{print $2}'"))
    nands_area = float(
        run_command("grep -m1 'ND2CLD' " + gates_rpt + " | awk '{print $3}'")
    )
    ffs = int(run_command("grep -m1 'sequential' " + gates_rpt + " | awk '{print $2}'"))

    # Process timing report
    if not os.path.exists(timing_rpt):
        return -1
    per = int(run_command("grep -m1 'capture' " + timing_rpt + " | awk '{print $4}'"))
    slack = int(
        run_command(
            "grep -m1 'slack' " + timing_rpt + " | awk '{print $4}' | grep -o '[^a-z]*'"
        )
    )

    return 0


def generate_output_file():
    fw = open(output_file, "w")
    fw.write(
        str(area)
        + " & "
        + str(gates)
        + " & "
        + str(ffs)
        + " & "
        + "{0:.5g}".format(freq)
        + "\\\\ \\hline"
    )
    fw.close()
    return


def run():
    global gates, freq
    ret = -1

    # Get data from reports
    ret = process_reports()

    # Compute number of gates
    gates = int(math.ceil((area / (nands_area / nands))))

    # Compute clock frequency
    freq = 1e6 / (per - slack)

    generate_output_file()

    return ret


def main():
    ret = -1

    ret = run()

    sys.exit(ret)


if __name__ == "__main__":
    main()
