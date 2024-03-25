from dataclasses import dataclass
from typing import Dict, List


@dataclass
class iob_conf:
    name: str
    type: str
    val: str
    min: str = 0
    max: str = 1
    description: str = "Default description"

    def __post_init__(self):
        if not self.name:
            raise Exception("Conf name is required")
        if not self.type:
            raise Exception("Conf type is required")
        elif self.type not in ["M", "P", "F"]:
            raise Exception("Conf type must be either M, P or F")


def create_conf(core, *args, **kwargs):
    """Creates a new conf object and adds it to the core's conf list
    param core: core object
    """
    # Ensure 'confs' list exists
    core.set_default_attribute("confs", [])
    conf = iob_conf(*args, **kwargs)
    core.confs.append(conf)
