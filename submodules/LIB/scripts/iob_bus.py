from dataclasses import dataclass, field
from typing import List, Optional, TextIO, Literal


@dataclass
class signal:
    name: str
    width: str


@dataclass
class localparam:
    name: str
    value: str


@dataclass
class iob_bus:
    file_prefix: str = ""
    bus_prefix: str = ""
    addr_width: str = "ADDR_W"
    data_width: str = "DATA_W"
    n_buses: int = 1
    bus_names: Optional[List[str]] = None

    # True: req/resp buses are module IO ports
    # False: req/resp buses are module wires/signals
    is_IO: bool = False

    # bus2native: generate logic from req -> iob signals
    # native2bus: generate logic from iob signals -> req
    # resp logic is always inverse from req logic
    logic: Literal["bus2native", "native2bus"] = "bus2native"

    # Optional flag to skip logic generation
    skip: List[str] = field(default_factory=list)

    __req_str: str = "req"
    __resp_str: str = "resp"

    def __post_init__(self) -> None:
        if self.is_IO:
            if self.logic == "bus2native":
                self.__req_str = "req_i"
                self.__resp_str = "resp_o"
            else:
                self.__req_str = "req_o"
                self.__resp_str = "resp_i"
        if self.bus_names is None:
            self.bus_names = []
            for i in range(self.n_buses):
                self.bus_names.append(f"{i}")
        else:
            self.n_buses = len(self.bus_names)

        self.req_signals: List[List[signal]] = []
        self.resp_signals: List[List[signal]] = []
        for bus_name in self.bus_names:
            bus_signal_prefix = f"{self.bus_prefix}_{bus_name}"
            # Note: add signals from lsb to msb, simpler signal ranges
            self.req_signals += [
                [
                    signal(f"{bus_signal_prefix}_req_wstrb", f"{self.data_width}/8"),
                    signal(f"{bus_signal_prefix}_req_wdata", self.data_width),
                    signal(f"{bus_signal_prefix}_req_addr", self.addr_width),
                    signal(f"{bus_signal_prefix}_req_valid", "1"),
                ]
            ]
            self.resp_signals += [
                [
                    signal(f"{bus_signal_prefix}_resp_ready", "1"),
                    signal(f"{bus_signal_prefix}_resp_rvalid", "1"),
                    signal(f"{bus_signal_prefix}_resp_rdata", self.data_width),
                ]
            ]
        self.__req_width: localparam = localparam(
            name=f"{self.bus_prefix.upper()}_REQ_W",
            value=self.calc_subbus_width(self.req_signals[0]),
        )
        self.__resp_width: localparam = localparam(
            name=f"{self.bus_prefix.upper()}_RESP_W",
            value=self.calc_subbus_width(self.resp_signals[0]),
        )

    def calc_subbus_width(self, signals: List[signal]) -> str:
        width = ""
        for signal in signals:
            if width == "":
                width = f"{signal.width}"
            else:
                width = f"{width}+{signal.width}"
        return width

    def declare_wires(self, fout: TextIO) -> None:
        fout.write(
            f"\tlocalparam {self.__req_width.name} = {self.__req_width.value};\n"
        )
        fout.write(
            f"\tlocalparam {self.__resp_width.name} = {self.__resp_width.value};\n"
        )
        if not self.is_IO:
            req_width = f"{self.n_buses}*({self.__req_width.name})"
            fout.write(f"\twire [{req_width}-1:0] {self.bus_prefix}_req;\n")
            resp_width = f"{self.n_buses}*({self.__resp_width.name})"
            fout.write(f"\twire [{resp_width}-1:0] {self.bus_prefix}_resp;\n\n")

        if "req" not in self.skip:
            for subbus in self.req_signals:
                for signal in subbus:
                    fout.write(f"\twire [{signal.width}-1:0] {signal.name};\n")
            fout.write("\n")
        if "resp" not in self.skip:
            for subbus in self.resp_signals:
                for signal in subbus:
                    fout.write(f"\twire [{signal.width}-1:0] {signal.name};\n")
            fout.write("\n")

    def generate_bus2native_logic(
        self, fout: TextIO, buses: List[List[signal]], req_resp: str, subbus_width: str
    ) -> None:
        subbus_idx = 0
        for subbus in buses:
            subbus_range_prefix = f"{subbus_idx}*({subbus_width})"
            cur_width = ""
            for signal in subbus:
                if cur_width == "":
                    subbus_ptr = f"{subbus_range_prefix}"
                else:
                    subbus_ptr = f"{subbus_range_prefix}+({cur_width})"
                bit_range = f"{subbus_ptr}+{signal.width}-1:{subbus_ptr}"
                bus_name = f"{self.bus_prefix}_{req_resp}"
                fout.write(f"\tassign {signal.name} = {bus_name}[{bit_range}];\n")
                if cur_width == "":
                    cur_width = signal.width
                else:
                    cur_width = f"{cur_width}+{signal.width}"
            subbus_idx += 1
        fout.write("\n")

    def generate_native2bus_logic(
        self, fout: TextIO, buses: List[List[signal]], req_resp: str
    ) -> None:
        fout.write(f"\tassign {self.bus_prefix}_{req_resp} = {{\n")
        first_line = True
        # reverse: verilog concatenation is from msb to lsb
        for subbus in reversed(buses):
            for signal in reversed(subbus):
                if first_line:
                    fout.write(f"\t\t{signal.name}")
                else:
                    fout.write(f",\n\t\t{signal.name}")
                first_line = False
        fout.write("\n\t};\n\n")

    def generate_logic(self, fout: TextIO) -> None:
        if self.logic == "bus2native":
            if "req" not in self.skip:
                self.generate_bus2native_logic(
                    fout, self.req_signals, self.__req_str, self.__req_width.name
                )
            if "resp" not in self.skip:
                self.generate_native2bus_logic(fout, self.resp_signals, self.__resp_str)
        elif self.logic == "native2bus":
            if "req" not in self.skip:
                self.generate_native2bus_logic(fout, self.req_signals, self.__req_str)
            if "resp" not in self.skip:
                self.generate_bus2native_logic(
                    fout, self.resp_signals, self.__resp_str, self.__resp_width.name
                )

    def generate_code(self, out_dir: str = "") -> None:
        fout_name = f"{self.file_prefix}_iob_bus.vs"
        if out_dir != "":
            fout_name = f"{out_dir}/{fout_name}"
        with open(fout_name, "w") as fout:
            self.declare_wires(fout)
            self.generate_logic(fout)


# Manually test iob_bus module: python path/to/iob_bus.py
if __name__ == "__main__":
    print("iob_bus module")
    iob_bus(
        file_prefix="test_file",
        bus_prefix="test_bus",
        addr_width="TEST_ADDR_W",  # "ADDR_W",
        data_width="TEST_DATA_W",  # "DATA_W",
        n_buses=2,  # ignored if bus_names is set
        bus_names=["UART", "TIMER"],
        is_IO=False,
        logic="bus2native",  # bus2native or native2bus
        skip=[],  # ["req", "resp"]
    ).generate_code()
