-- Copyright (c) 2015-2018 in2H2 inc.
-- System developed for in2H2 inc. by Intermotion Technology, Inc.
--
-- Full system RTL, C sources and board design files available at https://github.com/nearist
--
-- in2H2 inc. Team Members:
-- - Chris McCormick - Algorithm Research and Design
-- - Matt McCormick - Board Production, System Q/A
--
-- Intermotion Technology Inc. Team Members:
-- - Mick Fandrich - Project Lead
-- - Dr. Ludovico Minati - Board Architecture and Design, FPGA Technology Advisor
-- - Vardan Movsisyan - RTL Team Lead
-- - Khachatur Gyozalyan - RTL Design
-- - Tigran Papazyan - RTL Design
-- - Taron Harutyunyan - RTL Design
-- - Hayk Ghaltaghchyan - System Software
--
-- Tecno77 S.r.l. Team Members:
-- - Stefano Aldrigo, Board Layout Design
--
-- We dedicate this project to the memory of Bruce McCormick, an AI pioneer
-- and advocate, a good friend and father.
--
-- These materials are provided free of charge: you can redistribute them and/or modify
-- them under the terms of the GNU General Public License as published by
-- the Free Software Foundation, version 3.
--
-- These materials are distributed in the hope that they will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

-----------------------------------------------
-- Top module for artix project including    --
-- xillybus ip core (PCIe to FIFO interface) --
-----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity artix_top_sdr_diff is
port(
  -- PCIe Interface
  pcie_refclk_p            : in  std_logic;
  pcie_refclk_n            : in  std_logic;
  pcie_perst_ls            : in  std_logic;
  pcie_tx_p                : out std_logic_vector(3 downto 0);
  pcie_tx_n                : out std_logic_vector(3 downto 0);
  pcie_rx_p                : in  std_logic_vector(3 downto 0);
  pcie_rx_n                : in  std_logic_vector(3 downto 0);

    -- System clock input 200 mHz
--  sys_clk_sd               : out std_logic;
--  sys_clk_p                : in  std_logic;
--  sys_clk_n                : in  std_logic;

    -- Reference clock input 200 mHz
  clk_ref_p                : in  std_logic;
  clk_ref_n                : in  std_logic;

    -- Parallel interface signals for Lane 0
  lane0_sdr_clk_lr_p_o     : out   std_logic;
  lane0_sdr_clk_lr_n_o     : out   std_logic;
  lane0_sdr_clk_rl_p_i     : in    std_logic;
  lane0_sdr_clk_rl_n_i     : in    std_logic;
  lane0_sdr_data_p_io      : inout std_logic_vector(7 downto 0);
  lane0_sdr_data_n_io      : inout std_logic_vector(7 downto 0);
  lane0_sdr_data_type_p_io : inout std_logic_vector(1 downto 0);
  lane0_sdr_data_type_n_io : inout std_logic_vector(1 downto 0);
  lane0_sdr_dir_o          : out   std_logic;
  lane0_has_data_i         : in    std_logic;
  lane0_ready_io           : inout std_logic;

    -- Parallel interface signals for Lane 1
  lane1_sdr_clk_lr_p_o     : out   std_logic;
  lane1_sdr_clk_lr_n_o     : out   std_logic;
  lane1_sdr_clk_rl_p_i     : in    std_logic;
  lane1_sdr_clk_rl_n_i     : in    std_logic;
  lane1_sdr_data_p_io      : inout std_logic_vector(7 downto 0);
  lane1_sdr_data_n_io      : inout std_logic_vector(7 downto 0);
  lane1_sdr_data_type_p_io : inout std_logic_vector(1 downto 0);
  lane1_sdr_data_type_n_io : inout std_logic_vector(1 downto 0);
  lane1_sdr_dir_o          : out   std_logic;
  lane1_has_data_i         : in    std_logic;
  lane1_ready_io           : inout std_logic;

    -- Parallel interface signals for Lane 2
  lane2_sdr_clk_lr_p_o     : out   std_logic;
  lane2_sdr_clk_lr_n_o     : out   std_logic;
  lane2_sdr_clk_rl_p_i     : in    std_logic;
  lane2_sdr_clk_rl_n_i     : in    std_logic;
  lane2_sdr_data_p_io      : inout std_logic_vector(7 downto 0);
  lane2_sdr_data_n_io      : inout std_logic_vector(7 downto 0);
  lane2_sdr_data_type_p_io : inout std_logic_vector(1 downto 0);
  lane2_sdr_data_type_n_io : inout std_logic_vector(1 downto 0);
  lane2_sdr_dir_o          : out   std_logic;
  lane2_has_data_i         : in    std_logic;
  lane2_ready_io           : inout std_logic;

    -- 21 defferential clock outputs for all ECP5
  cm0_clk_p_o              : out   std_logic;
  cm0_clk_n_o              : out   std_logic;
  cm1_clk_p_o              : out   std_logic;
  cm1_clk_n_o              : out   std_logic;
  cm2_clk_p_o              : out   std_logic;
  cm2_clk_n_o              : out   std_logic;
  cm3_clk_p_o              : out   std_logic;
  cm3_clk_n_o              : out   std_logic;
  cm4_clk_p_o              : out   std_logic;
  cm4_clk_n_o              : out   std_logic;
  cm5_clk_p_o              : out   std_logic;
  cm5_clk_n_o              : out   std_logic;
  cm6_clk_p_o              : out   std_logic;
  cm6_clk_n_o              : out   std_logic;
  cm7_clk_p_o              : out   std_logic;
  cm7_clk_n_o              : out   std_logic;
  cm8_clk_p_o              : out   std_logic;
  cm8_clk_n_o              : out   std_logic;
  cm9_clk_p_o              : out   std_logic;
  cm9_clk_n_o              : out   std_logic;
  cm10_clk_p_o             : out   std_logic;
  cm10_clk_n_o             : out   std_logic;
  cm11_clk_p_o             : out   std_logic;
  cm11_clk_n_o             : out   std_logic;
  cm12_clk_p_o             : out   std_logic;
  cm12_clk_n_o             : out   std_logic;
  cm13_clk_p_o             : out   std_logic;
  cm13_clk_n_o             : out   std_logic;
  cm14_clk_p_o             : out   std_logic;
  cm14_clk_n_o             : out   std_logic;
  cm15_clk_p_o             : out   std_logic;
  cm15_clk_n_o             : out   std_logic;
  cm16_clk_p_o             : out   std_logic;
  cm16_clk_n_o             : out   std_logic;
  cm17_clk_p_o             : out   std_logic;
  cm17_clk_n_o             : out   std_logic;
  cm18_clk_p_o             : out   std_logic;
  cm18_clk_n_o             : out   std_logic;
  cm19_clk_p_o             : out   std_logic;
  cm19_clk_n_o             : out   std_logic;
  cm20_clk_p_o             : out   std_logic;
  cm20_clk_n_o             : out   std_logic;

    -- DDR3 Memory side signals
--  ddr3_mem_clk_p           : out   std_logic;
--  ddr3_mem_clk_n           : out   std_logic;
--  ddr3_mem_addr            : out   std_logic_vector(15 downto 0);
--  ddr3_mem_ba              : out   std_logic_vector(2 downto 0);
--  ddr3_mem_ras_n           : out   std_logic;
--  ddr3_mem_cas_n           : out   std_logic;
--  ddr3_mem_we_n            : out   std_logic;
--  ddr3_mem_cs_n            : out   std_logic_vector(1 downto 0);
--  ddr3_mem_cke             : out   std_logic_vector(1 downto 0);
--  ddr3_mem_odt             : out   std_logic_vector(1 downto 0);
--  ddr3_mem_dm              : out   std_logic_vector(3 downto 0);
--  ddr3_mem_dq              : inout std_logic_vector(31 downto 0);
--  ddr3_mem_dqs_p           : inout std_logic_vector(3 downto 0);
--  ddr3_mem_dqs_n           : inout std_logic_vector(3 downto 0);
--  ddr3_mem_reset_n         : out   std_logic;

    -- SPI Slave interface connected to ATMEGA1284P
--  ipmi_csn_ls_i            : in  std_logic;
--  ipmi_sclk_ls_i           : in  std_logic;
--  ipmi_mosi_ls_i           : in  std_logic;
--  ipmi_miso_ls_o           : out std_logic;

    -- Led Outputs
  led0_red_o               : out std_logic;
  led0_green_o             : out std_logic;
  led0_blue_o              : out std_logic;

    -- SPI Master interface for configuration Lane 0
  cfg0_sck0_ls_o           : out std_logic;
  cfg0_sck1_ls_o           : out std_logic;
  cfg0_sck2_ls_o           : out std_logic;
  cfg0_sck3_ls_o           : out std_logic;
  cfg0_sck4_ls_o           : out std_logic;
  cfg0_sck5_ls_o           : out std_logic;
  cfg0_sck6_ls_o           : out std_logic;
  cfg0_miso_ls_i           : in  std_logic;
  cfg0_mosi_ls_o           : out std_logic;
  cfg0_cs0n_ls_o           : out std_logic;
  cfg0_cs1n_ls_o           : out std_logic;
  cfg0_cs2n_ls_o           : out std_logic;
  cfg0_cs3n_ls_o           : out std_logic;
  cfg0_cs4n_ls_o           : out std_logic;
  cfg0_cs5n_ls_o           : out std_logic;
  cfg0_cs6n_ls_o           : out std_logic;
  cfg0_cs_dir_o            : out std_logic;
  cfg0_programn_ls_o       : out std_logic;

    -- SPI Master interface for configuration Lane 1
  cfg1_sck0_ls_o           : out std_logic;
  cfg1_sck1_ls_o           : out std_logic;
  cfg1_sck2_ls_o           : out std_logic;
  cfg1_sck3_ls_o           : out std_logic;
  cfg1_sck4_ls_o           : out std_logic;
  cfg1_sck5_ls_o           : out std_logic;
  cfg1_sck6_ls_o           : out std_logic;
  cfg1_miso_ls_i           : in  std_logic;
  cfg1_mosi_ls_o           : out std_logic;
  cfg1_cs0n_ls_o           : out std_logic;
  cfg1_cs1n_ls_o           : out std_logic;
  cfg1_cs2n_ls_o           : out std_logic;
  cfg1_cs3n_ls_o           : out std_logic;
  cfg1_cs4n_ls_o           : out std_logic;
  cfg1_cs5n_ls_o           : out std_logic;
  cfg1_cs6n_ls_o           : out std_logic;
  cfg1_cs_dir_o            : out std_logic;
  cfg1_programn_ls_o       : out std_logic;

    -- SPI Master interface for configuration Lane 2
  cfg2_sck0_ls_o           : out std_logic;
  cfg2_sck1_ls_o           : out std_logic;
  cfg2_sck2_ls_o           : out std_logic;
  cfg2_sck3_ls_o           : out std_logic;
  cfg2_sck4_ls_o           : out std_logic;
  cfg2_sck5_ls_o           : out std_logic;
  cfg2_sck6_ls_o           : out std_logic;
  cfg2_miso_ls_i           : in  std_logic;
  cfg2_mosi_ls_o           : out std_logic;
  cfg2_cs0n_ls_o           : out std_logic;
  cfg2_cs1n_ls_o           : out std_logic;
  cfg2_cs2n_ls_o           : out std_logic;
  cfg2_cs3n_ls_o           : out std_logic;
  cfg2_cs4n_ls_o           : out std_logic;
  cfg2_cs5n_ls_o           : out std_logic;
  cfg2_cs6n_ls_o           : out std_logic;
  cfg2_cs_dir_o            : out std_logic;
  cfg2_programn_ls_o       : out std_logic
);
end artix_top_sdr_diff;

