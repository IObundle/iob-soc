import sys
import os
from dataclasses import dataclass
import importlib

import iob_colors


class iob_base:
    """Generic IOb base class with attributes and methods useful for other IOb classes"""

    def set_default_attribute(
        self,
        name: str,
        value,
        datatype=None,
        set_attribute_handler=None,
        descr: str = "",
    ):
        """Set an attribute if it has not been set before (likely by a subclass)
        Also optionally verifies if the datatype of the attribute set
        previously is correct.
        param name: name of the attribute
        param value: value to set
        param datatype: optional data type of the attribute to check
        param set_attribute_handler: function to call to set the attribute
                                     Related to `parse_attributes_dict()` of iob_core.py
        param descr: description of the attribute
        """
        if not hasattr(self, name):
            setattr(self, name, value)
        elif datatype is not None:
            if type(getattr(self, name)) != datatype:
                raise TypeError(
                    iob_colors.FAIL
                    + f"Attribute '{name}' must be of type {datatype}"
                    + iob_colors.ENDC
                )
        # Ensure that `ATTRIBUTE_PROPERTIES` dictionary exists
        # The 'ATTRIBUTE_PROPERTIES' is a dictionary that stores information about the
        # attributes, including the handlers used to set their values.
        if "ATTRIBUTE_PROPERTIES" not in self.__dict__:
            self.ATTRIBUTE_PROPERTIES = {}
        # Define the function to call to set the attribute from info given in a dict.
        # See `parse_attributes_dict()` of iob_core.py for details.
        # For example, the info given about this attribute may be of the type 'dict',
        # but we may want to set a type 'object' instead.
        # The `set_attribute_handler` is responsible for converting between these two
        # datatypes.
        if name in self.ATTRIBUTE_PROPERTIES:
            properties = self.ATTRIBUTE_PROPERTIES[name]
        else:
            properties = iob_attribute_properties()
        if datatype:
            properties.datatype = datatype
        if set_attribute_handler:
            # Set custom set_handler
            properties.set_handler = set_attribute_handler
        elif not properties.set_handler:
            # Set default set_handler
            properties.set_handler = lambda v: setattr(self, name, v)
        if descr:
            properties.descr = descr

        self.ATTRIBUTE_PROPERTIES[name] = properties


@dataclass
class iob_attribute_properties:
    """Class that stores properties of an attribute"""

    datatype: object = None
    # Function to use to set the attribute value based on info given in the 'py2hw'
    # interface
    set_handler: object = None
    descr: str = "Default attribute description"


#
# List manipulation methods
#


def find_obj_in_list(obj_list, obj_name):
    """Returns an object with a given name from a list of objects
    param obj_list: list of objects (or dictionaries) to search
    param obj_name: name of the object to find
    """
    # Support dictionaries as well
    if obj_list and isinstance(obj_list[0], dict):
        return next((o for o in obj_list if o["name"] == obj_name), None)

    return next((o for o in obj_list if o.name == obj_name), None)


def convert_dict2obj_list(dict_list: dict, obj_class):
    """Convert a list of dictionaries to a list of objects
    If list contains elements that are not dictionaries, they are left as is
    param dict_list: list of dictionaries
    param obj_class: class of the objects to create
    """
    obj_list = []
    for dict_obj in dict_list:
        if isinstance(dict_obj, dict):
            obj_list.append(obj_class(**dict_obj))
        else:
            obj_list.append(dict_obj)
    return obj_list


def process_elements_from_list(list2process: list, process_func):
    """Run processing function on each element of a list"""
    for e in list2process:
        process_func(e)


#
# Print methods
#


def fail_with_msg(msg, exception_type=Exception):
    """Raise an error with a given message
    param msg: message to print
    param exception_type: type of python exception to raise
    """
    raise exception_type(iob_colors.FAIL + msg + iob_colors.ENDC)


def warn_with_msg(msg):
    """Print a warning with a given message"""
    print(iob_colors.WARNING + msg + iob_colors.ENDC)


#
# Other methods
#


def find_file(search_directory, name_without_ext, filter_extensions=[]):
    """Find a file, without extension, in a given directory or subdirectories
    param name_without_ext: name_without_ext of the file without extension
    param search_directory: directory to search
    param filter_extensions: list of extensions to filter
    """
    for root, _, files in os.walk(search_directory):
        for file in files:
            file_name, file_ext = os.path.splitext(file)
            if file_name == name_without_ext and (
                filter_extensions == [] or file_ext in filter_extensions
            ):
                return os.path.join(root, file)
    return None


def hardcoded_find_file(name_without_ext, filter_extensions=[]):
    """Find a file in specific hardcoded directories
    param name_without_ext: name of the file without extension
    param filter_extensions: list of extensions to filter
    """
    hardcoded_directories = [
        ".",
        f"submodules/{name_without_ext}",
        f"lib/modules/{name_without_ext}",
    ]

    for dir in hardcoded_directories:
        files = os.listdir(dir)
        for file in files:
            file_name, file_ext = os.path.splitext(file)
            if file_name == name_without_ext and (
                filter_extensions == [] or file_ext in filter_extensions
            ):
                return os.path.join(dir, file)
    return None


def import_python_module(module_path, module_name=None):
    """Import a python module from a given filepath
    param module_path: path of the module's python file
    param module_name: optinal name of the module. By default equal to file name.
    """
    # Don't import the same module twice
    if module_name in sys.modules:
        return
    if not module_name:
        module_name = os.path.splitext(os.path.basename(module_path))[0]
    spec = importlib.util.spec_from_file_location(module_name, module_path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
