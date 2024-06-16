#!/usr/bin/env python3
# Script with LaTeX related functions

"""
Write Latex table
"""


def write_table(outfile, table):
    fout = open(outfile + "_tab.tex", "w")
    for i in range(len(table)):
        if (i % 2) != 0:
            fout.write("\\rowcolor{iob-blue}\n")
        line = table[i]
        # replace underscores and $clog2 with \_ and $\log_2
        for j in range(len(line)):
            line[j] = line[j].replace("_", "\\_")
            line[j] = line[j].replace("$clog2", "log2")
        # if one of the elements has matching parenthesis, remove the enclosing ones
        for j in range(len(line)):
            if line[j].count("(") == line[j].count(")") and line[j].count("(") > 0:
                if line[j][0] == "(" and line[j][-1] == ")":
                    line[j] = line[j][1:-1]
        # Assemble the line
        line_out = str(line[0])
        for l in range(1, len(line)):
            line_out = line_out + (" & %s" % line[l])
        # Write the line
        fout.write(line_out + " \\\\ \\hline\n")

    fout.close()
    return


"""
Write Latex description
"""


def write_description(outfile, text):
    fout = open(outfile + "_desc.tex", "w")
    for line in text:
        fout.write("\\item[" + line[0] + "] " + "{" + line[1] + "}\n")
    fout.close()
