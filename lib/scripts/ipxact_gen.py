#!/usr/bin/env python3

# TODO: account for log2n_items in the memory map

import math
import io_gen
import if_gen
import re
import os

# Generates IP-XACT for the given core
#
#


def replace_params_with_ids(string, parameters_list, double_usage_count=False):
    """
    Replace the parameters in the string with their ID
    @param string: hardware size
    @param parameters_list: list of parameters objects
    return: string with the parameters replaced with their ID
    """

    xml_output = string
    # Search for parameters in the hw_size and replace them with their ID
    if isinstance(string, str):
        # divide the string expression into a list of strings separated by operators, parenthesis or spaces
        string_list = re.split(r"(\+|\-|\*|\/|\(|\)|\s)", string)
        for value in string_list:
            for param in parameters_list:
                # if the parameter is in the string, increment it's usage count for each time it's used
                if value == param.name:
                    if double_usage_count:
                        param.usage_count += 2 * string.count(param.name)
                    else:
                        param.usage_count += string.count(param.name)
                    # replace the parameter with it's ID
                    xml_output = xml_output.replace(param.name, param.name + "_ID")
                    continue

    return xml_output


class Parameter:
    """
    Parameter class


    """

    def __init__(self, name, type, def_value, min_value, max_value, description):
        self.name = name
        self.type = type
        self.def_value = def_value
        self.min_value = min_value
        self.max_value = max_value
        self.usage_count = 0
        self.description = description

    def gen_xml(self, parameters_list):
        """
        Generate the xml code for the parameter
        @param self: parameter object
        @param parameters_list: list of parameters objects
        return: xml code
        """

        # if the parameter is a string, it has params, change them to their ID
        def_value = replace_params_with_ids(self.def_value, parameters_list)

        # Generate the xml code
        xml_code = f"""<ipxact:parameter kactus2:usageCount="{self.usage_count}" """
        if self.max_value != "NA":
            xml_code += f"""maximum="{self.max_value}" """
        if self.min_value != "NA":
            xml_code += f"""minimum="{self.min_value}" """
        xml_code += f"""parameterId="{self.name}_ID" type="int">
			<ipxact:name>{self.name}</ipxact:name>
			<ipxact:description>{self.description}</ipxact:description>
			<ipxact:value>{def_value}</ipxact:value>
		</ipxact:parameter>"""

        return xml_code


class SwRegister:
    """
    Software register class


    """

    def __init__(
        self, name, address, hw_size, access, rst, rst_val, description, parameters_list
    ):
        self.name = name
        self.address = address
        self.hw_size = hw_size

        max_size = hw_size
        # if the max_size is a string, it has params, retrieve it's maximum value
        if isinstance(max_size, str):
            # transform the string into a mathemathical expression and retrieve the maximum value
            max_size = max_size.replace(" ", "")
            for param in parameters_list:
                max_size = max_size.replace(param.name, param.max_value)
            max_size = eval(max_size)

        # Compute the the size of the register in steps of 8 bits, rounding up
        self.sw_size = 8 * math.ceil(max_size / 8)

        self.access = access
        self.rst = rst
        self.rst_val = rst_val
        self.description = description

    def gen_xml(self, parameters_list):
        """
        Generate the xml code for the software register
        @param self: software register object
        @param parameters_list: list of parameters objects
        return: xml code
        """

        # set the access type
        if self.access == "R":
            access_type = "read-only"
        elif self.access == "W":
            access_type = "write-only"
        else:
            access_type = "read-write"

        # Search for parameters in the hw_size and replace them with their ID
        xml_hw_size = replace_params_with_ids(self.hw_size, parameters_list)

        rsvd_xml = ""
        # If the register is not a multiple of 8 bits, add the reserved bits
        if self.sw_size != self.hw_size:
            if isinstance(self.hw_size, str):
                rsvd_size = replace_params_with_ids(
                    f"{self.sw_size}-{self.hw_size}", parameters_list, True
                )
            else:
                rsvd_size = self.sw_size - self.hw_size

            # Generate the reserved bits xml code
            rsvd_xml = f"""<ipxact:field>
						<ipxact:name>RSVD</ipxact:name>
						<ipxact:bitOffset>{xml_hw_size}</ipxact:bitOffset>
						<ipxact:resets>
							<ipxact:reset resetTypeRef="{self.rst}">
								<ipxact:value>0</ipxact:value>
							</ipxact:reset>
						</ipxact:resets>
						<ipxact:bitWidth>{rsvd_size}</ipxact:bitWidth>
					</ipxact:field>"""

        # Generate the xml code
        xml_code = f"""<ipxact:register>
					<ipxact:name>{self.name}</ipxact:name>
					<ipxact:description>{self.description}</ipxact:description>
					<ipxact:addressOffset>{self.address}</ipxact:addressOffset>
					<ipxact:size>{self.sw_size}</ipxact:size>
					<ipxact:volatile>false</ipxact:volatile>
					<ipxact:access>{access_type}</ipxact:access>
					<ipxact:field>
						<ipxact:name>{self.name}</ipxact:name>
						<ipxact:bitOffset>0</ipxact:bitOffset>
						<ipxact:resets>
							<ipxact:reset resetTypeRef="{self.rst}">
								<ipxact:value>{self.rst_val}</ipxact:value>
							</ipxact:reset>
						</ipxact:resets>
						<ipxact:bitWidth>{xml_hw_size}</ipxact:bitWidth>
					</ipxact:field>"""
        if rsvd_xml != "":
            xml_code += f"""\n					{rsvd_xml}"""
        xml_code += """\n				</ipxact:register>"""

        return xml_code


