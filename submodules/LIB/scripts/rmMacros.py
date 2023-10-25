#!/usr/bin/env python3
#
# r m M a c r o s
#

import argparse
import sys
import os
import fnmatch

lookUpTable = {}


def processLine(line):
    newLine = line

    # Remove tabs
    line = line.replace("\t", "")
    # Remove breakline characters
    line = line.replace("\r", "")
    line = line.replace("\n", "")
    # Remove comments
    if line.find("//") + 1:
        line = line[: line.find("//")]

    mi = line.find("`IOB_")
    lpi = line.find("(")
    macro = line[mi + 1 : lpi]
    if macro in lookUpTable:
        rpi = line.rfind(")")

        old = line[mi : rpi + 1]
        new = lookUpTable[macro]["rule"]

        parts = line[lpi + 1 : rpi].replace(" ", "").split(",")
        for i in range(len(parts)):
            new = new.replace(lookUpTable[macro]["args"][i], parts[i])
        newLine = newLine.replace(old, new)

    return newLine


def processFile(inputFile, outputFile):
    fout = open(outputFile, "w")

    fin = open(inputFile, "r")
    for line in fin:
        res = processLine(line)
        fout.write(res)

    fin.close()
    fout.close()

    return 0


def processMacro(line):
    name = ""
    args = []
    rule = ""

    # Remove tabs
    line = line.replace("\t", "")
    # Remove breakline characters
    line = line.replace("\r", "")
    line = line.replace("\n", "")

    di = line.find("define")
    found = di + 1
    if found:
        lpi = line.find("(")
        rpi = line.find(")")

        name = line[di + 7 : lpi]
        args = line[lpi + 1 : rpi].replace(" ", "").split(",")
        rule = line[rpi + 2 :]

    return [name, {"args": args, "rule": rule}]


def loadMacros(macroFile):
    global lookUpTable

    fmacro = open(macroFile, "r")
    for line in fmacro:
        res = processMacro(line)
        if res[0] != "":
            lookUpTable[res[0]] = res[1]
    fmacro.close()

    return


def find(pattern, path):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            if fnmatch.fnmatch(name, pattern):
                result.append(os.path.join(root, name))
    return result


def replaceFiles(extension, path):
    files = find("*" + extension, path)

    for inputFile in files:
        ei = inputFile.rfind(".")
        outputFile = inputFile[0:ei] + "_tmp." + inputFile[ei + 1 :]
        res = processFile(inputFile, outputFile)
        os.system("mv " + outputFile + " " + inputFile)

    return


def parse_arguments():
    parser = argparse.ArgumentParser(
        prog="rmMacros.py", description="""Macro replacer script."""
    )
    parser.add_argument("-i", "--input", required=True, help="macros file")
    parser.add_argument(
        "-p",
        "--path",
        required=True,
        help="path to directory of files to replace macros",
    )
    parser.add_argument(
        "-e", "--extension", required=True, help="target files extension"
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_arguments()

    loadMacros(args.input)
    replaceFiles(args.extension, args.path)

    sys.exit(0)
