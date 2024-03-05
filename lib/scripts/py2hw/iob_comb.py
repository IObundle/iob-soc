from dataclasses import dataclass
from typing import List

from iob_module import iob_module
from iob_wire import iob_wire
from iob_port import iob_port


@dataclass
class iob_comb(iob_module):
    """Class for a combinational logic module"""
    name: str
    ios: List[iob_port]
    wires: List[iob_wire]
    instances: List[iob_module]  # List of instances to include
    description: str = "Combinational logic module"


    def __post_init__(self):
        for name,info in wire_lists.items():
            wire = iob_wire.create_list(name=name, width=info['width'], num=info['num'])
            setattr(self, name, wire)
        for inst_name, inst_info in instances.items():
            port_map = inst_info['port_map']
            if len(port_map) != len(inst_info['module'].ports):
                raise ValueError(f"Port map for instance {inst_name} is not the expected size")
            for name, info in inst_info['module'].ports.items():
                if name not in port_map:
                    raise ValueError(f"Port {name} is missing for instance {inst_name}")
                if isinstance(info['width'],str):
                    width = inst_info['param_dict'][info['width']]
                elif not isinstance(info['width'],int):
                    raise ValueError(f"Port {name} width is not valid for instance {inst_name}")
                else:
                    width = info['width']
                if isinstance(port_map[name],list):
                    new_port_map = {name:[]}
                    for name, list_range in portmap[name].items():
                        if getattr(self,name) is None:
                            raise ValueError(f"No port or wire list named {name} exists")
                        if not isinstance(getattr(self,name),list):
                            raise ValueError(f"Attribute {name} is not a list")
                        if not isinstance(getattr(self,name)[0],iob_wire):
                            raise ValueError(f"Attribute {name} is not a list of wires/ports")
                        if isinstance(getattr(self,name)[0],iob_port):
                            if getattr(self,name)[0].direction != info['direction']:
                                raise ValueError(f"Attribute {name} is not a list of {info['direction']} ports")
                        new_port_map[name].append(getattr(self,name)[list_range[0]:list_range[1]+1])  
                    port_map[name] = new_port_map[name]
                else:    
                    raise ValueError(f"Port {name} is not a list for instance {inst_name}")
            lenght = None
            for name, items in port_map.items():
                if length is None:
                    length = len(items)
                elif length != len(items):
                    raise ValueError(f"Port {name} list is not the same length for instance {inst_name}")
            for i in range(length):
                inst_name = f"{inst_name}_{i}"
                inst_port_map = {}
                for name, items in port_map.items():
                    inst_port_map[name] = items[i]
                self.inst_list.append(inst_info['module'].create(inst_name, inst_info['param_dict'], inst_port_map, inst_info['description']))
