import iob_colors


class iob_base:
    """Generic IOb base class with attributes and methods useful for other IOb classes"""

    def set_default_attribute(
        self,
        attribute_name: str,
        attribute_value,
        datatype=None,
        set_attribute_handler=None,
    ):
        """Set an attribute if it has not been set before (likely by a subclass)
        Also optionally verifies if the datatype of the attribute set
        previously is correct.
        param attribute_name: name of the attribute
        param attribute_value: value to set
        param datatype: optional data type of the attribute to check
        param set_attribute_handler: function to call to set the attribute
                                     Related to `parse_attributes_dict()` of iob_core.py
        """
        if not hasattr(self, attribute_name):
            setattr(self, attribute_name, attribute_value)
        elif datatype is not None:
            if type(getattr(self, attribute_name)) != datatype:
                raise TypeError(
                    iob_colors.FAIL
                    + f"Attribute '{attribute_name}' must be of type {datatype}"
                    + iob_colors.ENDC
                )
        # Ensure that `SET_ATTRIBUTE_HANDLER` dictionary exists
        # The 'SET_ATTRIBUTE_HANDLER' is a dictionary that stores the handlers used to
        # set every attribute.
        if "SET_ATTRIBUTE_HANDLER" not in self.__dict__:
            self.SET_ATTRIBUTE_HANDLER = {}
        # Define the function to call to set the attribute from info given in a dict.
        # See `parse_attributes_dict()` of iob_core.py for details.
        # For example, the info given about this attribute may be of the type 'dict',
        # but we may want to set a type 'object' instead.
        # The `set_attribute_handler` is responsible for converting between these two
        # datatypes.
        if set_attribute_handler:
            self.SET_ATTRIBUTE_HANDLER[attribute_name] = set_attribute_handler
        else:
            self.SET_ATTRIBUTE_HANDLER[attribute_name] = lambda v: setattr(
                self, attribute_name, v
            )


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
