#!/usr/bin/env python3
#
#    ios.py: build Verilog module IO and documentation
#

from latex import write_table
import if_gen
import os


def reverse_port(port_type):
    if port_type == "input":
        return "output"
    else:
        return "input"


def delete_last_comma(file_obj):
    # Place cursor at the end of the file
    file_obj.read()

    while True:
        # Search for start of line (previous \n) or start of file
        # (It is better than just searching for the comma, because there may be verilog comments in this line with commas that we dont want to remove)
        while file_obj.read(1) != "\n" and file_obj.tell() > 1:
            file_obj.seek(file_obj.tell() - 2)
        # Return if we are at the start of the file (didnt find any comma)
        if file_obj.tell() < 2:
            return
        # Ignore lines starting with Verilog macro
        if file_obj.read(1) != "`":
            file_obj.seek(file_obj.tell() - 1)
            break
        # Move cursor 3 chars back (skip "`", "\n" and previous char)
        file_obj.seek(file_obj.tell() - 3)

    # Search for next comma
    while file_obj.read(1) != ",":
        pass
    file_obj.seek(file_obj.tell() - 1)
    # Delete comma
    file_obj.write(" ")


def generate_ports(core):
    out_dir = core.build_dir + "/hardware/src"

    f_io = open(f"{out_dir}/{core.name}_io.vs", "w+")

    for table in core.ios:

        # print(table)

        # If table has 'doc_only' attribute set to True, skip it
        if "doc_only" in table.keys() and table["doc_only"]:
            continue

        # Open ifdef if conditional interface
        if "if_defined" in table.keys():
            f_io.write(f"`ifdef {core.name.upper()}_{table['if_defined']}\n")

        if "file_prefix" in table.keys():
            file_prefix = table["file_prefix"]
        else:
            file_prefix = table["port_prefix"] + table["wire_prefix"]

        if_gen.gen_if(
            table["name"],
            file_prefix,
            table["port_prefix"],
            table["wire_prefix"],
            table["ports"],
            table["mult"] if "mult" in table.keys() else 1,
            table["widths"] if "widths" in table.keys() else {},
        )

        # append vs_file to io.vs
        if table["type"] == "slave":
            infix = "s"
        else:
            infix = "m"
        vs_file = open(f"{file_prefix}{table['name']}_{infix}_port.vs", "r")
        f_io.write(vs_file.read())

        # move all .vs files from current directory to out_dir
        for file in os.listdir("."):
            if file.endswith(".vs"):
                os.rename(file, f"{out_dir}/{file}")

        # Close ifdef if conditional interface
        if "if_defined" in table.keys():
            f_io.write("`endif\n")

    # Find and remove last comma
    delete_last_comma(f_io)


# Generate if.tex file with list TeX tables of IOs
def generate_if_tex(ios, out_dir):
    if_file = open(f"{out_dir}/if.tex", "w")

    if_file.write(
        "The interface signals of the core are described in the following tables.\n"
    )

    for table in ios:
        if_file.write(
            """
\\begin{table}[H]
  \centering
  \\begin{tabularx}{\\textwidth}{|l|l|r|X|}
    
    \hline
    \\rowcolor{iob-green}
    {\\bf Name} & {\\bf Direction} & {\\bf Width} & {\\bf Description}  \\\\ \hline \hline

    \input """
            + table["name"]
            + """_if_tab
 
  \end{tabularx}
  \caption{"""
            + table["descr"].replace("_", "\_")
            + """}
  \label{"""
            + table["name"]
            + """_if_tab:is}
\end{table}
"""
        )

    if_file.write("\clearpage")
    if_file.close()


# Generate TeX tables of IOs
def generate_ios_tex(ios, out_dir):
    # Create if.tex file
    generate_if_tex(ios, out_dir)

    for table in ios:
        tex_table = []
        # Check if this table is a standard interface (from if_gen.py)
        if_name = table["name"]
        if if_name in if_gen.if_names:
            # Interface is standard, generate ports
            eval_str = f"if_gen.get_{if_name}_ports()"
            if_table = eval(eval_str)

            for port in if_table:
                port_direction = port["direction"]
                # reverse direction if port is a slave port
                if table["type"] == "slave":
                    port_direction = reverse_port(port_direction)

                tex_table.append(
                    [
                        (port["name"] + if_gen.get_suffix(port_direction)),
                        port_direction,
                        port["width"],
                        port["descr"],
                    ]
                )
        else:
            # Interface is not standard, read ports
            for port in table["ports"]:
                tex_table.append(
                    [
                        port["name"],
                        port["direction"],
                        port["width"],
                        port["descr"],
                    ]
                )

        write_table(f"{out_dir}/{table['name']}_if", tex_table)
