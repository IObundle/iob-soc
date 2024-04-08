from dataclasses import dataclass, field

from iob_base import convert_dict2obj_list, fail_with_msg


@dataclass
class iob_csr:
    """Class to represent a Control/Status Register."""

    name: str = ""
    type: str = ""
    n_bits: str or int = 1
    rst_val: int = 0
    addr: int = -1
    log2n_items: int = 0
    autoreg: bool = True
    descr: str = "Default description"

    def __post_init__(self):
        if not self.name:
            fail_with_msg("CSR name is not set", ValueError)

        if self.type not in ["R", "W", "RW"]:
            fail_with_msg(f"Invalid CSR type: '{self.type}'", ValueError)


@dataclass
class iob_csr_group:
    """Class to represent a Control/Status Register group."""

    name: str = ""
    descr: str = "Default description"
    regs: list = field(default_factory=list)

    def __post_init__(self):
        if not self.name:
            fail_with_msg("CSR group name is not set", ValueError)


def create_csr_group(core, *args, regs=[], **kwargs):
    """Creates a new csr group object and adds it to the core's csr list
    param core: core object
    """
    # Ensure 'csrs' list exists
    core.set_default_attribute("csrs", [])
    # Convert user reg dictionaries into 'iob_csr' objects
    csr_obj_list = convert_dict2obj_list(regs, iob_csr)
    csr_group = iob_csr_group(*args, regs=csr_obj_list, **kwargs)
    core.csrs.append(csr_group)
