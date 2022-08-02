	component pcie is
		port (
			clk_clk                 : in  std_logic                     := 'X';             -- clk
			reset_reset_n           : in  std_logic                     := 'X';             -- reset_n
			axi_bridge_0_s0_awid    : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- awid
			axi_bridge_0_s0_awaddr  : in  std_logic_vector(10 downto 0) := (others => 'X'); -- awaddr
			axi_bridge_0_s0_awlen   : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- awlen
			axi_bridge_0_s0_awsize  : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- awsize
			axi_bridge_0_s0_awburst : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- awburst
			axi_bridge_0_s0_awlock  : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- awlock
			axi_bridge_0_s0_awcache : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- awcache
			axi_bridge_0_s0_awprot  : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- awprot
			axi_bridge_0_s0_awvalid : in  std_logic                     := 'X';             -- awvalid
			axi_bridge_0_s0_awready : out std_logic;                                        -- awready
			axi_bridge_0_s0_wid     : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- wid
			axi_bridge_0_s0_wdata   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- wdata
			axi_bridge_0_s0_wstrb   : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- wstrb
			axi_bridge_0_s0_wlast   : in  std_logic                     := 'X';             -- wlast
			axi_bridge_0_s0_wvalid  : in  std_logic                     := 'X';             -- wvalid
			axi_bridge_0_s0_wready  : out std_logic;                                        -- wready
			axi_bridge_0_s0_bid     : out std_logic_vector(7 downto 0);                     -- bid
			axi_bridge_0_s0_bresp   : out std_logic_vector(1 downto 0);                     -- bresp
			axi_bridge_0_s0_bvalid  : out std_logic;                                        -- bvalid
			axi_bridge_0_s0_bready  : in  std_logic                     := 'X';             -- bready
			axi_bridge_0_s0_arid    : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- arid
			axi_bridge_0_s0_araddr  : in  std_logic_vector(10 downto 0) := (others => 'X'); -- araddr
			axi_bridge_0_s0_arlen   : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- arlen
			axi_bridge_0_s0_arsize  : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- arsize
			axi_bridge_0_s0_arburst : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- arburst
			axi_bridge_0_s0_arlock  : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- arlock
			axi_bridge_0_s0_arcache : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- arcache
			axi_bridge_0_s0_arprot  : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- arprot
			axi_bridge_0_s0_arvalid : in  std_logic                     := 'X';             -- arvalid
			axi_bridge_0_s0_arready : out std_logic;                                        -- arready
			axi_bridge_0_s0_rid     : out std_logic_vector(7 downto 0);                     -- rid
			axi_bridge_0_s0_rdata   : out std_logic_vector(31 downto 0);                    -- rdata
			axi_bridge_0_s0_rresp   : out std_logic_vector(1 downto 0);                     -- rresp
			axi_bridge_0_s0_rlast   : out std_logic;                                        -- rlast
			axi_bridge_0_s0_rvalid  : out std_logic;                                        -- rvalid
			axi_bridge_0_s0_rready  : in  std_logic                     := 'X'              -- rready
		);
	end component pcie;

	u0 : component pcie
		port map (
			clk_clk                 => CONNECTED_TO_clk_clk,                 --             clk.clk
			reset_reset_n           => CONNECTED_TO_reset_reset_n,           --           reset.reset_n
			axi_bridge_0_s0_awid    => CONNECTED_TO_axi_bridge_0_s0_awid,    -- axi_bridge_0_s0.awid
			axi_bridge_0_s0_awaddr  => CONNECTED_TO_axi_bridge_0_s0_awaddr,  --                .awaddr
			axi_bridge_0_s0_awlen   => CONNECTED_TO_axi_bridge_0_s0_awlen,   --                .awlen
			axi_bridge_0_s0_awsize  => CONNECTED_TO_axi_bridge_0_s0_awsize,  --                .awsize
			axi_bridge_0_s0_awburst => CONNECTED_TO_axi_bridge_0_s0_awburst, --                .awburst
			axi_bridge_0_s0_awlock  => CONNECTED_TO_axi_bridge_0_s0_awlock,  --                .awlock
			axi_bridge_0_s0_awcache => CONNECTED_TO_axi_bridge_0_s0_awcache, --                .awcache
			axi_bridge_0_s0_awprot  => CONNECTED_TO_axi_bridge_0_s0_awprot,  --                .awprot
			axi_bridge_0_s0_awvalid => CONNECTED_TO_axi_bridge_0_s0_awvalid, --                .awvalid
			axi_bridge_0_s0_awready => CONNECTED_TO_axi_bridge_0_s0_awready, --                .awready
			axi_bridge_0_s0_wid     => CONNECTED_TO_axi_bridge_0_s0_wid,     --                .wid
			axi_bridge_0_s0_wdata   => CONNECTED_TO_axi_bridge_0_s0_wdata,   --                .wdata
			axi_bridge_0_s0_wstrb   => CONNECTED_TO_axi_bridge_0_s0_wstrb,   --                .wstrb
			axi_bridge_0_s0_wlast   => CONNECTED_TO_axi_bridge_0_s0_wlast,   --                .wlast
			axi_bridge_0_s0_wvalid  => CONNECTED_TO_axi_bridge_0_s0_wvalid,  --                .wvalid
			axi_bridge_0_s0_wready  => CONNECTED_TO_axi_bridge_0_s0_wready,  --                .wready
			axi_bridge_0_s0_bid     => CONNECTED_TO_axi_bridge_0_s0_bid,     --                .bid
			axi_bridge_0_s0_bresp   => CONNECTED_TO_axi_bridge_0_s0_bresp,   --                .bresp
			axi_bridge_0_s0_bvalid  => CONNECTED_TO_axi_bridge_0_s0_bvalid,  --                .bvalid
			axi_bridge_0_s0_bready  => CONNECTED_TO_axi_bridge_0_s0_bready,  --                .bready
			axi_bridge_0_s0_arid    => CONNECTED_TO_axi_bridge_0_s0_arid,    --                .arid
			axi_bridge_0_s0_araddr  => CONNECTED_TO_axi_bridge_0_s0_araddr,  --                .araddr
			axi_bridge_0_s0_arlen   => CONNECTED_TO_axi_bridge_0_s0_arlen,   --                .arlen
			axi_bridge_0_s0_arsize  => CONNECTED_TO_axi_bridge_0_s0_arsize,  --                .arsize
			axi_bridge_0_s0_arburst => CONNECTED_TO_axi_bridge_0_s0_arburst, --                .arburst
			axi_bridge_0_s0_arlock  => CONNECTED_TO_axi_bridge_0_s0_arlock,  --                .arlock
			axi_bridge_0_s0_arcache => CONNECTED_TO_axi_bridge_0_s0_arcache, --                .arcache
			axi_bridge_0_s0_arprot  => CONNECTED_TO_axi_bridge_0_s0_arprot,  --                .arprot
			axi_bridge_0_s0_arvalid => CONNECTED_TO_axi_bridge_0_s0_arvalid, --                .arvalid
			axi_bridge_0_s0_arready => CONNECTED_TO_axi_bridge_0_s0_arready, --                .arready
			axi_bridge_0_s0_rid     => CONNECTED_TO_axi_bridge_0_s0_rid,     --                .rid
			axi_bridge_0_s0_rdata   => CONNECTED_TO_axi_bridge_0_s0_rdata,   --                .rdata
			axi_bridge_0_s0_rresp   => CONNECTED_TO_axi_bridge_0_s0_rresp,   --                .rresp
			axi_bridge_0_s0_rlast   => CONNECTED_TO_axi_bridge_0_s0_rlast,   --                .rlast
			axi_bridge_0_s0_rvalid  => CONNECTED_TO_axi_bridge_0_s0_rvalid,  --                .rvalid
			axi_bridge_0_s0_rready  => CONNECTED_TO_axi_bridge_0_s0_rready   --                .rready
		);