architecture rtl of artix_top_sdr_diff is

component xillybus
port (
  pcie_refclk_p         : in  std_logic;
  pcie_refclk_n         : in  std_logic;
  pcie_perst_b_ls       : in  std_logic;
  pcie_tx_p             : out std_logic_vector(3 downto 0);
  pcie_tx_n             : out std_logic_vector(3 downto 0);
  pcie_rx_p             : in  std_logic_vector(3 downto 0);
  pcie_rx_n             : in  std_logic_vector(3 downto 0);
  bus_clk               : out std_logic;
  gpio_led              : out std_logic_vector(3 downto 0);
  quiesce               : out std_logic;

  user_r_read_00_data   : in  std_logic_vector(31 downto 0);
  user_r_read_00_empty  : in  std_logic;
  user_r_read_00_rden   : out std_logic;
  user_r_read_00_eof    : in  std_logic;
  user_r_read_00_open   : out std_logic;
  user_w_write_00_data  : out std_logic_vector(31 downto 0);
  user_w_write_00_full  : in  std_logic;
  user_w_write_00_wren  : out std_logic;
  user_w_write_00_open  : out std_logic;

  user_r_read_01_data   : in  std_logic_vector(31 downto 0);
  user_r_read_01_empty  : in  std_logic;
  user_r_read_01_rden   : out std_logic;
  user_r_read_01_eof    : in  std_logic;
  user_r_read_01_open   : out std_logic;
  user_w_write_01_data  : out std_logic_vector(31 downto 0);
  user_w_write_01_full  : in  std_logic;
  user_w_write_01_wren  : out std_logic;
  user_w_write_01_open  : out std_logic;

  user_r_read_02_data   : in  std_logic_vector(31 downto 0);
  user_r_read_02_empty  : in  std_logic;
  user_r_read_02_rden   : out std_logic;
  user_r_read_02_eof    : in  std_logic;
  user_r_read_02_open   : out std_logic;
  user_w_write_02_data  : out std_logic_vector(31 downto 0);
  user_w_write_02_full  : in  std_logic;
  user_w_write_02_wren  : out std_logic;
  user_w_write_02_open  : out std_logic;

  user_r_read_spi_data  : in  std_logic_vector(31 downto 0);
  user_r_read_spi_empty : in  std_logic;
  user_r_read_spi_rden  : out std_logic;
  user_r_read_spi_eof   : in  std_logic;
  user_r_read_spi_open  : out std_logic;
  user_w_write_spi_data : out std_logic_vector(31 downto 0);
  user_w_write_spi_full : in  std_logic;
  user_w_write_spi_wren : out std_logic;
  user_w_write_spi_open : out std_logic
);
end component;

