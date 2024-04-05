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


def find_obj_in_list(obj_list, obj_name):
    """Returns an object with a given name from a list of objects"""
    # Support dictionaries as well
    if obj_list and isinstance(obj_list[0], dict):
        return next((o for o in obj_list if o["name"] == obj_name), None)

    return next((o for o in obj_list if o.name == obj_name), None)


def fail_with_msg(msg, exception_type=Exception):
    """Raise an error with a given message"""
    raise exception_type(iob_colors.FAIL + msg + iob_colors.ENDC)


def warn_with_msg(msg):
    """Print a warning with a given message"""
    print(iob_colors.WARNING + msg + iob_colors.ENDC)
