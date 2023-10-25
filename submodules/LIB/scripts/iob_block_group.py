# Class that describes a group of blocks
class iob_block_group:
    def __init__(
        self, name="default_group", description="default description", blocks=[]
    ):
        self.name = name
        self.description = description
        self.blocks = blocks