component artix_core_sdr_diff
port(
    -- System active low reset input
  reset_n_in               : in  std_logic;

    -- System clock input 200 mHz
--  sys_clk_sd               : out std_logic;
--  sys_clk_p                : in  std_logic;
--  sys_clk_n                : in  std_logic;

    -- Reference clock input 200 mHz
  clk_ref_p                : in  std_logic;
  clk_ref_n                : in  std_logic;

    -- Parallel interface signals for Lane 0
  lane0_sdr_clk_lr_p_o     : out   std_logic;
  lane0_sdr_clk_lr_n_o     : out   std_logic;
  lane0_sdr_clk_rl_p_i     : in    std_logic;
  lane0_sdr_clk_rl_n_i     : in    std_logic;
  lane0_sdr_data_p_io      : inout std_logic_vector(7 downto 0);
  lane0_sdr_data_n_io      : inout std_logic_vector(7 downto 0);
  lane0_sdr_data_type_p_io : inout std_logic_vector(1 downto 0);
  lane0_sdr_data_type_n_io : inout std_logic_vector(1 downto 0);
  lane0_sdr_dir_o          : out   std_logic;
  lane0_has_data_i         : in    std_logic;
  lane0_ready_io           : inout std_logic;

    -- Parallel interface signals for Lane 1
  lane1_sdr_clk_lr_p_o     : out   std_logic;
  lane1_sdr_clk_lr_n_o     : out   std_logic;
  lane1_sdr_clk_rl_p_i     : in    std_logic;
  lane1_sdr_clk_rl_n_i     : in    std_logic;
  lane1_sdr_data_p_io      : inout std_logic_vector(7 downto 0);
  lane1_sdr_data_n_io      : inout std_logic_vector(7 downto 0);
  lane1_sdr_data_type_p_io : inout std_logic_vector(1 downto 0);
  lane1_sdr_data_type_n_io : inout std_logic_vector(1 downto 0);
  lane1_sdr_dir_o          : out   std_logic;
  lane1_has_data_i         : in    std_logic;
  lane1_ready_io           : inout std_logic;

    -- Parallel interface signals for Lane 2
  lane2_sdr_clk_lr_p_o     : out   std_logic;
  lane2_sdr_clk_lr_n_o     : out   std_logic;
  lane2_sdr_clk_rl_p_i     : in    std_logic;
  lane2_sdr_clk_rl_n_i     : in    std_logic;
  lane2_sdr_data_p_io      : inout std_logic_vector(7 downto 0);
  lane2_sdr_data_n_io      : inout std_logic_vector(7 downto 0);
  lane2_sdr_data_type_p_io : inout std_logic_vector(1 downto 0);
  lane2_sdr_data_type_n_io : inout std_logic_vector(1 downto 0);
  lane2_sdr_dir_o          : out   std_logic;
  lane2_has_data_i         : in    std_logic;
  lane2_ready_io           : inout std_logic;

    -- 21 defferential clock outputs for all ECP5
  cm0_clk_p_o              : out   std_logic;
  cm0_clk_n_o              : out   std_logic;
  cm1_clk_p_o              : out   std_logic;
  cm1_clk_n_o              : out   std_logic;
  cm2_clk_p_o              : out   std_logic;
  cm2_clk_n_o              : out   std_logic;
  cm3_clk_p_o              : out   std_logic;
  cm3_clk_n_o              : out   std_logic;
  cm4_clk_p_o              : out   std_logic;
  cm4_clk_n_o              : out   std_logic;
  cm5_clk_p_o              : out   std_logic;
  cm5_clk_n_o              : out   std_logic;
  cm6_clk_p_o              : out   std_logic;
  cm6_clk_n_o              : out   std_logic;
  cm7_clk_p_o              : out   std_logic;
  cm7_clk_n_o              : out   std_logic;
  cm8_clk_p_o              : out   std_logic;
  cm8_clk_n_o              : out   std_logic;
  cm9_clk_p_o              : out   std_logic;
  cm9_clk_n_o              : out   std_logic;
  cm10_clk_p_o             : out   std_logic;
  cm10_clk_n_o             : out   std_logic;
  cm11_clk_p_o             : out   std_logic;
  cm11_clk_n_o             : out   std_logic;
  cm12_clk_p_o             : out   std_logic;
  cm12_clk_n_o             : out   std_logic;
  cm13_clk_p_o             : out   std_logic;
  cm13_clk_n_o             : out   std_logic;
  cm14_clk_p_o             : out   std_logic;
  cm14_clk_n_o             : out   std_logic;
  cm15_clk_p_o             : out   std_logic;
  cm15_clk_n_o             : out   std_logic;
  cm16_clk_p_o             : out   std_logic;
  cm16_clk_n_o             : out   std_logic;
  cm17_clk_p_o             : out   std_logic;
  cm17_clk_n_o             : out   std_logic;
  cm18_clk_p_o             : out   std_logic;
  cm18_clk_n_o             : out   std_logic;
  cm19_clk_p_o             : out   std_logic;
  cm19_clk_n_o             : out   std_logic;
  cm20_clk_p_o             : out   std_logic;
  cm20_clk_n_o             : out   std_logic;

    -- DDR3 Memory side signals
--  ddr3_mem_clk_p           : out   std_logic;
--  ddr3_mem_clk_n           : out   std_logic;
--  ddr3_mem_addr            : out   std_logic_vector(15 downto 0);
--  ddr3_mem_ba              : out   std_logic_vector(2 downto 0);
--  ddr3_mem_ras_n           : out   std_logic;
--  ddr3_mem_cas_n           : out   std_logic;
--  ddr3_mem_we_n            : out   std_logic;
--  ddr3_mem_cs_n            : out   std_logic_vector(1 downto 0);
--  ddr3_mem_cke             : out   std_logic_vector(1 downto 0);
--  ddr3_mem_odt             : out   std_logic_vector(1 downto 0);
--  ddr3_mem_dm              : out   std_logic_vector(3 downto 0);
--  ddr3_mem_dq              : inout std_logic_vector(31 downto 0);
--  ddr3_mem_dqs_p           : inout std_logic_vector(3 downto 0);
--  ddr3_mem_dqs_n           : inout std_logic_vector(3 downto 0);
--  ddr3_mem_reset_n         : out   std_logic;

    -- SPI Slave interface connected to ATMEGA1284P
--  ipmi_csn_ls_i            : in  std_logic;
--  ipmi_sclk_ls_i           : in  std_logic;
--  ipmi_mosi_ls_i           : in  std_logic;
--  ipmi_miso_ls_o           : out std_logic;

    -- Led Outputs
  led0_red_o               : out std_logic;
  led0_green_o             : out std_logic;
  led0_blue_o              : out std_logic;

    -- SPI Master interface for configuration Lane 0
  cfg0_sck0_ls_o           : out std_logic;
  cfg0_sck1_ls_o           : out std_logic;
  cfg0_sck2_ls_o           : out std_logic;
  cfg0_sck3_ls_o           : out std_logic;
  cfg0_sck4_ls_o           : out std_logic;
  cfg0_sck5_ls_o           : out std_logic;
  cfg0_sck6_ls_o           : out std_logic;
  cfg0_miso_ls_i           : in  std_logic;
  cfg0_mosi_ls_o           : out std_logic;
  cfg0_cs0n_ls_o           : out std_logic;
  cfg0_cs1n_ls_o           : out std_logic;
  cfg0_cs2n_ls_o           : out std_logic;
  cfg0_cs3n_ls_o           : out std_logic;
  cfg0_cs4n_ls_o           : out std_logic;
  cfg0_cs5n_ls_o           : out std_logic;
  cfg0_cs6n_ls_o           : out std_logic;
  cfg0_cs_dir_o            : out std_logic;
  cfg0_programn_ls_o       : out std_logic;

    -- SPI Master interface for configuration Lane 1
  cfg1_sck0_ls_o           : out std_logic;
  cfg1_sck1_ls_o           : out std_logic;
  cfg1_sck2_ls_o           : out std_logic;
  cfg1_sck3_ls_o           : out std_logic;
  cfg1_sck4_ls_o           : out std_logic;
  cfg1_sck5_ls_o           : out std_logic;
  cfg1_sck6_ls_o           : out std_logic;
  cfg1_miso_ls_i           : in  std_logic;
  cfg1_mosi_ls_o           : out std_logic;
  cfg1_cs0n_ls_o           : out std_logic;
  cfg1_cs1n_ls_o           : out std_logic;
  cfg1_cs2n_ls_o           : out std_logic;
  cfg1_cs3n_ls_o           : out std_logic;
  cfg1_cs4n_ls_o           : out std_logic;
  cfg1_cs5n_ls_o           : out std_logic;
  cfg1_cs6n_ls_o           : out std_logic;
  cfg1_cs_dir_o            : out std_logic;
  cfg1_programn_ls_o       : out std_logic;

    -- SPI Master interface for configuration Lane 2
  cfg2_sck0_ls_o           : out std_logic;
  cfg2_sck1_ls_o           : out std_logic;
  cfg2_sck2_ls_o           : out std_logic;
  cfg2_sck3_ls_o           : out std_logic;
  cfg2_sck4_ls_o           : out std_logic;
  cfg2_sck5_ls_o           : out std_logic;
  cfg2_sck6_ls_o           : out std_logic;
  cfg2_miso_ls_i           : in  std_logic;
  cfg2_mosi_ls_o           : out std_logic;
  cfg2_cs0n_ls_o           : out std_logic;
  cfg2_cs1n_ls_o           : out std_logic;
  cfg2_cs2n_ls_o           : out std_logic;
  cfg2_cs3n_ls_o           : out std_logic;
  cfg2_cs4n_ls_o           : out std_logic;
  cfg2_cs5n_ls_o           : out std_logic;
  cfg2_cs6n_ls_o           : out std_logic;
  cfg2_cs_dir_o            : out std_logic;
  cfg2_programn_ls_o       : out std_logic;

    -- 250 mHz clock input from xillybus
  xil_bus_clk              : in  std_logic;

    -- Xillybus FIFO interface for Lane 0
  xil0_wr_fifo_wr_en_i     : in  std_logic;
  xil0_wr_fifo_din_i       : in  std_logic_vector(31 downto 0);
  xil0_wr_fifo_full_o      : out std_logic;
  xil0_rd_fifo_rd_en_i     : in  std_logic;
  xil0_rd_fifo_dout_o      : out std_logic_vector(31 downto 0);
  xil0_rd_fifo_empty_o     : out std_logic;

    -- Xillybus FIFO interface for Lane 1
  xil1_wr_fifo_wr_en_i     : in  std_logic;
  xil1_wr_fifo_din_i       : in  std_logic_vector(31 downto 0);
  xil1_wr_fifo_full_o      : out std_logic;
  xil1_rd_fifo_rd_en_i     : in  std_logic;
  xil1_rd_fifo_dout_o      : out std_logic_vector(31 downto 0);
  xil1_rd_fifo_empty_o     : out std_logic;

    -- Xillybus FIFO interface for Lane 2
  xil2_wr_fifo_wr_en_i     : in  std_logic;
  xil2_wr_fifo_din_i       : in  std_logic_vector(31 downto 0);
  xil2_wr_fifo_full_o      : out std_logic;
  xil2_rd_fifo_rd_en_i     : in  std_logic;
  xil2_rd_fifo_dout_o      : out std_logic_vector(31 downto 0);
  xil2_rd_fifo_empty_o     : out std_logic;

    -- Xillybus FIFO interface for SPI
  xil_spi_wr_fifo_wr_en_i  : in  std_logic;
  xil_spi_wr_fifo_din_i    : in  std_logic_vector(31 downto 0);
  xil_spi_wr_fifo_full_o   : out std_logic;
  xil_spi_rd_fifo_rd_en_i  : in  std_logic;
  xil_spi_rd_fifo_dout_o   : out std_logic_vector(31 downto 0);
  xil_spi_rd_fifo_empty_o  : out std_logic
);
end component;

