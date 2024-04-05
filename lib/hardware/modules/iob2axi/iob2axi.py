from iob_core import iob_core


class iob2axi(iob_core):
    def __init__(self, *args, **kwargs):
        self.set_default_attribute("version", "0.1")
        self.set_default_attribute("generate_hw", False)

        self.create_instance(
            "m_axi_m_port",
            "m_axi_m_port_inst",
        )

        self.create_instance(
            "m_axi_write_m_port",
            "m_axi_write_m_port_inst",
        )

        self.create_instance(
            "m_axi_read_m_port",
            "m_axi_read_m_port_inst",
        )

        self.create_instance(
            "m_m_axi_write_portmap",
            "m_m_axi_write_portmap_inst",
        )

        self.create_instance(
            "m_m_axi_read_portmap",
            "m_m_axi_read_portmap_inst",
        )

        self.create_instance(
            "iob2axi_wr",
            "iob2axi_wr_inst",
        )

        self.create_instance(
            "iob2axi_rd",
            "iob2axi_rd_inst",
        )

        self.create_instance(
            "iob_fifo_sync",
            "iob_fifo_sync_inst",
        )

        super().__init__(*args, **kwargs)
