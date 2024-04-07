#
#    blocks.py: instantiate Verilog modules and generate their documentation
#

from latex import write_table

import iob_colors
from iob_port import get_signal_name_with_dir_suffix
from iob_wire import get_real_signal
import if_gen


# Generate blocks.tex file with TeX table of blocks (Verilog modules instances)
def generate_blocks_table_tex(out_dir):
    blocks_file = open(f"{out_dir}/blocks.tex", "w")

    blocks_file.write(
        "The Verilog modules in the top-level entity of the core are \
        described in the following table. The table elements represent \
        the blocks in the Block Diagram.\n"
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


def generate_blocks(core):
    """Generate Verilog instances of core"""
    out_dir = core.build_dir + "/hardware/src"

    f_blocks = open(f"{out_dir}/{core.name}_blocks.vs", "w+")

    for instance in core.blocks:
        # Open ifdef if conditional interface
        if instance.if_defined:
            f_blocks.write(f"`ifdef {core.name.upper()}_{instance.if_defined}\n")

        f_blocks.write(
            f"""\
    {instance.name} #(
        `include "{instance.instance_name}_inst_params.vs"
    ) {instance.instance_name} (
{get_instance_port_connections(instance)}
    );

"""
        )

        # Close ifdef if conditional interface
        if instance.if_defined:
            f_blocks.write("`endif\n")

    f_blocks.close()


def get_instance_port_connections(instance):
    """Returns a multi-line string with all port's signals connections
    for the given Verilog instance.
    """
    instance_portmap = ""
    for port_idx, port in enumerate(instance.ports):
        assert (
            port.e_connect
        ), f"{iob_colors.FAIL}Port '{port.name}' of instance '{instance.name}' is not connected!{iob_colors.ENDC}"
        instance_portmap += f"        // {port.name} port\n"
        # Connect individual signals
        for idx, signal in enumerate(port.signals):
            port_name = get_signal_name_with_dir_suffix(signal)
            real_e_signal = get_real_signal(port.e_connect.signals[idx])
            if real_e_signal.direction:
                # External signal belongs to a port. Use direction suffix.
                e_signal_name = get_signal_name_with_dir_suffix(real_e_signal)
            else:
                e_signal_name = real_e_signal.name

            comma = (
                ","
                if (
                    (port_idx < len(instance.ports) - 1)
                    or (idx < len(port.signals) - 1)
                )
                else ""
            )
            instance_portmap += f"        .{port_name}({e_signal_name}){comma}\n"

    return instance_portmap