class Port:
    """
    Port class


    """

    def __init__(self, name, type, n_bits, description):
        self.name = name
        self.type = type
        self.n_bits = n_bits
        self.description = description

    def gen_xml(self, parameters_list):
        """
        Generate the xml code for the port
        @param self: port object
        @param parameters_list: list of parameters objects
        return: xml code
        """

        # set the direction
        if self.type == "I":
            direction = "in"
        elif self.type == "O":
            direction = "out"
        else:
            print("ERROR: Port type not recognized")
            exit(1)

        # Search for parameters in the n_bits and replace them with their ID
        if isinstance(self.n_bits, str):
            left_bit = replace_params_with_ids(f"{self.n_bits}-1", parameters_list)
        else:
            left_bit = self.n_bits - 1

        # Generate the xml code
        xml_code = f"""<ipxact:port>
				<ipxact:name>{self.name}</ipxact:name>
				<ipxact:description>{self.description}</ipxact:description>
				<ipxact:wire>
					<ipxact:direction>{direction}</ipxact:direction>
					<ipxact:vectors>
						<ipxact:vector>
							<ipxact:left>{left_bit}</ipxact:left>
							<ipxact:right>0</ipxact:right>
						</ipxact:vector>
					</ipxact:vectors>
				</ipxact:wire>
			</ipxact:port>"""

        return xml_code


def gen_ports_list(core):
    """
    Generate the ports list for the given core
    @param core: core object
    return: ports list
    """

    if_ports_list = []

    for interface in core.ports:
        # Skip doc_only interfaces
        if "doc_only" in interface.keys() and interface["doc_only"]:
            continue

        # Check if this interface is a standard interface (from if_gen.py)
        if_prefix, if_name = io_gen.find_suffix_from_list(
            interface["name"], if_gen.interfaces
        )
        if if_name:
            # Generate the ports list for the interface
            if_gen.create_signal_table(if_name)
            port_prefix = f"{if_name+'_'}{if_prefix}"
            param_prefix = port_prefix.upper()
            if_ports_list += if_gen.generate_interface(if_name, "", param_prefix)
        else:  # Interface is not standard, simply add the ports list
            if_ports_list += interface["ports"]

    ports_list = []
    for port in if_ports_list:
        n_bits = port["n_bits"]
        if n_bits.isnumeric():
            n_bits = int(n_bits)

        ports_list.append(
            Port(
                port["name"],
                port["type"],
                n_bits,
                port["descr"],
            )
        )

    return ports_list


def gen_ports_xml(ports_list, parameters_list):
    """
    Generate the ports xml code
    @param ports_list: list of ports objects
    return: xml code
    """

    # Generate the xml code for the ports
    ports_xml = ""
    for port in ports_list:
        if ports_xml != "":
            ports_xml += "\n"
            # indent the xml code
            ports_xml += "\t" * 3
        ports_xml += port.gen_xml(parameters_list)

    # Generate the xml code for the ports
    xml_code = f"""<ipxact:ports>
			{ports_xml}
		</ipxact:ports>"""

    return xml_code


