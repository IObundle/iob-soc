#!/usr/bin/env python3
#Contains functions usefull for the tester
#TODO: this file is no longer needed

import sys
import subprocess
import os
import re

# Add folder to path that contains python scripts to be imported
import submodule_utils 
from submodule_utils import *
from portmap_utils import *

# SUT instance to be included in tester
sut_instance_template = """\
system sut (
    //SUTPORTS

`ifdef USE_DDR
    //address write
    .m_axi_awid    (m_axi_awid),
    .m_axi_awaddr  (m_axi_awaddr),
    .m_axi_awlen   (m_axi_awlen),
    .m_axi_awsize  (m_axi_awsize),
    .m_axi_awburst (m_axi_awburst),
    .m_axi_awlock  (m_axi_awlock),
    .m_axi_awcache (m_axi_awcache),
    .m_axi_awprot  (m_axi_awprot),
    .m_axi_awqos   (m_axi_awqos),
    .m_axi_awvalid (m_axi_awvalid),
    .m_axi_awready (m_axi_awready),

    //write  
    .m_axi_wdata   (m_axi_wdata),
    .m_axi_wstrb   (m_axi_wstrb),
    .m_axi_wlast   (m_axi_wlast),
    .m_axi_wvalid  (m_axi_wvalid),
    .m_axi_wready  (m_axi_wready),

    //write response
    .m_axi_bid     (m_axi_bid),
    .m_axi_bresp   (m_axi_bresp),
    .m_axi_bvalid  (m_axi_bvalid),
    .m_axi_bready  (m_axi_bready),

    //address read
    .m_axi_arid    (m_axi_arid),
    .m_axi_araddr  (m_axi_araddr),
    .m_axi_arlen   (m_axi_arlen),
    .m_axi_arsize  (m_axi_arsize),
    .m_axi_arburst (m_axi_arburst),
    .m_axi_arlock  (m_axi_arlock),
    .m_axi_arcache (m_axi_arcache),
    .m_axi_arprot  (m_axi_arprot),
    .m_axi_arqos   (m_axi_arqos),
    .m_axi_arvalid (m_axi_arvalid),
    .m_axi_arready (m_axi_arready),

    //read   
    .m_axi_rid     (m_axi_rid),
    .m_axi_rdata   (m_axi_rdata),
    .m_axi_rresp   (m_axi_rresp),
    .m_axi_rlast   (m_axi_rlast),
    .m_axi_rvalid  (m_axi_rvalid),
    .m_axi_rready  (m_axi_rready),	
`endif               
    .clk           (clk),
    .reset         (reset),
    .trap          (trap[0])
    );
"""

