#
#    blocks.py: instantiate Verilog modules and generate their documentation
#

from latex import write_table

# Generate blocks.tex file with list TeX tables of blocks (Verilog modules instances)
def generate_blocks_list_tex(block_groups, out_dir):
    blocks_file = open(f"{out_dir}/blocks.tex", "w")

    blocks_file.write(
        "The Verilog modules in the top-level entity of the core are described in the \
    following tables. Each table represents a major block or block group in the \
    Block Diagram, and contains a description of each of the sub-blocks.\n"
    )

    for block_group in block_groups:
        blocks_file.write(
            """
\\begin{table}[H]
  \centering
  \\begin{tabularx}{\\textwidth}{|l|X|}
    
    \\hline
    \\rowcolor{iob-green}
    {\\bf Name} & {\\bf Description}  \\\\ \\hline \\hline

    \\input """
            + block_group.name
            + """_module_tab
 
  \\end{tabularx}
  \\caption{"""
            + block_group.description
            + """}
  \\label{"""
            + block_group.name
            + """_module_tab:is}
\\end{table}
"""
        )

    blocks_file.write("\clearpage")
    blocks_file.close()


# Generate TeX tables of blocks
def generate_blocks_tex(block_groups, out_dir):
    # Create blocks.tex file
    generate_blocks_list_tex(block_groups, out_dir)

    for block_group in block_groups:
        tex_table = []
        for instance in block_group.blocks:
            tex_table.append(
                [
                    instance.name,
                    instance.description,
                ]
            )

        write_table(f"{out_dir}/{block_group.name}_module", tex_table)