def gen_memory_map_xml(sw_regs, parameters_list):
    """
    Generate the memory map xml code
    @param core: core object
    @param sw_regs: list of software registers
    @param parameters_list: list of parameters objects
    return: xml code
    """

    # Generate the software registers list
    sw_regs_list = []
    for sw_reg in sw_regs:
        # create the sw register object
        sw_reg_obj = SwRegister(
            sw_reg["name"],
            sw_reg["addr"],
            sw_reg["n_bits"],
            sw_reg["type"],
            "arst_i",
            sw_reg["rst_val"],
            sw_reg["descr"],
            parameters_list,
        )

        # add it to the sw_regs list
        sw_regs_list.append(sw_reg_obj)

    # Sort the software registers list by address
    sw_regs_list.sort(key=lambda x: x.address)

    # Generate the xml code for the software registers
    sw_regs_xml = ""
    for sw_reg in sw_regs_list:
        if sw_regs_xml != "":
            sw_regs_xml += "\n"
            # indent the xml code
            sw_regs_xml += "\t" * 4
        sw_regs_xml += sw_reg.gen_xml(parameters_list)

    # Compute the memory map range by adding the address and sw_size (in bytes) of the last register
    memory_map_range = sw_regs_list[-1].address + sw_regs_list[-1].sw_size / 8
    # Round up if not an integer
    memory_map_range = math.ceil(memory_map_range)

    # Substitute the ADDR_W parameter value with the memory map range log2
    for param in parameters_list:
        if param.name == "ADDR_W":
            param.def_value = math.ceil(math.log2(memory_map_range))

    # Generate the xml code for the memory map
    xml_code = f"""<ipxact:memoryMaps>
		<ipxact:memoryMap>
			<ipxact:name>CSR</ipxact:name>
			<ipxact:addressBlock>
				<ipxact:name>CSR_REGS</ipxact:name>
				<ipxact:baseAddress>0</ipxact:baseAddress>
				<ipxact:range>{memory_map_range}</ipxact:range>
				<ipxact:width>32</ipxact:width>
				<ipxact:usage>register</ipxact:usage>
				<ipxact:access>read-write</ipxact:access>
				{sw_regs_xml}
			</ipxact:addressBlock>
			<ipxact:addressUnitBits>8</ipxact:addressUnitBits>
		</ipxact:memoryMap>
	</ipxact:memoryMaps>"""

    return xml_code


def gen_parameters_list(core):
    """
    Generate the parameters list for the given core
    @param core: core object
    return: parameters list
    """

    parameters_list = []
    for conf in core.confs:
        if conf["type"] != "M":
            parameters_list.append(
                Parameter(
                    conf["name"],
                    conf["type"],
                    conf["val"],
                    conf["min"],
                    conf["max"],
                    conf["descr"],
                )
            )

    return parameters_list


def gen_instantiations_xml(core, parameters_list):
    """
    Generate the instantiations xml code
    @param core: core object
    @param parameters_list: list of parameters objects
    return: xml code
    """

    # Generate the parameters xml code
    inst_parameters_xml = ""
    for param in parameters_list:
        # generate the parameter ID and the instance parameter ID
        param_id = param.name + "_ID"
        inst_param_id = param.name + "_INST_ID"
        # increment the usage count of the parameter
        param.usage_count += 1
        if inst_parameters_xml != "":
            inst_parameters_xml += "\n"
            # indent the xml code
            inst_parameters_xml += "\t" * 5
        # generate the xml code
        inst_parameters_xml += f"""<ipxact:moduleParameter parameterId="{inst_param_id}" usageType="nontyped">
						<ipxact:name>{param.name}</ipxact:name>
						<ipxact:value>{param_id}</ipxact:value>
					</ipxact:moduleParameter>"""

    # Generate the xml code for the instantiations
    xml_code = f"""<ipxact:instantiations>
			<ipxact:componentInstantiation>
				<ipxact:name>verilog_implementation</ipxact:name>
				<ipxact:language>Verilog</ipxact:language>
				<ipxact:moduleName>{core.name}</ipxact:moduleName>
				<ipxact:moduleParameters>
					{inst_parameters_xml}
				</ipxact:moduleParameters>
			</ipxact:componentInstantiation>
		</ipxact:instantiations>"""

    return xml_code