signal xil_bus_clk_250             : std_logic;

signal xil_lane0_rd_fifo_dout      : std_logic_vector(31 downto 0);
signal xil_lane0_rd_fifo_empty     : std_logic;
signal xil_lane0_rd_fifo_rd_en     : std_logic;
signal xil_lane0_wr_fifo_din       : std_logic_vector(31 downto 0);
signal xil_lane0_wr_fifo_full      : std_logic;
signal xil_lane0_wr_fifo_wr_en     : std_logic;

signal xil_lane1_rd_fifo_dout      : std_logic_vector(31 downto 0);
signal xil_lane1_rd_fifo_empty     : std_logic;
signal xil_lane1_rd_fifo_rd_en     : std_logic;
signal xil_lane1_wr_fifo_din       : std_logic_vector(31 downto 0);
signal xil_lane1_wr_fifo_full      : std_logic;
signal xil_lane1_wr_fifo_wr_en     : std_logic;

signal xil_lane2_rd_fifo_dout      : std_logic_vector(31 downto 0);
signal xil_lane2_rd_fifo_empty     : std_logic;
signal xil_lane2_rd_fifo_rd_en     : std_logic;
signal xil_lane2_wr_fifo_din       : std_logic_vector(31 downto 0);
signal xil_lane2_wr_fifo_full      : std_logic;
signal xil_lane2_wr_fifo_wr_en     : std_logic;

