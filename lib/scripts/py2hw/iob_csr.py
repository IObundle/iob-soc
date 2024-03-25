from dataclasses import dataclass


@dataclass
class iob_csr:
    """Describes a Control/Status Register."""

    # TODO


def create_csr(core, *args, **kwargs):
    """Creates a new csr object and adds it to the core's csr list
    param core: core object
    """
    # Ensure 'csrs' list exists
    core.set_default_attribute("csrs", [])
    csr = iob_csr(*args, **kwargs)
    core.csrs.append(csr)
