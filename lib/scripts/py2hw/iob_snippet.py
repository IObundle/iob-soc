from dataclasses import dataclass, field
from typing import List


@dataclass
class iob_snippet:
    """Class to represent a Verilog snippet in an iob module"""

    # List of outputs of this snippet (use to generate global wires)
    outputs: List[str] = field(default_factory=list)
    verilog_code: str = ""


def create_snippet(core, *args, **kwargs):
    """Create a Verilog snippet to insert in given core."""
    # Ensure 'snippets' list exists
    core.set_default_attribute("snippets", [])
    snippet = iob_snippet(*args, **kwargs)
    core.snippets.append(snippet)
