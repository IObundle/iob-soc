<!--
SPDX-FileCopyrightText: 2024 IObundle

SPDX-License-Identifier: MIT
-->

# iob-lib
This repository contains a set of Python scripts, Verilog, and C sources to
simplify the development of subsystem IP cores.

It is used as a submodule in the [IOb-SoC](https://github.com/IObundle/iob-soc)
RISC-V-based SoC, and associated projects.

## Code Style
#### Python Code
[![Recommended python code style:
black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
- Python format workflow:
    - install [black](https://black.readthedocs.io/en/stable/)
    - run black manually:
        - `make python-format` or `./scripts/sw_format.py black`
    - (optional): [integrate with your preferred
      IDE](https://black.readthedocs.io/en/stable/integrations/editors.html)
    - black formatting for other repositories:
        - call `sw_format.py black` script in LIB submodule from the repository
          top level:
        ```make
        # repository top level Makefile
        format:
           @./lib/scripts/sw_format.py black
        ```
#### C/C++ Code
- Recommended C/C++ code style: [LLVM](https://llvm.org/docs/CodingStandards.html)
- C/C++ format workflow:
    - install [clang-format](https://black.readthedocs.io/en/stable/)
    - run clang-format manually:
        - `make c-format` or `./scripts/sw_format.py clang`
    - (optional) [integrate with your preferred
      IDE](https://clang.llvm.org/docs/ClangFormat.html#vim-integration)
    - C/C++ formatting for other repositories:
        - copy `.clang-format` to new repository top level
        - call `sw_format.py clang` script in LIB submodule from the repository
          top level:
        ```make
        # repository top level Makefile
        format:
           @./lib/scripts/sw_format.py clang
        ```

## Tests
Currently tests are automated for the memory modules in the `test.mk` makefile.
Run tests for all memory modules with the command: 
```
make -f test.mk test
```

## How to use Nix
Instead of manually installing the dependencies for each IObundle repository project, you can use [nix-shell](https://nixos.org/manual/nix/stable/command-ref/nix-shell.html). This allows you to run your project in a [Nix](https://nixos.org/) environment with all dependencies available except for Vivado and Quartus. The packages installed by the `nix-shell` are defined in [`scripts/default.nix`](https://github.com/IObundle/iob-lib/blob/python-setup/scripts/default.nix).

To [install Nix](https://nixos.org/download.html#nix-install-linux) the recommended command is:
- `sh <(curl -L https://nixos.org/nix/install) --daemon`

Then, in the repository you can run `nix-shell` from the root directory to install the required packages.

To delete all the unused old Nix packages you can run: `nix-collect-garbage -d`. It is recommended to run it inside the nix-shell environment currently used to prevent deleting packages commonly used and having to install them again.
