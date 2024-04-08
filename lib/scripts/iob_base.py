import iob_colors


class iob_base:
    """Generic IOb base class with attributes and methods useful for other IOb classes"""

    def set_default_attribute(
        self, attribute_name: str, attribute_value, datatype=None
    ):
        """Set an attribute if it has not been set before (likely by a subclass)
        Also optionally verifies if the datatype of the attribute set
        previously is correct.
        param attribute_name: name of the attribute
        param attribute_value: value to set
        param datatype: optional data type of the attribute to check
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
