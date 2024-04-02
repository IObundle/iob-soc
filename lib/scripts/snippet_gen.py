#!/usr/bin/env python3


def generate_snippets(core):
    out_dir = core.build_dir + "/hardware/src"

    f_snippets = open(f"{out_dir}/{core.name}_snippets.vs", "w+")

    for snippet in core.snippets:
        f_snippets.write(snippet.verilog_code)
        f_snippets.write("\n")

    f_snippets.close()
