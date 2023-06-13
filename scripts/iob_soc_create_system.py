#!/usr/bin/env python3
import os

# Add folder to path that contains python scripts to be imported
from submodule_utils import get_pio_signals, get_peripherals_ports_params_top, get_reserved_signals, get_reserved_signal_connection
from ios import get_peripheral_port_mapping

# Automatically include <corename>_swreg_def.vh verilog headers after IOB_PRAGMA_PHEADERS comment
def insert_header_files(dest_dir, name, peripherals_list):
    fd_out = open(f"{dest_dir}/{name}_periphs_swreg_def.vs", "w")
    # Get each type of peripheral used
    included_peripherals = []
    for instance in peripherals_list:
        module = instance.module
        if module.name not in included_peripherals:
            included_peripherals.append(module.name)
            # Only insert swreg file if module has regiters
            if hasattr(module,'regs') and module.regs:
                top = module.name
                fd_out.write(f'`include "{top}_swreg_def.vh"\n')
    fd_out.close()


# Creates the Verilog Snippet (.vs) files required by {top}.v 
# build_dir: build directory
# top: top name of the system
# peripherals_list: list of dictionaries each of them describes a peripheral instance
# internal_wires: Optional argument. List of extra wires to create inside module
def create_systemv(build_dir, top, peripherals_list, internal_wires=None):
    num_peripherals_with_axi_s_port = 0

    out_dir = os.path.join(build_dir,f'hardware/src/')

    insert_header_files(out_dir, top, peripherals_list)

    # Get port list, parameter list and top module name for each type of peripheral used
    port_list, params_list, top_list = get_peripherals_ports_params_top(peripherals_list)

    # Insert internal module wires (if any)
    periphs_wires_str = ""
    if internal_wires:
        #Insert internal wires
        for wire in internal_wires:
            periphs_wires_str += f"    wire [{wire['n_bits']}-1:0] {wire['name']};\n"
    
    periphs_inst_str = ""
    # Insert IOs and Instances for this type of peripheral
    for instance in peripherals_list:
        # Create peripheral instance Verilog Snippet
        periphs_inst_str += "\n"
        # Insert peripheral comment
        periphs_inst_str += "   // {}\n".format(instance.name)
        periphs_inst_str += "\n"
        # Insert peripheral type
        periphs_inst_str += "   {}\n".format(top_list[instance.module.name])
        # Insert peripheral parameters (if any)
        if params_list[instance.module.name]:
            periphs_inst_str += "     #(\n"
            # Insert parameters
            for param in params_list[instance.module.name]:
                periphs_inst_str += '      .{}({}){}\n'.format(param['name'],instance.name+"_"+param['name'],",")
            # Remove comma at the end of last parameter
            periphs_inst_str=periphs_inst_str[::-1].replace(",","",1)[::-1]
            periphs_inst_str += "   )\n"
        # Insert peripheral instance name
        periphs_inst_str += "   {} (\n".format(instance.name)
        # Insert io signals
        for signal in get_pio_signals(port_list[instance.module.name]):
            if 'if_defined' in signal.keys(): periphs_inst_str += f"`ifdef {top.upper()}_{signal['if_defined']}\n"
            periphs_inst_str += '      .{}({}),\n'.format(signal['name'],get_peripheral_port_mapping(instance,signal['name_without_prefix']))
            if 'if_defined' in signal.keys(): periphs_inst_str += "`endif\n"
        # Insert reserved signals
        for signal in get_reserved_signals(port_list[instance.module.name]):
            if 'if_defined' in signal.keys(): periphs_inst_str += f"`ifdef {top.upper()}_{signal['if_defined']}\n"
            periphs_inst_str += "      "+get_reserved_signal_connection(signal['name'],
                                      top.upper()+"_"+instance.name,
                                      top_list[instance.module.name].upper()+"_SWREG")+",\n"
            if 'if_defined' in signal.keys(): periphs_inst_str += "`endif\n"
            # Increment number of peripherals connected to axi_s_port if this is one of them (by checking axi_awid_o signal)
            if signal['name']=="axi_awid_o":
                num_peripherals_with_axi_s_port+=1
        # Remove comma at the end of last signal
        periphs_inst_str=periphs_inst_str[::-1].replace(",","",1)[::-1]
        
        periphs_inst_str += "      );\n"

    fd_wires = open(f"{out_dir}/{top}_pwires.vs", "w")
    fd_wires.write(periphs_wires_str)
    fd_wires.close()

    # Map axi_s interface to ground if ther are no peripherals with axi_s port
    if num_peripherals_with_axi_s_port==0:
        periphs_inst_str += map_axi_s_interface_to_groud(top,0)
    
    fd_periphs = open(f"{out_dir}/{top}_periphs_inst.vs", "w")
    fd_periphs.write(periphs_inst_str)
    fd_periphs.close()

# Returns a list of strings mapping the system axi_s interface to ground
# Use this function to prevent and axi_s port with high impedance
# name: System name
# if_num: Interface number of the axi_s bus to connect to ground
def map_axi_s_interface_to_groud(name, if_num):
    return f"""
`ifdef {name.upper()}_USE_EXTMEM
    // Connect outputs of the AXI slave interface {if_num} of system to ground, preventing high impedance
    assign axi_awid_o    [{if_num}+:AXI_ID_W] = 'b0;
    assign axi_awaddr_o  [{if_num}+:AXI_ADDR_W] = 'b0;
    assign axi_awlen_o   [{if_num}+:AXI_LEN_W] = 'b0;
    assign axi_awsize_o  [{if_num}+:3] = 'b0;
    assign axi_awburst_o [{if_num}+:2] = 'b0;
    assign axi_awlock_o  [{if_num}+:2] = 'b0;
    assign axi_awcache_o [{if_num}+:4] = 'b0;
    assign axi_awprot_o  [{if_num}+:3] = 'b0;
    assign axi_awqos_o   [{if_num}+:4] = 'b0;
    assign axi_awvalid_o [{if_num}+:1] = 'b0;
    assign axi_wdata_o   [{if_num}+:AXI_DATA_W] = 'b0;
    assign axi_wstrb_o   [{if_num}+:(AXI_DATA_W/8)] = 'b0;
    assign axi_wlast_o   [{if_num}+:1] = 'b0;
    assign axi_wvalid_o  [{if_num}+:1] = 'b0;
    assign axi_bready_o  [{if_num}+:1] = 'b0;
    assign axi_arid_o    [{if_num}+:AXI_ID_W] = 'b0;
    assign axi_araddr_o  [{if_num}+:AXI_ADDR_W] = 'b0;
    assign axi_arlen_o   [{if_num}+:AXI_LEN_W] = 'b0;
    assign axi_arsize_o  [{if_num}+:3] = 'b0;
    assign axi_arburst_o [{if_num}+:2] = 'b0;
    assign axi_arlock_o  [{if_num}+:2] = 'b0;
    assign axi_arcache_o [{if_num}+:4] = 'b0;
    assign axi_arprot_o  [{if_num}+:3] = 'b0;
    assign axi_arqos_o   [{if_num}+:4] = 'b0;
    assign axi_arvalid_o [{if_num}+:1] = 'b0;
    assign axi_rready_o  [{if_num}+:1] = 'b0;
`endif
"""