signal xil_spi_rd_fifo_dout        : std_logic_vector(31 downto 0);
signal xil_spi_rd_fifo_empty       : std_logic;
signal xil_spi_rd_fifo_rd_en       : std_logic;
signal xil_spi_wr_fifo_din         : std_logic_vector(31 downto 0);
signal xil_spi_wr_fifo_full        : std_logic;
signal xil_spi_wr_fifo_wr_en       : std_logic;
signal pcie_perst_b_ls             : std_logic;

begin

pcie_perst_b_ls <= not pcie_perst_ls;

xillybus_inst : xillybus
port map(
  pcie_refclk_p         => pcie_refclk_p,
  pcie_refclk_n         => pcie_refclk_n,
  pcie_perst_b_ls       => pcie_perst_b_ls,
  pcie_tx_p             => pcie_tx_p,
  pcie_tx_n             => pcie_tx_n,
  pcie_rx_p             => pcie_rx_p,
  pcie_rx_n             => pcie_rx_n,
  bus_clk               => xil_bus_clk_250,
  gpio_led              => open,
  quiesce               => open,
  user_r_read_00_data   => xil_lane0_rd_fifo_dout,
  user_r_read_00_empty  => xil_lane0_rd_fifo_empty,
  user_r_read_00_rden   => xil_lane0_rd_fifo_rd_en,
  user_r_read_00_eof    => '0',
  user_r_read_00_open   => open,
  user_w_write_00_data  => xil_lane0_wr_fifo_din,
  user_w_write_00_full  => xil_lane0_wr_fifo_full,
  user_w_write_00_wren  => xil_lane0_wr_fifo_wr_en,
  user_w_write_00_open  => open,
  user_r_read_01_data   => xil_lane1_rd_fifo_dout,
  user_r_read_01_empty  => xil_lane1_rd_fifo_empty,
  user_r_read_01_rden   => xil_lane1_rd_fifo_rd_en,
  user_r_read_01_eof    => '0',
  user_r_read_01_open   => open,
  user_w_write_01_data  => xil_lane1_wr_fifo_din,
  user_w_write_01_full  => xil_lane1_wr_fifo_full,
  user_w_write_01_wren  => xil_lane1_wr_fifo_wr_en,
  user_w_write_01_open  => open,
  user_r_read_02_data   => xil_lane2_rd_fifo_dout,
  user_r_read_02_empty  => xil_lane2_rd_fifo_empty,
  user_r_read_02_rden   => xil_lane2_rd_fifo_rd_en,
  user_r_read_02_eof    => '0',
  user_r_read_02_open   => open,
  user_w_write_02_data  => xil_lane2_wr_fifo_din,
  user_w_write_02_full  => xil_lane2_wr_fifo_full,
  user_w_write_02_wren  => xil_lane2_wr_fifo_wr_en,
  user_w_write_02_open  => open,
  user_r_read_spi_data  => xil_spi_rd_fifo_dout,
  user_r_read_spi_empty => xil_spi_rd_fifo_empty,
  user_r_read_spi_rden  => xil_spi_rd_fifo_rd_en,
  user_r_read_spi_eof   => '0',
  user_r_read_spi_open  => open,
  user_w_write_spi_data => xil_spi_wr_fifo_din,
  user_w_write_spi_full => xil_spi_wr_fifo_full,
  user_w_write_spi_wren => xil_spi_wr_fifo_wr_en,
  user_w_write_spi_open => open
);

