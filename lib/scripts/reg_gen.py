#
#    reg_gen.py: build register files
#

import os

import copy_srcs
import csr_gen


def auto_add_reg_settings(core):
    """Auto-add settings like macros and submodules to the module"""

    # Auto-add VERSION macro if there are software registers
    if core.regs:
        found_version_macro = False
        if core.confs:
            for macro in core.confs:
                if macro["name"] == "VERSION":
                    found_version_macro = True
        if not found_version_macro:
            core.confs.append(
                {
                    "name": "VERSION",
                    "type": "M",
                    "val": "16'h" + copy_srcs.version_str_to_digits(core.version),
                    "min": "NA",
                    "max": "NA",
                    "descr": "Product version. This 16-bit macro uses nibbles to represent decimal numbers using their binary values. The two most significant nibbles represent the integral part of the version, and the two least significant nibbles represent the decimal part. For example V12.34 is represented by 0x1234.",
                }
            )

        # Auto-add iob_ctls module, except if use_netlist
        if core.name != "iob_ctls" and not core.use_netlist:
            from iob_ctls import iob_ctls

            iob_ctls()._setup(
                is_top=False,
                purpose=core.purpose,
                topdir=f"{core.build_dir}",
            )


def build_regs_table(core):
    """Build registers table.
    :returns csr_gen csr_gen_obj: Instance of csr_gen class
    :returns list reg_table: Register table generated by `get_reg_table` method of `csr_gen_obj`
    """
    # Don't create regs table if module does not have regs
    if not core.regs:
        return None, None

    # Make sure 'general' registers table exists
    general_regs_table = next((i for i in core.regs if i["name"] == "general"), None)
    if not general_regs_table:
        general_regs_table = {
            "name": "general",
            "descr": "General Registers.",
            "regs": [],
        }
        core.regs.append(general_regs_table)

    # Add 'VERSION' register if it does not have one
    if not next(
        (i for i in general_regs_table["regs"] if i["name"] == "VERSION"), None
    ):
        general_regs_table["regs"].append(
            {
                "name": "VERSION",
                "type": "R",
                "n_bits": 16,
                "rst_val": copy_srcs.version_str_to_digits(core.version),
                "addr": -1,
                "log2n_items": 0,
                "autoreg": True,
                "descr": "Product version.  This 16-bit register uses nibbles to represent decimal numbers using their binary values. The two most significant nibbles represent the integral part of the version, and the two least significant nibbles represent the decimal part. For example V12.34 is represented by 0x1234.",
            }
        )

    # Create an instance of the csr_gen class inside the csr_gen module
    # This instance is only used locally, not affecting status of csr_gen imported in other functions/modules
    csr_gen_obj = csr_gen.csr_gen()
    csr_gen_obj.config = core.confs
    # Get register table
    reg_table = csr_gen_obj.get_reg_table(core.regs, core.rw_overlap, core.autoaddr)

    return csr_gen_obj, reg_table


def generate_reg_hw(core, csr_gen_obj, reg_table):
    """Generate reg hardware files"""
    if core.regs:
        csr_gen_obj.write_hwheader(
            reg_table, core.build_dir + "/hardware/src", core.name
        )
        csr_gen_obj.write_lparam_header(
            reg_table, core.build_dir + "/hardware/simulation/src", core.name
        )
        if not core.use_netlist:
            csr_gen_obj.write_hwcode(
                reg_table,
                core.build_dir + "/hardware/src",
                core.name,
                core.csr_if,
            )


def generate_reg_sw(core, csr_gen_obj, reg_table):
    """Generate reg software files"""
    if core.is_system or core.regs:
        os.makedirs(core.build_dir + "/software/src", exist_ok=True)
        if core.regs:
            csr_gen_obj.write_swheader(
                reg_table, core.build_dir + "/software/src", core.name
            )
            csr_gen_obj.write_swcode(
                reg_table, core.build_dir + "/software/src", core.name
            )
            csr_gen_obj.write_swheader(
                reg_table, core.build_dir + "/software/src", core.name
            )


def generate_csr(core):
    """Generate hw, sw and doc files"""
    csr_gen_obj, reg_table = build_regs_table(core)
    generate_reg_hw(core, csr_gen_obj, reg_table)
    generate_reg_sw(core, csr_gen_obj, reg_table)
    auto_add_reg_settings(core)
    return csr_gen_obj, reg_table