def gen_resets_xml(ports_list):
    """
    Generate the resets xml code by finding ports with the word "arst_i" in the last 6 characters
    @param ports_list: list of ports objects
    return: xml code
    """

    # Find the ports with the word "arst_i" in the last 6 characters
    arst_ports = []
    for port in ports_list:
        if port.name[-6:] == "arst_i":
            arst_ports.append(port)

    # Generate the xml code for the resets
    ports_xml_code = ""
    for rst in arst_ports:
        if ports_xml_code != "":
            ports_xml_code += "\n"
            # indent the xml code
            ports_xml_code += "\t" * 2
        ports_xml_code += f"""<ipxact:resetType>
			<ipxact:name>{rst.name}</ipxact:name>
			<ipxact:displayName>{rst.name}</ipxact:displayName>
			<ipxact:description>{rst.description}</ipxact:description>
		</ipxact:resetType>"""

    # Generate the xml code for the resets
    xml_code = f"""<ipxact:resetTypes>
		{ports_xml_code}
	</ipxact:resetTypes>"""

    return xml_code


def gen_parameters_xml(parameters_list):
    """
    Generate the parameters xml code
    @param parameters_list: list of parameters objects
    return: xml code
    """

    # Generate the xml code for the parameters
    parameters_xml = ""
    for param in parameters_list:
        if parameters_xml != "":
            parameters_xml += "\n"
            # indent the xml code
            parameters_xml += "\t" * 2
        parameters_xml += param.gen_xml(parameters_list)

    # Generate the xml code for the parameters
    xml_code = f"""<ipxact:parameters>
		{parameters_xml}
	</ipxact:parameters>"""

    return xml_code


def generate_ipxact_xml(core, sw_regs, dest_dir):
    """
    Generate the xml file for the given core
    @param core: core object
    @param dest_dir: destination directory
    return: None
    """

    # try to open file document/tsrc/intro.tex and read it into self.description
    try:
        with open(f"document/tsrc/intro.tex", "r") as file:
            core.description = file.read()
    except:
        print("ERROR: Could not open document/tsrc/intro.tex")
        exit(1)

    # Add the CSR IF,
    core_name = core.name + "_" + core.csr_if

    # Core name to be displayed in the xml file
    # Change "_" to "-" and capitalize all the letters
    core_name_display = core_name.replace("_", "-").upper()

    # Set the core vendor and library
    core_vendor = "CAST"
    core_library = "IP"

    # Generate the parameters table
    parameters_list = gen_parameters_list(core)

    # Genererate the memory map xml code
    memory_map_xml = gen_memory_map_xml(sw_regs, parameters_list)

    # Generate instantiations xml code
    instantiations_xml = gen_instantiations_xml(core, parameters_list)

    # Generate ports list
    ports_list = gen_ports_list(core)

    # Generate ports xml code
    ports_xml = gen_ports_xml(ports_list, parameters_list)

    # Generate resets xml code
    resets_xml = gen_resets_xml(ports_list)

    # Generate parameters xml code
    parameters_xml = gen_parameters_xml(parameters_list)

    # Create the destination directory if it doesn't exist
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)

    # Create the xml file
    xml_file = open(dest_dir + "/" + core_name + ".xml", "w+")

    # Write the xml header
    xml_text = f"""<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ipxact:component xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014" xmlns:kactus2="http://kactus2.cs.tut.fi" xsi:schemaLocation="http://www.accellera.org/XMLSchema/IPXACT/1685-2014 http://www.accellera.org/XMLSchema/IPXACT/1685-2014/index.xsd">
	<ipxact:vendor>{core_vendor}</ipxact:vendor>
	<ipxact:library>{core_library}</ipxact:library>
	<ipxact:name>{core_name_display}</ipxact:name>
	<ipxact:version>{core.version}</ipxact:version>
	{memory_map_xml}
	<ipxact:model>
		<ipxact:views>
			<ipxact:view>
				<ipxact:name>flat_verilog</ipxact:name>
				<ipxact:envIdentifier>Verilog:kactus2.cs.tut.fi:</ipxact:envIdentifier>
				<ipxact:componentInstantiationRef>verilog_implementation</ipxact:componentInstantiationRef>
			</ipxact:view>
		</ipxact:views>
		{instantiations_xml}
		{ports_xml}
	</ipxact:model>
	{resets_xml}
	<ipxact:description>{core.description}</ipxact:description>
	{parameters_xml}
	<ipxact:vendorExtensions>
		<kactus2:author>IObundle, Lda</kactus2:author>
		<kactus2:version>3,10,15,0</kactus2:version>
		<kactus2:kts_attributes>
			<kactus2:kts_productHier>Flat</kactus2:kts_productHier>
			<kactus2:kts_implementation>HW</kactus2:kts_implementation>
			<kactus2:kts_firmness>Mutable</kactus2:kts_firmness>
		</kactus2:kts_attributes>
	</ipxact:vendorExtensions>
</ipxact:component>"""

    # Write the xml code to the file
    xml_file.write(xml_text)
