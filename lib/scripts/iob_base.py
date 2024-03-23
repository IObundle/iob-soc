class iob_base:
    """Generic IOb base class with attributes and methods useful for other IOb classes"""

    def set_default_attribute(self, attribute_name: str, attribute_value):
        """Set an attribute if it has not been set before (likely by a subclass)
        param attribute_name: name of the attribute
        param attribute_value: value to set
        """
        if not hasattr(self, attribute_name):
            setattr(self, attribute_name, attribute_value)
