from dataclasses import dataclass


@dataclass
class iob_wire:
    """Class to represent a wire in an iob module"""
    name: str
    width: int = 1
    connect_to: str = 'x' * width
    description: str = "Default description"

    def __post_init__(self):
        if not self.name:
            raise Exception("Port name is required")

    def set_value(self, value):
        if isinstance(value, str):
            if len(value) != self.width:
                raise ValueError(f'Value {value} is not the correct width {self.width}')
            for c in value:
                if c not in '01zx':
                    raise ValueError(f'Value {value} contains invalid character {c}')
        elif isinstance(value, int):
            if value < 0:
                if value < -(2**(self.width-1)):
                    raise ValueError(f'Value {value} is out of range for width {self.width}')
                value = 2**self.width + value
                # convert to binary and pad with 1s to width
                value = bin(value)[2:]
                value = '1' * (self.width - len(value)) + value
            elif value >= 2**self.width:
                raise ValueError(f'Value {value} is out of range for width {self.width}')
            else:
                value = bin(value)[2:]
                value = '0' * (self.width - len(value)) + value
        # if value is boolean convert to string and check self.width = 1
        elif isinstance(value, bool):
            if self.width != 1:
                raise ValueError(f'Boolean values must be assigned to wires of width 1')
            value = '1' if value else '0'
        self.connect_to = value

    @classmethod
    def create_list(cls, name, width, num):
        _list = []
        for i in range(num):
            _list.append(cls(name=f'{name}_{i}', width=width))
        return _list

    def get_value(self):
        return self.connect_to

    def print_wire(self):
        print(f"wire [{self.width}-1:0] {self.name};")

    # Comparison operators
    def __eq__(self, other):
        if isinstance(other, iob_wire):
            if self.width != other.width:
                raise ValueError(f'Cannot compare wires of different widths {self.width} and {other.width}')
        else:
            raise ValueError(f'Cannot compare iob_wire and {type(other)}')
        temp_wire = iob_wire('temp', 1)
        temp_wire.set_value(self.get_value() == other.get_value())
        return temp_wire

    # Bitwise operators
    def __invert__(self):
        result = ''
        for c in self.get_value():
            if c == '0':
                result += '1'
            elif c == '1':
                result += '0'
            else:
                result += 'x'
        temp_wire = iob_wire('temp', self.width)
        temp_wire.set_value(result)
        return temp_wire

    def __and__(self, other):
        if isinstance(other, iob_wire):
            if self.width != other.width:
                raise ValueError(f'Cannot AND wires of different widths {self.width} and {other.width}')
        else:
            raise ValueError(f'Cannot AND iob_wire and {type(other)}')
        result = ''
        for i in range(self.width):
            if self.get_value()[i] == '1' and other.get_value()[i] == '1':
                result += '1'
            elif self.get_value()[i] == '0' or other.get_value()[i] == '0':
                result += '0'
            else:
                result += 'x'
        temp_wire = iob_wire('temp', self.width)
        temp_wire.set_value(result)
        return temp_wire

    def __or__(self, other):
        if isinstance(other, iob_wire):
            if self.width != other.width:
                raise ValueError(f'Cannot OR wires of different widths {self.width} and {other.width}')
        else:
            raise ValueError(f'Cannot OR iob_wire and {type(other)}')
        result = ''
        for i in range(self.width):
            if self.get_value()[i] == '1' or other.get_value()[i] == '1':
                result += '1'
            elif self.get_value()[i] == '0' and other.get_value()[i] == '0':
                result += '0'
            else:
                result += 'x'
        temp_wire = iob_wire('temp', self.width)
        temp_wire.set_value(result)
        return temp_wire

    def __str__(self):
        return f'{self.name}'
