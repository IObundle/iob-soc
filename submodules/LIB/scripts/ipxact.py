#!/usr/bin/env python3

# TODO: account for log2n_items in the memory map

import math

# Generates IP-XACT for the given core
#
#


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

    def gen_xml(self):
        """
        Generate the xml code for the parameter
        @param self: parameter object
        return: xml code
        """

        xml_code = f"""
<ipxact:parameter kactus2:usageCount="{self.usage_count}" maximum="{self.max_value}" minimum="{self.min_value}" parameterId="{self.name+"_ID"}" type="int">
    <ipxact:name>{self.name}</ipxact:name>
    <ipxact:description>{self.description}</ipxact:description>
    <ipxact:value>{self.def_value}</ipxact:value>
</ipxact:parameter>
        """

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
        for param in parameters_list:
            # if the parameter is in the hw_size, increment it's usage count for each time it's used
            if param.name in self.hw_size:
                param.usage_count += self.hw_size.count(param.name)
                # replace the parameter with it's ID
                xml_hw_size = self.hw_size.replace(param.name, param.name + "_ID")

        # If the register is not a multiple of 8 bits, add the reserved bits
        rsvd_xml = ""
        if self.sw_size != self.hw_size:
            # if the parameter is in the hw_size, increment it's usage count two times for each time it's used
            for param in parameters_list:
                if param.name in self.hw_size:
                    param.usage_count += 2 * self.hw_size.count(param.name)
            
            # Generate the reserved bits xml code
            rsvd_xml = f"""
    <ipxact:field>
        <ipxact:name>RSVD</ipxact:name>
        <ipxact:bitOffset>{xml_hw_size}</ipxact:bitOffset>
        <ipxact:resets>
            <ipxact:reset resetTypeRef="{self.rst}">
                <ipxact:value>{self.rst_val}</ipxact:value>
            </ipxact:reset>
        </ipxact:resets>
        <ipxact:bitWidth>{self.sw_size + " - " + xml_hw_size}</ipxact:bitWidth>
    </ipxact:field>
    """

        # Generate the xml code
        xml_code = f"""
<ipxact:register>
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
    </ipxact:field>
    {rsvd_xml}
</ipxact:register>
        """

        return xml_code

def gen_memory_map_xml(core, sw_regs, parameters_list):
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
        sw_regs_xml += sw_reg.gen_xml(parameters_list)

    # Compute the memory map range by adding the address and sw_size (in bytes) of the last register
    memory_map_range = sw_regs_list[-1].address + sw_regs_list[-1].sw_size / 8

    # Generate the xml code for the memory map
    xml_code = f"""
<ipxact:memoryMaps>
    <ipxact:memoryMap>
        <ipxact:name>CSR</ipxact:name>
        <ipxact:addressBlock>
            <ipxact:name>CSR_REGS</ipxact:name>
            <ipxact:baseAddress>0</ipxact:baseAddress>
            <ipxact:range>{memory_map_range}</ipxact:range>
            <ipxact:width>32</ipxact:width>
            <ipxact:usage>register</ipxact:usage>
            <ipxact:access>read-write</ipxact:access>
            <ipxact:volatile>true</ipxact:volatile>
            {sw_regs_xml}
        </ipxact:addressBlock>
        <ipxact:addressUnitBits>8</ipxact:addressUnitBits>
    </ipxact:memoryMap>
</ipxact:memoryMaps>
    """







def gen_parameters_list(core):
    """
    Generate the parameters list for the given core
    @param core: core object
    return: parameters list
    """

    parameters_list = []
    for conf in core.confs:
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


def gen_memory_map_xml(sw_regs, parameters_list):
    """
    Generate the memory map xml code
    @param sw_regs: list of software registers
    @param parameters_list: list of parameters objects
    return: xml code
    """


def generate_ipxact_xml(core, sw_regs, dest_dir):
    """
    Generate the xml file for the given core
    @param core: core object
    @param sw_regs: list of software registers objects
    @param dest_dir: destination directory
    return: None
    """

    # Remove the core name iob_ sufix and add the CSR IF,
    core_name = core_name.replace("iob_", "")
    core_name = core_name + "_" + core.csr_if

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

    # Create the xml file
    xml_file = open(dest_dir + "/" + core_name + ".xml", "w")

    # Write the xml header
    xml_file.write(
        f"""
    <?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <ipxact:component xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014" xmlns:kactus2="http://kactus2.cs.tut.fi" xsi:schemaLocation="http://www.accellera.org/XMLSchema/IPXACT/1685-2014 http://www.accellera.org/XMLSchema/IPXACT/1685-2014/index.xsd>
        <ipxact:vendor>{core_vendor}</ipxact:vendor>
        <ipxact:library>{core_library}</ipxact:library>
        <ipxact:name>{core_name_display}</ipxact:name>
        <ipxact:version>{core.version}</ipxact:version>
        """
    )
