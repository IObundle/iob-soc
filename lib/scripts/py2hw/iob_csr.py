from dataclasses import dataclass, field

from iob_base import fail_with_msg


@dataclass
class iob_csr_group:
    """Class to represent a Control/Status Register group."""

    name: str = ""
    descr: str = "Default description"
    regs: list = field(default_factory=list)

    def __post_init__(self):
        if not self.name:
            fail_with_msg("CSR group name is not set", ValueError)

        if not self.regs:
            fail_with_msg("CSR group regs list is empty", ValueError)


def create_csr_group(core, *args, **kwargs):
    """Creates a new csr group object and adds it to the core's csr list
    param core: core object
    """
    # Ensure 'csrs' list exists
    core.set_default_attribute("csrs", [])
    csr_group = iob_csr_group(*args, **kwargs)
    core.csrs.append(csr_group)
