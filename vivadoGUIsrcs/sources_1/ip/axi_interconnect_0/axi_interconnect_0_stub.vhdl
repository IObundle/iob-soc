-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
-- Date        : Mon Aug 26 16:23:53 2019
-- Host        : baba-de-camelo running 64-bit unknown
-- Command     : write_vhdl -force -mode synth_stub
--               /home/pmiranda/Documents/project_1/project_1.srcs/sources_1/ip/axi_interconnect_0/axi_interconnect_0_stub.vhdl
-- Design      : axi_interconnect_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku040-fbva676-1-c
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi_interconnect_0 is
  Port ( 
    INTERCONNECT_ACLK : in STD_LOGIC;
    INTERCONNECT_ARESETN : in STD_LOGIC;
    S00_AXI_ARESET_OUT_N : out STD_LOGIC;
    S00_AXI_ACLK : in STD_LOGIC;
    S00_AXI_AWID : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_AWLOCK : in STD_LOGIC;
    S00_AXI_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_AWVALID : in STD_LOGIC;
    S00_AXI_AWREADY : out STD_LOGIC;
    S00_AXI_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_WLAST : in STD_LOGIC;
    S00_AXI_WVALID : in STD_LOGIC;
    S00_AXI_WREADY : out STD_LOGIC;
    S00_AXI_BID : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_BVALID : out STD_LOGIC;
    S00_AXI_BREADY : in STD_LOGIC;
    S00_AXI_ARID : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_ARLOCK : in STD_LOGIC;
    S00_AXI_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_ARVALID : in STD_LOGIC;
    S00_AXI_ARREADY : out STD_LOGIC;
    S00_AXI_RID : out STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_RLAST : out STD_LOGIC;
    S00_AXI_RVALID : out STD_LOGIC;
    S00_AXI_RREADY : in STD_LOGIC;
    M00_AXI_ARESET_OUT_N : out STD_LOGIC;
    M00_AXI_ACLK : in STD_LOGIC;
    M00_AXI_AWID : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_AWLOCK : out STD_LOGIC;
    M00_AXI_AWCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_AWQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_AWVALID : out STD_LOGIC;
    M00_AXI_AWREADY : in STD_LOGIC;
    M00_AXI_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_WLAST : out STD_LOGIC;
    M00_AXI_WVALID : out STD_LOGIC;
    M00_AXI_WREADY : in STD_LOGIC;
    M00_AXI_BID : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_BVALID : in STD_LOGIC;
    M00_AXI_BREADY : out STD_LOGIC;
    M00_AXI_ARID : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_ARLOCK : out STD_LOGIC;
    M00_AXI_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_ARVALID : out STD_LOGIC;
    M00_AXI_ARREADY : in STD_LOGIC;
    M00_AXI_RID : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_RLAST : in STD_LOGIC;
    M00_AXI_RVALID : in STD_LOGIC;
    M00_AXI_RREADY : out STD_LOGIC
  );

end axi_interconnect_0;

architecture stub of axi_interconnect_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "INTERCONNECT_ACLK,INTERCONNECT_ARESETN,S00_AXI_ARESET_OUT_N,S00_AXI_ACLK,S00_AXI_AWID[0:0],S00_AXI_AWADDR[31:0],S00_AXI_AWLEN[7:0],S00_AXI_AWSIZE[2:0],S00_AXI_AWBURST[1:0],S00_AXI_AWLOCK,S00_AXI_AWCACHE[3:0],S00_AXI_AWPROT[2:0],S00_AXI_AWQOS[3:0],S00_AXI_AWVALID,S00_AXI_AWREADY,S00_AXI_WDATA[31:0],S00_AXI_WSTRB[3:0],S00_AXI_WLAST,S00_AXI_WVALID,S00_AXI_WREADY,S00_AXI_BID[0:0],S00_AXI_BRESP[1:0],S00_AXI_BVALID,S00_AXI_BREADY,S00_AXI_ARID[0:0],S00_AXI_ARADDR[31:0],S00_AXI_ARLEN[7:0],S00_AXI_ARSIZE[2:0],S00_AXI_ARBURST[1:0],S00_AXI_ARLOCK,S00_AXI_ARCACHE[3:0],S00_AXI_ARPROT[2:0],S00_AXI_ARQOS[3:0],S00_AXI_ARVALID,S00_AXI_ARREADY,S00_AXI_RID[0:0],S00_AXI_RDATA[31:0],S00_AXI_RRESP[1:0],S00_AXI_RLAST,S00_AXI_RVALID,S00_AXI_RREADY,M00_AXI_ARESET_OUT_N,M00_AXI_ACLK,M00_AXI_AWID[3:0],M00_AXI_AWADDR[31:0],M00_AXI_AWLEN[7:0],M00_AXI_AWSIZE[2:0],M00_AXI_AWBURST[1:0],M00_AXI_AWLOCK,M00_AXI_AWCACHE[3:0],M00_AXI_AWPROT[2:0],M00_AXI_AWQOS[3:0],M00_AXI_AWVALID,M00_AXI_AWREADY,M00_AXI_WDATA[31:0],M00_AXI_WSTRB[3:0],M00_AXI_WLAST,M00_AXI_WVALID,M00_AXI_WREADY,M00_AXI_BID[3:0],M00_AXI_BRESP[1:0],M00_AXI_BVALID,M00_AXI_BREADY,M00_AXI_ARID[3:0],M00_AXI_ARADDR[31:0],M00_AXI_ARLEN[7:0],M00_AXI_ARSIZE[2:0],M00_AXI_ARBURST[1:0],M00_AXI_ARLOCK,M00_AXI_ARCACHE[3:0],M00_AXI_ARPROT[2:0],M00_AXI_ARQOS[3:0],M00_AXI_ARVALID,M00_AXI_ARREADY,M00_AXI_RID[3:0],M00_AXI_RDATA[31:0],M00_AXI_RRESP[1:0],M00_AXI_RLAST,M00_AXI_RVALID,M00_AXI_RREADY";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axi_interconnect_v1_7_15_top,Vivado 2018.3";
begin
end;
