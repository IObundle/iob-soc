class iob_base:
    """Generic IOb base class with attributes and methods useful for other IOb classes"""

    def set_default_value(self, attribute_name: str, attribute_value):
        """Set a default value for an attribute
        Defines an attribute if it doesn't exist and sets its value.
        param attribute_name: name of the attribute
        param attribute_value: value to set
        """
        if not hasattr(self, attribute_name):
            setattr(self, attribute_name, attribute_value)
