#
#    doc_gen.py: generate documentation
#

import config_gen
import io_gen
import block_gen


def generate_docs(core, csr_gen_obj, reg_table):
    """Generate common documentation files"""
    if core.is_top_module:
        config_gen.generate_confs_tex(core.confs, core.build_dir + "/doc/tsrc")
        io_gen.generate_ios_tex(core.ports, core.build_dir + "/doc/tsrc")
        if core.csrs:
            csr_gen_obj.generate_regs_tex(
                core.csrs, reg_table, core.build_dir + "/doc/tsrc"
            )
        block_gen.generate_blocks_tex(core.blocks, core.build_dir + "/doc/tsrc")
