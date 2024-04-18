from dataclasses import dataclass

from iob_base import fail_with_msg


@dataclass
class iob_signal:
    """Class that represents a wire/port signal"""

    name: str = ""
    width: str or int = 1
    descr: str = "Default description"

    # Only used when signal belongs to a port
    direction: str = ""

    def __post_init__(self):
        if not self.name:
            fail_with_msg("Signal name is not set", ValueError)

        if self.direction not in ["", "input", "output", "inout"]:
            fail_with_msg(f"Invalid signal direction: '{self.direction}'", ValueError)


@dataclass
class iob_signal_reference:
    """Class that references another signal
    Use to distinguish from a real signal (for generator scripts)
    """

    signal: iob_signal | None = None
