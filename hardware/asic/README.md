# ASIC IMPLEMENTATION INSTRUCTIONS

## OpenLane Instructions 
## Installation of Openlane and Skywater PDK 130

Minimal requirements for OpenLane:
1.  Docker 19.03.12+
2.  GNU make
3.  Python 3.6+ with PIP
4.  Click, Pyyaml 

Clone OpenLane repository with Skywater PDK 130 using *ssh*

```bash
git clone git@github.com:efabless/OpenLane.git
```

or using *https*;
```bash
git clone https://github.com/efabless/OpenLane.git
```

The default Standard Cell Library (SCL) to be installed is sky130_fd_sc_hd. To
change that, you can add this configuration variable: 

```bash
export STD_CELL_LIBRARY=<library name>
```

where library name is one of the following:
1.  sky130_fd_sc_hd
2.  sky130_fd_sc_hs
3.  sky130_fd_sc_ms
4.  sky130_fd_sc_ls
5.  sky130_fd_sc_hdll

To run OpenLane, export following environment variables:

```bash
export OPENLANE_HOME=path/to/OpenLane/root
export PDK_ROOT=$OPENLANE_HOME/pdks
```

For installation of Skywater PDK and OpenLane, type the following:
```bash
cd path/to/OpenLane/root
make
```

This will clone the specific version of Skywater PDK, pull and build its Docker
container. If everything is properly installed, it will report success. To test
the OpenLane flow and PDK installation, run

```bash
make test
```

This runs a test design flow that verifies the OpenLane and Skywater PDK
installations, and reports success if everything has been successfully
installed.

**NOTE**: If mounting *docker* is requiring sudo access, then follow these
steps:

1. First create the docker group, if it is not already there.
```bash
sudo groupadd docker
```
2. Add the user to the docker group
```bash
sudo usermod -aG docker $USER
```
3. Log out and log back in so that your group membership is re-evaluated.On
   Ubuntu machine logout completely from the session and login again in order to
   allow changes to take effect. On the Ubuntu machine you can also run
   following command to activate the changes to groups.

```bash
newgrp docker
```
4. Verify that you can run docker commands without sudo by running docker
```bash
 docker run -name test -d efabless/openlane:2021.07.29_04.49.46
```
This image and tag are cloned when you give the "make" command in OpenLane root
directory.You can also clone the latest tag for the efabless/openlane image.
## OPENLANE FLOW FOR MACRO HARDENING FROM AN HDL DESIGN

1. Start the OpenLane Docker container by running 

```bash
cd $OPENLANE_HOME
make mount
```

This command will mount the docker container and open a bash terminal in which
you run the following tcl file to generate a default configuration file for
OpenLane flow:

```bash
./flow.tcl -design design_name -init_design_config 
```

2.  The default configuration file "config.tcl" has following environment
    variables:

* DESIGN_NAME: the name of your design must match the name of your top-level
  Verilog module. This variable cannot be modified.

