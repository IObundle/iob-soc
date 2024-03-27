#
#    blocks.py: instantiate Verilog modules and generate their documentation
#

from latex import write_table


# Generate blocks.tex file with TeX table of blocks (Verilog modules instances)
def generate_blocks_table_tex(out_dir):
    blocks_file = open(f"{out_dir}/blocks.tex", "w")

    blocks_file.write(
        "The Verilog modules in the top-level entity of the core are described in the \
    following table. The table elements represent the blocks in the \
    Block Diagram.\n"
    )

    blocks_file.write(
        """
\\begin{table}[H]
  \\centering
  \\begin{tabularx}{\\textwidth}{|l|X|}

    \\hline
    \\rowcolor{iob-green}
    {\\bf Name} & {\\bf Description}  \\\\ \\hline \\hline

    \\input blocks_module_tab

  \\end{tabularx}
  \\caption{Verilog modules in the top-level entity of the core}
  \\label{blocks_module_tab:is}
\\end{table}
"""
    )

    blocks_file.write("\\clearpage")
    blocks_file.close()


# Generate TeX table of blocks
def generate_blocks_tex(blocks, out_dir):
    # Create blocks.tex file
    generate_blocks_table_tex(out_dir)

    tex_table = []
    for block in blocks:
        tex_table.append(
            [
                block.name,
                block.description,
            ]
        )

    write_table(f"{out_dir}/blocks_module", tex_table)
