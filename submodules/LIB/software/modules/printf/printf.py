import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()


class printf(iob_module):
    name = "printf"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)


if __name__ == "__main__":
    printf.setup_as_top_module()