* VERILOG_FILES: this environment variable points to a directory containing and
  lists all your Verilog files. By default it is set to DESIGN_DIR/src/*.v,
  where DESIGN_DIR is the "$OPENLANE_HOME/designs/design_name" directory

* CLOCK_PERIOD: clock signal period. Change this according to your design.

* CLOCK_PORT: name of the clock signal port. Make sure that this name matches
  the name of the clock signal in your top level module.

* STD_CELL_LIBRARY: Standard Cell Library.

You can also specify variables in the config.tcl file whose values that you provide here will override the default values of these variables. These variables are used to specify and report different design parameters that are used in the Static Timing Analysis.
* Synthesis strategy parameter **SYNTH_STRATEGY**. This parameter
   can be used to define the synthesis strategy. This defines if the design is
   optimized for area or for delay.
* Parameter to specify input delay as percentage of clock peroid **IO_PCT**.
* Parameter to report maximum delay path **LIB_SLOWEST** and minimum delay paths
   **LIB_FASTEST** and specific delay path **LIB_TYPICAL**.
* Parameter to set different wire load models **SPEF_WIRE_MODEL**.

**NOTE:** Complete list of configuration variables that can be used to define
the design constraints can be found at:
https://github.com/The-OpenROAD-Project/OpenLane/tree/master/configuration


3. After eding config.tcl file, run the following command.
```bash 
./flow.tcl -design design1 -tag first_run
```
where the -tag option is the tag for the design run. This command will go
through all the following steps to generate GDSII file from Verilog input files.

**"Synthesis"**

_yosys_ - Performs RTL synthesis _abc_ - Performs technology mapping

**"Static Timing Analysis"** 

OpenSTA - Performs static timing analysis on the resulting netlist to generate
timing reports

**"Floorplan and PDN"**

_init_fp_ - Defines the core area for the macro as well as the rows (used for
placement) and the tracks (used for routing) _ioplacer_ - Places the macro input
and output ports _pdn_ - Generates the power distribution network _tapcell_ -
Inserts welltap and decap cells in the floorplan

**"Placement"**

_RePLace_ - Performs global placement _Resizer_ - Performs optional
optimizations on the design _OpenDP_ - Perfroms detailed placement to legalize
the globally placed components

**"Clock Tree Synthesis"**

_TritonCTS_ - Synthesizes the clock distribution network (clock tree)

**"Routing"**

_FastRoute_ - Performs global routing to generate a guide file for the detailed
router.

_CU-GR_ - Another option for performing global routing.

_TritonRoute_ - Performs detailed routing

_SPEF-Extractor_ - Performs SPEF extraction.

**"GDSII Generation"**

_Magic_ - Streams out the final GDSII layout file from the routed def _Klayout_
- Streams out the final GDSII layout file from the routed def as a back-up

**"Checks"**

_Magic_ - Performs DRC Checks & Antenna Checks

_Klayout_ - Performs DRC Checks

_Netgen_ - Performs LVS Checks

_CVC_ - Performs Circuit Validity Checks

After all the processes mentioned above are successfully completed without any
fatal errors and warnings, the GDSII file is generated. Go to the
runs/first_run/ folder. Here you will have all reports and results generated by
all of the above mentioned steps.

## Interactive flow of OpenLane

OpenLane can be run in interactive mode. This can be done by following these
steps.

1. Intialize design configuration:
```bash
flow.tcl -design design1 -init_design_config 
```
2. Start interactive flow of OpenLane:
```bash
flow.tcl -interactive
``` 
3. Prepare the design:
```bash
prep -design your_design
```

The last command will prepare the design for OpenLane flow by creating one .lef
file and one .tech file by merging all the tech and lef files from the library.

4. Run *yosys*. Enter following in the command line:
```bash
run_yosys
```

This creates a gate level netlist of the design and will perform technology
independent optimizations to the design.

5. Run Static Timing Analysis:
```bash
run_sta
```
This reports the Total Negative Slack and Worst Negative Slack of the design.

6. Run Floorplan:
```bash
run_floorplan
```
7. Run Placement step:
```bash
run_placement_step
```
8. Run CTS step:
```bash
run_cts_step
```
9. Run Routing step:
```bash
run_routing_step
```
10. Run Fake Diode Insertion step:
```bash
run_diode_insertion_2_5_step
```
11. Run Power Pin Insertion step:
```bash
run_power_pins_insertion_step
```
12. Run Magic:
```bash
run_magic
```
13. Run Klayout:
```bash
run_klayout
```
14. Run Klayout GDS XOR:
```bash
run_klayout_gds_xor
```
15. Run CVC:
```bash
run_lef_cvc
```


# OpenRAM Instructions

## INSTALLATION OF OPENRAM

The requirements for Openram are the following:

1.   Python 3.8.10
2.   Python numpy (pip3 install numpy)
3.   Python scipy (pip3 install scipy)
4.   Python sklearn (pip3 install sklearn)
5.   Python Coverage(pip3 install coverage)     
5.   Magic 8.3.130
6.   Netgen 1.5.164 or newer

Clone OpenRAM and set environment variables as follows:

1. clone the git repository for openram
```bash
git clone https://github.com/VLSIDA/OpenRAM
```
2. set following environment variables in bashrc
```bash
export OPENRAM_HOME=<path to openRAM compiler>
export OPENRAM_TECH=<path to openRAM technology>
export OPENRAM_CONFIG=<path to skywater directory inside iob-soc repository>
  ```
3. Also add OPENRAM_HOME to your PYTHONPATH variable
```bash
export PYTHONPATH="$PYTHONPATH:$OPENRAM_HOME"
```

## Getting SKYWATER 130nm 

Clone the Skywater Physical Design Kit:

```bash
git clone https://github.com/google/skywater-pdk
```

## Getting OpenPDK

We will need OpenPDK to install & generate the required tech files for
*magic_vlsi*. Get open pdk repository and checkout to new branch as follows:

```bash
git clone git://opencircuitdesign.com/open_pdks
cd open_pdks
git checkout open_pdks-1.0
```

## Getting Magic_VLSI 

For *magic_vlsi* requirements, do the following:

```bash
sudo apt update && sudo apt install m4 tcsh csh libx11-dev tcl-dev tk-dev
sudo apt install libcairo2-dev libncurses-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev
```

Download and install *magic_vlsi*.

**Download**
```bash
git clone git://opencircuitdesign.com/magic
cd magic
git checkout magic-8.3
```

**Compile & Install**
```bash
sudo ./configure
sudo make
sudo make install
```


## Skywater PDK Installation

```bash
# cd into skywater-pdk cloned repository.
cd skywater-pdk 
git submodule init libraries/sky130_fd_pr/latest
git submodule init libraries/sky130_fd_sc_hd/latest
git submodule init libraries/sky130_fd_sc_hdll/latest
git submodule init libraries/sky130_fd_sc_hs/latest
git submodule init libraries/sky130_fd_sc_ms/latest
git submodule init libraries/sky130_fd_sc_ls/latest
git submodule init libraries/sky130_fd_sc_lp/latest
git submodule init libraries/sky130_fd_sc_hvl/latest
git submodule update
sudo make timing
``` 


## Configuring Open PDK with Google Skywater

To configure Open PDK with Google's Skywater technology, do the following:
```bash
cd <path to open-pdk repository root directory>
./configure --enable-sky130-pdk=<skywater root directory>/skywater-pdk/libraries --with-sky130-local-path=<your target install directory> 
```

**NOTE**: Skywater_root_dir = skywater repo and your_target_install_dir = your
skywater130A runtime install directory.

## Install Skywater

From the open-pdk repository, do the following 
```bash
cd sky130 # you should be in open_pdks root dir
make
sudo make install
``` 

## Integrate Skywater into Magic

As the Skywater tech files are not installed in magic’s library, we need to
create a symbolic link in order to use the tech files for layout drawing:

```bash
sudo ln -s /path/to/open_pdks/sky130A/libs.tech/magic/*  /usr/local/lib/magic/sys/
```

## Running Magic with Skywater

Enter following in the terminal to check if the magic can run with Skywater:
```bash
sudo magic -T sky130A
```

## Porting SKY130 to OpenRAM

Last step is to port skywater 130 process node technology to OpenRAM. The
OpenRAM compiler is currently available for two technologies, SCMOS and
FreePDK45. For adding a new technology support to OpenRAM, a directory with the
name of process node should be created in directory $OPENRAM_TECH.

Getting the Sky130 technology for OpenRAM:

```bash
git clone https://github.com/vsdip/vsdsram_sky130
```

Copy the folder `vsdsram_sky130/OpenRAM/sky130A)` and paste it in in directory
$OPENRAM_TECH.

## Netgen Installation

To get the git repo for Netgen, a tool used for LVS layout vs schemetic
comparison, do the following:

```bash
git clone git://opencircuitdesign.com/netgen
```

To install Netgen, type:

```bash
cd netgen # repo of netgen
./configure
make 
make install
``` 

Finally, make a configuration python script, for example "openram_config.py",
with the following content:

```python
# Data word size
word_size = 32

# Number of words in the memory
num_words = 32 #1024

# Technology to use in $OPENRAM_TECH
tech_name = "sky130A"

# You can use the technology nominal corner only
# nominal_corner_only = True

process_corners = ["SS", "TT", "FF"]
# process_corners = ["TT"]

# Voltage corners to characterize
supply_voltages = [ 1.8 ]
# supply_voltages = [ 3.0, 3.3, 3.5 ]

# Temperature corners to characterize
# temperatures = [ 0, 25 100]

# Output directory for the results
output_path = "temp"
# Output file base name
output_name = "sram_{0}_{1}_{2}".format(word_size,num_words,tech_name)

# Disable analytical models for full characterization (WARNING: slow!)
# analytical_delay = False
```

Some example scripts are available inside the OpenRAM repository, in
`openram/compiler/example_configs`. Finally, run OpenRAM as follows:
```bash
python3 $OPENRAM_HOME/openram.py openram_config.py 
```

**REFERENCES:**

[OpenCircuit](http://www.opencircuitdesign.com/open_pdks/install.html)

[Magic_VLSI_Install_Guide](https://lootr5858.wordpress.com/2020/10/06/magic-vlsi-skywater-pdk-local-installation-guide/)

[Github:Repo for Skywater130
tech](https://github.com/vsdip/vsdsram_sky130/tree/main/OpenRAM)

[OpenRAM Repo](https://github.com/VLSIDA/OpenRAM)

[Google Skywater](https://github.com/google/skywater-pdk)











  

  

   

