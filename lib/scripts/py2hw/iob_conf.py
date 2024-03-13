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
