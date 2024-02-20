import sys
import os
import argparse
import json
import re

from Verilog_VCD import parse_vcd
from Verilog_VCD import get_timescale

busregex = re.compile(r"(.+)\[(\d+)\]")
busregex2 = re.compile(r"(.+)\[(\d):(\d)\]")
config = {}


def replacevalue(wave, strval):
    if "replace" in config and wave in config["replace"]:
        if strval in config["replace"][wave]:
            return config["replace"][wave][strval]
    return strval


def group_buses(vcd_dict, slots):
    buses = {}
    buswidth = {}
    """
    Extract bus name and width
    """
    for isig, wave in enumerate(vcd_dict):
        result = busregex.match(wave)
        if result is not None and len(result.groups()) == 2:
            name = result.group(1)
            pos = int(result.group(2))
            if name not in buses:
                buses[name] = {"name": name, "wave": "", "data": []}
                buswidth[name] = 0
            if pos > buswidth[name]:
                buswidth[name] = pos
    """
    Create hex from bits
    """
    for wave in buses:
        for slot in range(slots):
            if not samplenow(slot):
                continue
            byte = 0
            strval = ""
            for bit in range(buswidth[wave] + 1):
                if bit % 8 == 0 and bit != 0:
                    strval = format(byte, "X") + strval
                    byte = 0
                val = vcd_dict[wave + "[" + str(bit) + "]"][slot][1]
                if val != "0" and val != "1":
                    byte = -1
                    break
                byte += pow(2, bit % 8) * int(val)
            strval = format(byte, "X") + strval
            if byte == -1:
                buses[wave]["wave"] += "x"
            else:
                strval = replacevalue(wave, strval)
                if len(buses[wave]["data"]) > 0 and buses[wave]["data"][-1] == strval:
                    buses[wave]["wave"] += "."
                else:
                    buses[wave]["wave"] += "="
                    buses[wave]["data"].append(strval)
    return buses


def homogenize_waves(vcd_dict, timescale):
    slots = int(config["maxtime"] / timescale) + 1
    for isig, wave in enumerate(vcd_dict):
        lastval = "x"
        for tidx, t in enumerate(range(0, config["maxtime"] + timescale, timescale)):
            if len(vcd_dict[wave]) > tidx:
                newtime = vcd_dict[wave][tidx][0]
            else:
                newtime = t + 1
            if newtime != t:
                for ito_padd, padd in enumerate(range(t, newtime, timescale)):
                    vcd_dict[wave].insert(tidx + ito_padd, (padd, lastval))
            else:
                lastval = vcd_dict[wave][tidx][1]
        vcd_dict[wave] = vcd_dict[wave][0:slots]


def includewave(wave):
    if "__all__" in config["filter"] or wave in config["filter"]:
        return True
    return False


def clockvalue(wave, digit):
    if wave in config["clocks"] and digit == "1":
        return "P"
    return digit


def samplenow(tick):
    offset = 0
    if "offset" in config:
        offset = config["offset"]

    samplerate = 1
    if "samplerate" in config:
        samplerate = config["samplerate"]

    if ((tick - offset) % samplerate) == 0:
        return True
    return False


def appendconfig(wave):
    wavename = wave["name"]
    if wavename in config["signal"]:
        wave.update(config["signal"][wavename])


def dump_wavedrom(vcd_dict, timescale):
    drom = {"signal": [], "config": {"hscale": 1}}
    slots = int(config["maxtime"] / timescale)
    buses = group_buses(vcd_dict, slots)
    """
    Replace old signals that were grouped
    """
    for bus in buses:
        pattern = re.compile(r"^" + re.escape(bus) + "\\[.*")
        for wave in list(vcd_dict.keys()):
            if pattern.match(wave) is not None:
                del vcd_dict[wave]
    """
    Create waveforms for the rest of the signals
    """
    idromsig = 0
    for wave in vcd_dict:
        if not includewave(wave):
            continue
        drom["signal"].append({"name": wave, "wave": "", "data": []})
        lastval = ""
        isbus = busregex2.match(wave) is not None
        for j in vcd_dict[wave]:
            if not samplenow(j[0]):
                continue
            digit = "."
            if isbus:
                if lastval != j[1]:
                    digit = "="
                if "x" not in j[1]:
                    drom["signal"][idromsig]["data"].append(format(int(j[1], 2), "X"))
                else:
                    digit = "x"
            else:
                j = (j[0], clockvalue(wave, j[1]))
                if lastval != j[1]:
                    digit = j[1]
            drom["signal"][idromsig]["wave"] += digit
            lastval = j[1]
        idromsig += 1

    """
    Insert buses waveforms
    """
    for bus in buses:
        if not includewave(bus):
            continue
        drom["signal"].append(buses[bus])

    """
    Order per config and add extra user parameters
    """
    ordered = []
    for filtered in config["filter"]:
        for wave in drom["signal"]:
            if wave["name"] == filtered:
                ordered.append(wave)
                appendconfig(wave)
    drom["signal"] = ordered
    if "hscale" in config:
        drom["config"]["hscale"] = config["hscale"]

    """
    Print the result
    """
    if config["output"]:
        f = open(config["output"], "w")
        f.write(json.dumps(drom, indent=4))
    else:
        print(json.dumps(drom, indent=4))


def vcd2wavedrom():
    vcd = parse_vcd(config["input"])
    timescale = int(re.match(r"(\d+)", get_timescale()).group(1))
    vcd_dict = {}
    for i in vcd:
        vcd_dict[vcd[i]["nets"][0]["hier"] + "." + vcd[i]["nets"][0]["name"]] = vcd[i][
            "tv"
        ]

    homogenize_waves(vcd_dict, timescale)
    dump_wavedrom(vcd_dict, timescale)


def main(argv):
    parser = argparse.ArgumentParser(description="Transform VCD to wavedrom")
    parser.add_argument("--config", dest="configfile", required=True)
    parser.add_argument("--input", nargs="?", dest="input", required=True)
    parser.add_argument("--output", nargs="?", dest="output", required=False)

    args = parser.parse_args(argv)
    args.input = os.path.abspath(os.path.join(os.getcwd(), args.input))

    with open(args.configfile) as json_file:
        config.update(json.load(json_file))

    config["input"] = args.input
    config["output"] = args.output
    vcd2wavedrom()


if __name__ == "__main__":
    main(sys.argv[1:])
