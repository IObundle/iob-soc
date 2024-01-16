#!/usr/bin/env python3

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