# Creates tester.v with SUT included 
def create_tester(directories_str, sut_peripherals_str, tester_peripherals_str):
    # Get lists of peripherals and info about them
    sut_instances_amount = get_peripherals(sut_peripherals_str)
    tester_instances_amount = get_peripherals(tester_peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals = get_peripherals_signals({**sut_instances_amount, **tester_instances_amount},submodule_directories)

    # Read portmap file and get encoded data
    pwires, mapped_signals = read_portmap(sut_instances_amount, tester_instances_amount, peripheral_signals, root_dir+"/peripheral_portmap.conf")

    # Read template file
    tester_template_file = open(root_dir+"/hardware/src/system_core.v", "r") 
    tester_contents = tester_template_file.readlines() 
    tester_template_file.close()

    # Insert headers of peripherals of both systems
    for i in {**sut_instances_amount, **tester_instances_amount}:
        path = root_dir+"/"+submodule_directories[i]+"/hardware/include"
        start_index = find_idx(tester_contents, "PHEADER")
        for file in os.listdir(path):
            if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                tester_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
            if file.endswith("swreg.vh"):
                tester_contents.insert(start_index, '`include "{}"\n'.format(file.replace("swreg","swreg_def")))

    # Rename verilog module form 'system' to 'tester'
    tester_contents[find_idx(tester_contents, "module system")-1] = "module tester\n"

    # Add another trap signal for tester cpu
    tester_contents = [re.sub('output(\s+)trap', 'output [1:0]\g<1>trap', i) for i in tester_contents] 
    # Attach tester cpu to instance 0 of trap signal array
    tester_contents = [re.sub('\(trap\)', '(trap[1])', i) for i in tester_contents] 

    axi_sizes = {} #Store axi signal sizes 
    # Add another AXI bus for Tester memory
    for i in range(len(tester_contents)):
        strMatch = re.search('(inout|input|output)\s+(?:\[([^\:]+)[^\]]+\])?\s+(m_axi_[^,]+),', tester_contents[i])
        if not strMatch:
            continue
        if strMatch[2]==None or strMatch[2]=="0":
            tester_contents[i]="   {} [1:0] {},\n".format(strMatch[1],strMatch[3])
            axi_sizes[strMatch[3]]="0"
        else:
            tester_contents[i]="   {} [2*({}+1)-1:0] {},\n".format(strMatch[1],strMatch[2],strMatch[3])
            axi_sizes[strMatch[3]]=strMatch[2]
    # Change Tester AXI interface to use instance 1 of AXI bus array
    for i in range(len(tester_contents)):
        strMatch = re.search('\((m_axi_[^\)]+)\)', tester_contents[i])
        if not strMatch:
            continue
        tester_contents[i]=re.sub('\(m_axi_[^\)]+\)', '({}[2*({}+1)-1:{}+1])'.format(strMatch[1],axi_sizes[strMatch[1]],axi_sizes[strMatch[1]]), tester_contents[i])

    # Insert SUT instance (includes SUTPORTS marker)
    start_index = find_idx(tester_contents, "endmodule")-1
    sut_instance_template_array = sut_instance_template.splitlines(True)
    for i in range(len(sut_instance_template_array)):
        strMatch = re.search('\((m_axi_[^\)]+)\)', sut_instance_template_array[i])
        if not strMatch:
            continue
        sut_instance_template_array[i]=re.sub('\(m_axi_[^\)]+\)', '({}[{}:0])'.format(strMatch[1],axi_sizes[strMatch[1]]), sut_instance_template_array[i])
    tester_contents = tester_contents[:start_index] + sut_instance_template_array + tester_contents[start_index:] 

    # Invert tester memory access bit
    start_index = find_idx(tester_contents, "ext_mem ")-1
    tester_contents.insert(start_index, "`endif\n")
    tester_contents.insert(start_index, "   assign m_axi_awaddr[2*`DDR_ADDR_W-1] = axi_invert_w_bit;\n")
    tester_contents.insert(start_index, "   assign m_axi_araddr[2*`DDR_ADDR_W-1] = axi_invert_r_bit;\n")
    tester_contents.insert(start_index, "   //Dont invert bits if we dont run firmware of both systems from the DDR\n")
    tester_contents.insert(start_index, "`else\n")
    tester_contents.insert(start_index, "   assign m_axi_awaddr[2*`DDR_ADDR_W-1] = ~axi_invert_w_bit;\n")
    tester_contents.insert(start_index, "   assign m_axi_araddr[2*`DDR_ADDR_W-1] = ~axi_invert_r_bit;\n")
    tester_contents.insert(start_index, "`ifdef RUN_EXTMEM\n")
    tester_contents.insert(start_index, "   wire axi_invert_w_bit;\n")
    tester_contents.insert(start_index, "   wire axi_invert_r_bit;\n")
    tester_contents = [re.sub('.axi_awaddr\(m_axi_awaddr\[[^\]]+\]\),', '.axi_awaddr({axi_invert_w_bit,m_axi_awaddr[2*`DDR_ADDR_W-2:`DDR_ADDR_W]}),', i) for i in tester_contents]
    tester_contents = [re.sub('.axi_araddr\(m_axi_araddr\[[^\]]+\]\),', '.axi_araddr({axi_invert_r_bit,m_axi_araddr[2*`DDR_ADDR_W-2:`DDR_ADDR_W]}),', i) for i in tester_contents]

    # Replace N_SLAVES by TESTER_N_SLAVES
    tester_contents = [re.sub('`N_SLAVES', '`TESTER_N_SLAVES', i) for i in tester_contents] 

    #Insert parameters on int_mem to load with tester firmware
    int_mem_template = """\
    int_mem
         #(.HEXFILE("tester_firmware"),
           .BOOT_HEXFILE("tester_boot"))
        int_mem0
    """
    start_index = find_idx(tester_contents, "int_mem ")-1
    tester_contents.pop(start_index)
    tester_contents = tester_contents[:start_index] + int_mem_template.splitlines(True) + tester_contents[start_index:]

    # Insert Tester peripherals
    for corename in tester_instances_amount:
        swreg_filename = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk")+"_swreg";

        # Insert for every instance
        for i in range(tester_instances_amount[corename]):
            # Insert peripheral instance
            start_index = find_idx(tester_contents, "endmodule")-1
            tester_contents.insert(start_index, "      );\n")
            first_reversed_signal=True
            # Insert reserved signals
            for signal in reversed(reserved_signals_template.splitlines(True)):
                str_match=re.match("^\s*\.([^\(]+)\(",signal)
                # Only insert if this reserved signal (from template) is present in IO of this peripheral
                if (str_match is not None) and str_match.group(1) in peripheral_signals[corename]:
                    tester_contents.insert(start_index, 
                            re.sub("\/\*<InstanceName>\*\/","TESTER_"+corename+str(i),
                            re.sub("\/\*<SwregFilename>\*\/",swreg_filename, 
                                signal)))
                    # Remove comma at the end of last signal
                    if first_reversed_signal == True:
                        tester_contents[start_index]=tester_contents[start_index][::-1].replace(",","",1)[::-1]
                        first_reversed_signal = False
            # Insert io signals
            for signal in get_pio_signals(peripheral_signals[corename]):
                    if mapped_signals[1][corename][i][signal] > -1: # Not mapped to external interface
                        # Signal is connected to corresponding pwires
                        tester_contents.insert(start_index, '      .{}({}),\n'.format(signal,pwires[mapped_signals[1][corename][i][signal]][0]))
                    else: # Mapped to external interface
                        # Signal is connected to corresponding pio
                        tester_contents.insert(start_index, '      .{}(tester_{}_{}),\n'.format(signal,corename+str(i),signal))
            tester_contents.insert(start_index, "     (\n")
            tester_contents.insert(start_index, "   {} {}\n".format(swreg_filename[:-6], corename+str(i)))
            tester_contents.insert(start_index, "\n")
            tester_contents.insert(start_index, "   // {}\n".format(corename+str(i)))
            tester_contents.insert(start_index, "\n")

    # Array to store if pwires have been inserted
    pwires_inserted = [0] * len(pwires)
    # Insert PIO, PWIRES, SUTPORTS 
    for corename in sut_instances_amount:
        swreg_filename = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk")+"_swreg";

        for i in range(sut_instances_amount[corename]):
            for signal in get_pio_signals(peripheral_signals[corename]):
                # Make sure this signal is mapped
                if mapped_signals[0][corename][i][signal] < -1:
                    print("Error: signal {} of SUT.{}[{}] not mapped!".format(signal,corename,i))
                    exit(-1)
                if mapped_signals[0][corename][i][signal] > -1: # Not mapped to external interface
                    # Only insert this signal, if it is mapped between SUT and Tester (don't insert SUT : SUT signals)
                    if 2>len(re.findall('(?=_SUT_)', pwires[mapped_signals[0][corename][i][signal]][0])):
                        # Make sure we have not yet created PWIRE of this signal
                        if pwires_inserted[mapped_signals[0][corename][i][signal]] == False:
                            # Insert pwire
                            tester_contents.insert(find_idx(tester_contents, "PWIRES"), '    wire {} {};\n'.format(pwires[mapped_signals[0][corename][i][signal]][1].replace("/*<SwregFilename>*/",swreg_filename),pwires[mapped_signals[0][corename][i][signal]][0]))
                            # Mark this signal as been inserted
                            pwires_inserted[mapped_signals[0][corename][i][signal]] = True
                        # Insert SUT PORT
                        tester_contents.insert(find_idx(tester_contents, "SUTPORTS"), '        .{}_{}({}),\n'.format(corename+str(i),signal,pwires[mapped_signals[0][corename][i][signal]][0]))
                else: # Mapped to external interface
                    # Insert PIO
                    tester_contents.insert(find_idx(tester_contents, "PIO"), '    {} sut_{}_{},\n'.format(peripheral_signals[corename][signal].replace("/*<SwregFilename>*/",swreg_filename),corename+str(i),signal))
                    # Insert SUT PORT
                    tester_contents.insert(find_idx(tester_contents, "SUTPORTS"), '        .{}_{}(sut_{}_{}),\n'.format(corename+str(i),signal,corename+str(i),signal))
    for corename in tester_instances_amount:
        swreg_filename = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk")+"_swreg";

        for i in range(tester_instances_amount[corename]):
            for signal in get_pio_signals(peripheral_signals[corename]):
                # Make sure this signal is mapped
                if mapped_signals[1][corename][i][signal] < -1:
                    print("Error: signal {} of Tester.{}[{}] not mapped!".format(signal,corename,i))
                    exit(-1)
                if mapped_signals[1][corename][i][signal] > -1: # Not mapped to external interface
                    # Make sure we have not yet created PWIRE of this signal
                    if pwires_inserted[mapped_signals[1][corename][i][signal]] == False:
                        # Insert pwire
                        tester_contents.insert(find_idx(tester_contents, "PWIRES"), '    wire {} {};\n'.format(pwires[mapped_signals[1][corename][i][signal]][1].replace("/*<SwregFilename>*/",swreg_filename),pwires[mapped_signals[1][corename][i][signal]][0]))
                        # Mark this signal as been inserted
                        pwires_inserted[mapped_signals[1][corename][i][signal]] = True
                else: # Mapped to external interface
                    # Insert PIO
                    tester_contents.insert(find_idx(tester_contents, "PIO"), '    {} tester_{}_{},\n'.format(peripheral_signals[corename][signal].replace("/*<SwregFilename>*/",swreg_filename),corename+str(i),signal))

    # Write tester.v
    tester_file = open("tester.v", "w")
    tester_file.writelines(tester_contents)
    tester_file.close()

# Create top_system for simulation with the Tester
def create_top_system(directories_str, sut_peripherals_str, tester_peripherals_str):
    # Get lists of peripherals and info about them
    sut_instances_amount = get_peripherals(sut_peripherals_str)
    tester_instances_amount = get_peripherals(tester_peripherals_str)
    submodule_directories = get_submodule_directories(directories_str)
    peripheral_signals = get_peripherals_signals({**sut_instances_amount, **tester_instances_amount},submodule_directories)

    # Read portmap file and get encoded data
    _, mapped_signals = read_portmap(sut_instances_amount, tester_instances_amount, peripheral_signals, root_dir+"/peripheral_portmap.conf")

    # Read template file
    topsystem_template_file = open(root_dir+"/hardware/tester/tester_top_core.v", "r") 
    topsystem_contents = topsystem_template_file.readlines() 
    topsystem_template_file.close()

    # Insert headers of peripherals of both systems
    for i in {**sut_instances_amount, **tester_instances_amount}:
        path = root_dir+"/"+submodule_directories[i]+"/hardware/include"
        start_index = find_idx(topsystem_contents, "PHEADER")
        for file in os.listdir(path):
            if file.endswith(".vh") and not any(x in file for x in ["pio","inst","swreg"]):
                topsystem_contents.insert(start_index, '`include "{}"\n'.format(path+"/"+file))
            if file.endswith("swreg.vh"):
                topsystem_contents.insert(start_index, '`include "{}"\n'.format(file.replace("swreg","swreg_def")))

    # Insert PORTS and PWIRES
    for corename in sut_instances_amount:
        swreg_filename = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk")+"_swreg";

        for i in range(sut_instances_amount[corename]):
            for signal in get_pio_signals(peripheral_signals[corename]):
                # Make sure this signal is mapped
                if mapped_signals[0][corename][i][signal] < -1:
                    print("Error: signal {} of SUT.{}[{}] not mapped!".format(signal,corename,i))
                    exit(-1)
                if mapped_signals[0][corename][i][signal] == -1: # Mapped to external interface, therefore is a top_system port
                    # Insert PWIRES
                    signal_size = re.search("(?:inout|input|output)(.+)",peripheral_signals[corename][signal]).group(1).replace(" ", "").replace("/*<SwregFilename>*/",swreg_filename)
                    topsystem_contents.insert(find_idx(topsystem_contents, "PWIRES"), '    wire {} sut_{}_{};\n'.format(signal_size,corename+str(i),signal))
                    # Insert PORTS
                    topsystem_contents.insert(find_idx(topsystem_contents, "PORTS"), '        .sut_{}_{}(sut_{}_{}),\n'.format(corename+str(i),signal,corename+str(i),signal))
    for corename in tester_instances_amount:
        swreg_filename = get_top_module(root_dir+"/"+submodule_directories[corename]+"/config.mk")+"_swreg";

        for i in range(tester_instances_amount[corename]):
            for signal in get_pio_signals(peripheral_signals[corename]):
                # Make sure this signal is mapped
                if mapped_signals[1][corename][i][signal] < -1:
                    print("Error: signal {} of Tester.{}[{}] not mapped!".format(signal,corename,i))
                    exit(-1)
                if mapped_signals[1][corename][i][signal] == -1: # Mapped to external interface, therefore is a top_system port
                    # Insert PWIRES
                    signal_size = re.search("(?:inout|input|output)(.+)",peripheral_signals[corename][signal]).group(1).replace(" ", "").replace("/*<SwregFilename>*/",swreg_filename)
                    topsystem_contents.insert(find_idx(topsystem_contents, "PWIRES"), '    wire {} tester_{}_{};\n'.format(signal_size,corename+str(i),signal))
                    # Insert PORTS
                    topsystem_contents.insert(find_idx(topsystem_contents, "PORTS"), '        .tester_{}_{}(tester_{}_{}),\n'.format(corename+str(i),signal,corename+str(i),signal))

    # Write topsystem 
    topsystem_file = open("tester_top.v", "w")
    topsystem_file.writelines(topsystem_contents)
    topsystem_file.close()

def print_tester_nslaves(tester_peripherals_str):
    tester_instances_amount = get_peripherals(tester_peripherals_str)
    i=0
    # Calculate total amount of instances
    for corename in tester_instances_amount:
        i=i+tester_instances_amount[corename]
    print(i, end="")

#Creates list of defines of sut instances with sequential numbers
def print_tester_peripheral_defines(defmacro, tester_peripherals_str):
    tester_instances_amount = get_peripherals(tester_peripherals_str)
    j=0
    for corename in tester_instances_amount:
        for i in range(tester_instances_amount[corename]):
            print(defmacro+"TESTER_"+corename+str(i)+"="+str(j), end=" ")
            j = j + 1

#Replaces SUT peripheral sequential numbers with the ones from tester if they exist, otherwise, just add Tester peripheral numbers
#For example, if DEFINE list contains UART0=0 (previously defined for the SUT), and the Tester has its UART0 mapped to 1 (UART0=1), then this function replaces the UART0=0 in the list by UART0=1. If the list did not contain UART0 then it just adds UART0=1.
def replace_peripheral_defines(define_string, defmacro, tester_peripherals_str):
    define_list = define_string.split(' ')
    tester_instances_amount = get_peripherals(tester_peripherals_str)
    j=0
    for corename in tester_instances_amount:
        for i in range(tester_instances_amount[corename]):
            # Check if this instance is already in the list
            foundItem = False
            for k in range(len(define_list)):
                if(define_list[k].startswith(defmacro+corename+str(i))):
                    # Was already defined in list, so replace its peripheral number
                    define_list[k] = defmacro+corename+str(i)+"="+str(j)
                    foundItem = True
                    break
            # Otherwise add it to the list
            if (foundItem == False):
                define_list.append(defmacro+corename+str(i)+"="+str(j))
            j = j + 1
    # Print complete list
    print(*define_list)

if __name__ == "__main__":
    # Parse arguments
    root_dir=sys.argv[2]
    submodule_utils.root_dir = root_dir
    if sys.argv[1] == "create_tester":
        if len(sys.argv)<6:
            print("Usage: {} create_tester <root_dir> <directories_defined_in_config.mk> <sut_peripherals> <tester_peripherals>\n".format(sys.argv[0]))
            exit(-1)
        create_tester(sys.argv[3], sys.argv[4], sys.argv[5])
    elif sys.argv[1] == "create_top_system":
        if len(sys.argv)<6:
            print("Usage: {} create_top_system <root_dir> <directories_defined_in_config.mk> <sut_peripherals> <tester_peripherals>\n".format(sys.argv[0]))
            exit(-1)
        create_top_system(sys.argv[3], sys.argv[4], sys.argv[5])
    elif sys.argv[1] == "get_n_slaves":
        if len(sys.argv)<3:
            print("Usage: {} get_n_slaves <tester_peripherals>\n".format(sys.argv[0]))
            exit(-1)
        print_tester_nslaves(sys.argv[2])
    elif sys.argv[1] == "get_defines":
        if len(sys.argv)<3:
            print("Usage: {} get_defines <tester_peripherals> <optional: defmacro>\n".format(sys.argv[0]))
            exit(-1)
        if len(sys.argv)<4:
            print_tester_peripheral_defines("",sys.argv[2])
        else:
            print_tester_peripheral_defines(sys.argv[3], sys.argv[2])
    elif sys.argv[1] == "replace_peripheral_defines":
        if len(sys.argv)<4:
            print("Usage: {} replace_peripheral_defines <DEFINE_list> <tester_peripherals> <optional: defmacro>\n".format(sys.argv[0]))
            exit(-1)
        if len(sys.argv)<5:
            replace_peripheral_defines(sys.argv[2],"",sys.argv[3])
        else:
            replace_peripheral_defines(sys.argv[2],sys.argv[4],sys.argv[3])
    else:
        print("Unknown command.\nUsage: {} <command> <parameters>\n Commands: create_tester create_top_system get_n_slaves get_defines replace_peripheral_defines".format(sys.argv[0]))
