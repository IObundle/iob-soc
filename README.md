# IOb-SoC

SoC template containing a RISC-V processor (iob-rv32), a UART (iob-uart), and optional internal and external memory systems.


## Install RISC-V GNU Compiler Toolchain if you have not

###Get sources

```
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
git submodule update --init --recursive
git checkout <stable tag>
git submodule update --init --recursive
```

###Prerequisites

For Ubuntu OS and its variants:

```
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```

For CentOS and its variants:

```
sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk  bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel
```

###Instalation

```
sudo ./configure --prefix=path/to/riscv --enable-multilib
sudo make
```

###Compilation

```
path/to/riscv/riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 <C sources> -o <exec>
```

###Supporting 32-bit applications

Use symbolic links:

```
sudo ln -s riscv64-unknown-elf-gcc riscv32-unknown-elf-gcc
sudo ln -s riscv64-unknown-elf-objcopy riscv32-unknown-elf-objcopy
```

## Update submodules
``git submodule update --init --recursive``


## Edit the system configuration file: rtl/system.mk


## Simulate
```
make sim
```

## Compile FPGA 
```
make fpga
```

## Configure FPGA
```
make conf-fpga
```

## Load Software
```
make ld-sw
```


## Run Software
```
make run-sw
```

## Synthesize ASIC
```
make synth-asic
```

## Place and route ASIC
```
make pr-asic
```