artix_core_sdr_diff_0 : artix_core_sdr_diff
port map(
    -- System active low reset input
  reset_n_in               => pcie_perst_b_ls,

    -- System clock input 200 mHz
--  sys_clk_sd               => sys_clk_sd,
--  sys_clk_p                => sys_clk_p,
--  sys_clk_n                => sys_clk_n,

    -- Reference clock input 200 mHz
  clk_ref_p                => clk_ref_p,
  clk_ref_n                => clk_ref_n,

    -- Parallel interface signals for Lane 0
  lane0_sdr_clk_lr_p_o     => lane0_sdr_clk_lr_p_o,
  lane0_sdr_clk_lr_n_o     => lane0_sdr_clk_lr_n_o,
  lane0_sdr_clk_rl_p_i     => lane0_sdr_clk_rl_p_i,
  lane0_sdr_clk_rl_n_i     => lane0_sdr_clk_rl_n_i,
  lane0_sdr_data_p_io      => lane0_sdr_data_p_io,
  lane0_sdr_data_n_io      => lane0_sdr_data_n_io,
  lane0_sdr_data_type_p_io => lane0_sdr_data_type_p_io,
  lane0_sdr_data_type_n_io => lane0_sdr_data_type_n_io,
  lane0_sdr_dir_o          => lane0_sdr_dir_o,
  lane0_has_data_i         => lane0_has_data_i,
  lane0_ready_io           => lane0_ready_io,

    -- Parallel interface signals for Lane 1
  lane1_sdr_clk_lr_p_o     => lane1_sdr_clk_lr_p_o,
  lane1_sdr_clk_lr_n_o     => lane1_sdr_clk_lr_n_o,
  lane1_sdr_clk_rl_p_i     => lane1_sdr_clk_rl_p_i,
  lane1_sdr_clk_rl_n_i     => lane1_sdr_clk_rl_n_i,
  lane1_sdr_data_p_io      => lane1_sdr_data_p_io,
  lane1_sdr_data_n_io      => lane1_sdr_data_n_io,
  lane1_sdr_data_type_p_io => lane1_sdr_data_type_p_io,
  lane1_sdr_data_type_n_io => lane1_sdr_data_type_n_io,
  lane1_sdr_dir_o          => lane1_sdr_dir_o,
  lane1_has_data_i         => lane1_has_data_i,
  lane1_ready_io           => lane1_ready_io,

    -- Parallel interface signals for Lane 2
  lane2_sdr_clk_lr_p_o     => lane2_sdr_clk_lr_p_o,
  lane2_sdr_clk_lr_n_o     => lane2_sdr_clk_lr_n_o,
  lane2_sdr_clk_rl_p_i     => lane2_sdr_clk_rl_p_i,
  lane2_sdr_clk_rl_n_i     => lane2_sdr_clk_rl_n_i,
  lane2_sdr_data_p_io      => lane2_sdr_data_p_io,
  lane2_sdr_data_n_io      => lane2_sdr_data_n_io,
  lane2_sdr_data_type_p_io => lane2_sdr_data_type_p_io,
  lane2_sdr_data_type_n_io => lane2_sdr_data_type_n_io,
  lane2_sdr_dir_o          => lane2_sdr_dir_o,
  lane2_has_data_i         => lane2_has_data_i,
  lane2_ready_io           => lane2_ready_io,

    -- 21 defferential clock outputs for all ECP5
  cm0_clk_p_o              => cm0_clk_p_o,
  cm0_clk_n_o              => cm0_clk_n_o,
  cm1_clk_p_o              => cm1_clk_p_o,
  cm1_clk_n_o              => cm1_clk_n_o,
  cm2_clk_p_o              => cm2_clk_p_o,
  cm2_clk_n_o              => cm2_clk_n_o,
  cm3_clk_p_o              => cm3_clk_p_o,
  cm3_clk_n_o              => cm3_clk_n_o,
  cm4_clk_p_o              => cm4_clk_p_o,
  cm4_clk_n_o              => cm4_clk_n_o,
  cm5_clk_p_o              => cm5_clk_p_o,
  cm5_clk_n_o              => cm5_clk_n_o,
  cm6_clk_p_o              => cm6_clk_p_o,
  cm6_clk_n_o              => cm6_clk_n_o,
  cm7_clk_p_o              => cm7_clk_p_o,
  cm7_clk_n_o              => cm7_clk_n_o,
  cm8_clk_p_o              => cm8_clk_p_o,
  cm8_clk_n_o              => cm8_clk_n_o,
  cm9_clk_p_o              => cm9_clk_p_o,
  cm9_clk_n_o              => cm9_clk_n_o,
  cm10_clk_p_o             => cm10_clk_p_o,
  cm10_clk_n_o             => cm10_clk_n_o,
  cm11_clk_p_o             => cm11_clk_p_o,
  cm11_clk_n_o             => cm11_clk_n_o,
  cm12_clk_p_o             => cm12_clk_p_o,
  cm12_clk_n_o             => cm12_clk_n_o,
  cm13_clk_p_o             => cm13_clk_p_o,
  cm13_clk_n_o             => cm13_clk_n_o,
  cm14_clk_p_o             => cm14_clk_p_o,
  cm14_clk_n_o             => cm14_clk_n_o,
  cm15_clk_p_o             => cm15_clk_p_o,
  cm15_clk_n_o             => cm15_clk_n_o,
  cm16_clk_p_o             => cm16_clk_p_o,
  cm16_clk_n_o             => cm16_clk_n_o,
  cm17_clk_p_o             => cm17_clk_p_o,
  cm17_clk_n_o             => cm17_clk_n_o,
  cm18_clk_p_o             => cm18_clk_p_o,
  cm18_clk_n_o             => cm18_clk_n_o,
  cm19_clk_p_o             => cm19_clk_p_o,
  cm19_clk_n_o             => cm19_clk_n_o,
  cm20_clk_p_o             => cm20_clk_p_o,
  cm20_clk_n_o             => cm20_clk_n_o,

    -- DDR3 Memory side signals
--  ddr3_mem_clk_p           => ddr3_mem_clk_p,
--  ddr3_mem_clk_n           => ddr3_mem_clk_n,
--  ddr3_mem_addr            => ddr3_mem_addr,
--  ddr3_mem_ba              => ddr3_mem_ba,
--  ddr3_mem_ras_n           => ddr3_mem_ras_n,
--  ddr3_mem_cas_n           => ddr3_mem_cas_n,
--  ddr3_mem_we_n            => ddr3_mem_we_n,
--  ddr3_mem_cs_n            => ddr3_mem_cs_n,
--  ddr3_mem_cke             => ddr3_mem_cke,
--  ddr3_mem_odt             => ddr3_mem_odt,
--  ddr3_mem_dm              => ddr3_mem_dm,
--  ddr3_mem_dq              => ddr3_mem_dq,
--  ddr3_mem_dqs_p           => ddr3_mem_dqs_p,
--  ddr3_mem_dqs_n           => ddr3_mem_dqs_n,
--  ddr3_mem_reset_n         => ddr3_mem_reset_n,

    -- SPI Slave interface connected to ATMEGA1284P
--  ipmi_csn_ls_i            => ipmi_csn_ls_i,
--  ipmi_sclk_ls_i           => ipmi_sclk_ls_i,
--  ipmi_mosi_ls_i           => ipmi_mosi_ls_i,
--  ipmi_miso_ls_o           => ipmi_miso_ls_o,

    -- Led Outputs
  led0_red_o               => led0_red_o,
  led0_green_o             => led0_green_o,
  led0_blue_o              => led0_blue_o,

    -- SPI Master interface for configuration Lane 0
  cfg0_sck0_ls_o           => cfg0_sck0_ls_o,
  cfg0_sck1_ls_o           => cfg0_sck1_ls_o,
  cfg0_sck2_ls_o           => cfg0_sck2_ls_o,
  cfg0_sck3_ls_o           => cfg0_sck3_ls_o,
  cfg0_sck4_ls_o           => cfg0_sck4_ls_o,
  cfg0_sck5_ls_o           => cfg0_sck5_ls_o,
  cfg0_sck6_ls_o           => cfg0_sck6_ls_o,
  cfg0_miso_ls_i           => cfg0_miso_ls_i,
  cfg0_mosi_ls_o           => cfg0_mosi_ls_o,
  cfg0_cs0n_ls_o           => cfg0_cs0n_ls_o,
  cfg0_cs1n_ls_o           => cfg0_cs1n_ls_o,
  cfg0_cs2n_ls_o           => cfg0_cs2n_ls_o,
  cfg0_cs3n_ls_o           => cfg0_cs3n_ls_o,
  cfg0_cs4n_ls_o           => cfg0_cs4n_ls_o,
  cfg0_cs5n_ls_o           => cfg0_cs5n_ls_o,
  cfg0_cs6n_ls_o           => cfg0_cs6n_ls_o,
  cfg0_cs_dir_o            => cfg0_cs_dir_o,
  cfg0_programn_ls_o       => cfg0_programn_ls_o,

    -- SPI Master interface for configuration Lane 1
  cfg1_sck0_ls_o           => cfg1_sck0_ls_o,
  cfg1_sck1_ls_o           => cfg1_sck1_ls_o,
  cfg1_sck2_ls_o           => cfg1_sck2_ls_o,
  cfg1_sck3_ls_o           => cfg1_sck3_ls_o,
  cfg1_sck4_ls_o           => cfg1_sck4_ls_o,
  cfg1_sck5_ls_o           => cfg1_sck5_ls_o,
  cfg1_sck6_ls_o           => cfg1_sck6_ls_o,
  cfg1_miso_ls_i           => cfg1_miso_ls_i,
  cfg1_mosi_ls_o           => cfg1_mosi_ls_o,
  cfg1_cs0n_ls_o           => cfg1_cs0n_ls_o,
  cfg1_cs1n_ls_o           => cfg1_cs1n_ls_o,
  cfg1_cs2n_ls_o           => cfg1_cs2n_ls_o,
  cfg1_cs3n_ls_o           => cfg1_cs3n_ls_o,
  cfg1_cs4n_ls_o           => cfg1_cs4n_ls_o,
  cfg1_cs5n_ls_o           => cfg1_cs5n_ls_o,
  cfg1_cs6n_ls_o           => cfg1_cs6n_ls_o,
  cfg1_cs_dir_o            => cfg1_cs_dir_o,
  cfg1_programn_ls_o       => cfg1_programn_ls_o,

    -- SPI Master interface for configuration Lane 2
  cfg2_sck0_ls_o           => cfg2_sck0_ls_o,
  cfg2_sck1_ls_o           => cfg2_sck1_ls_o,
  cfg2_sck2_ls_o           => cfg2_sck2_ls_o,
  cfg2_sck3_ls_o           => cfg2_sck3_ls_o,
  cfg2_sck4_ls_o           => cfg2_sck4_ls_o,
  cfg2_sck5_ls_o           => cfg2_sck5_ls_o,
  cfg2_sck6_ls_o           => cfg2_sck6_ls_o,
  cfg2_miso_ls_i           => cfg2_miso_ls_i,
  cfg2_mosi_ls_o           => cfg2_mosi_ls_o,
  cfg2_cs0n_ls_o           => cfg2_cs0n_ls_o,
  cfg2_cs1n_ls_o           => cfg2_cs1n_ls_o,
  cfg2_cs2n_ls_o           => cfg2_cs2n_ls_o,
  cfg2_cs3n_ls_o           => cfg2_cs3n_ls_o,
  cfg2_cs4n_ls_o           => cfg2_cs4n_ls_o,
  cfg2_cs5n_ls_o           => cfg2_cs5n_ls_o,
  cfg2_cs6n_ls_o           => cfg2_cs6n_ls_o,
  cfg2_cs_dir_o            => cfg2_cs_dir_o,
  cfg2_programn_ls_o       => cfg2_programn_ls_o,

    -- 250 mHz clock input from xillybus
  xil_bus_clk              => xil_bus_clk_250,

    -- Xillybus FIFO interface for Lane 0
  xil0_wr_fifo_wr_en_i     => xil_lane0_wr_fifo_wr_en,
  xil0_wr_fifo_din_i       => xil_lane0_wr_fifo_din,
  xil0_wr_fifo_full_o      => xil_lane0_wr_fifo_full,
  xil0_rd_fifo_rd_en_i     => xil_lane0_rd_fifo_rd_en,
  xil0_rd_fifo_dout_o      => xil_lane0_rd_fifo_dout,
  xil0_rd_fifo_empty_o     => xil_lane0_rd_fifo_empty,

    -- Xillybus FIFO interface for Lane 1
  xil1_wr_fifo_wr_en_i     => xil_lane1_wr_fifo_wr_en,
  xil1_wr_fifo_din_i       => xil_lane1_wr_fifo_din,
  xil1_wr_fifo_full_o      => xil_lane1_wr_fifo_full,
  xil1_rd_fifo_rd_en_i     => xil_lane1_rd_fifo_rd_en,
  xil1_rd_fifo_dout_o      => xil_lane1_rd_fifo_dout,
  xil1_rd_fifo_empty_o     => xil_lane1_rd_fifo_empty,

    -- Xillybus FIFO interface for Lane 2
  xil2_wr_fifo_wr_en_i     => xil_lane2_wr_fifo_wr_en,
  xil2_wr_fifo_din_i       => xil_lane2_wr_fifo_din,
  xil2_wr_fifo_full_o      => xil_lane2_wr_fifo_full,
  xil2_rd_fifo_rd_en_i     => xil_lane2_rd_fifo_rd_en,
  xil2_rd_fifo_dout_o      => xil_lane2_rd_fifo_dout,
  xil2_rd_fifo_empty_o     => xil_lane2_rd_fifo_empty,

    -- Xillybus FIFO interface for SPI
  xil_spi_wr_fifo_wr_en_i  => xil_spi_wr_fifo_wr_en,
  xil_spi_wr_fifo_din_i    => xil_spi_wr_fifo_din,
  xil_spi_wr_fifo_full_o   => xil_spi_wr_fifo_full,
  xil_spi_rd_fifo_rd_en_i  => xil_spi_rd_fifo_rd_en,
  xil_spi_rd_fifo_dout_o   => xil_spi_rd_fifo_dout,
  xil_spi_rd_fifo_empty_o  => xil_spi_rd_fifo_empty
);

end rtl;
