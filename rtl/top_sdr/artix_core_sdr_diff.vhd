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

-----------------------------------------------------------
-- High level module instanced in artix_top_sdr module,  --
-- including clock wizard, slave FPGAs clock generator,  --
-- SPI master for slave FPGAs programming,               --
-- Parallel interfaces and Packet layer for three Lanes. --
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity artix_core_sdr_diff is
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
end artix_core_sdr_diff;

architecture rtl of artix_core_sdr_diff is

component clk_wiz_main
port(
  reset     : in  std_logic;
  clk_in1_p : in  std_logic;
  clk_in1_n : in  std_logic;
  locked    : out std_logic;
  clk_out1  : out std_logic;
  clk_out2  : out std_logic;
  clk_out3  : out std_logic;
  clk_out4  : out std_logic;
  clk_out5  : out std_logic
);
end component;

component parallel_if_sdr_diff
port(
  clk_fifo_if           : in    std_logic;
  clk_par_if            : in    std_logic;
  clk_par_if_n          : in    std_logic;
  reset_n               : in    std_logic;

  -- Parallel interface signals  (Connect directly to pads)
  sdr_clk_lr_p_o        : out   std_logic;
  sdr_clk_lr_n_o        : out   std_logic;
  sdr_clk_rl_p_i        : in    std_logic;
  sdr_clk_rl_n_i        : in    std_logic;
  sdr_data_p_io         : inout std_logic_vector(7 downto 0);
  sdr_data_n_io         : inout std_logic_vector(7 downto 0);
  sdr_data_type_p_io    : inout std_logic_vector(1 downto 0);
  sdr_data_type_n_io    : inout std_logic_vector(1 downto 0);
  sdr_dir_o             : out   std_logic;
  has_data_i            : in    std_logic;
  ready_io              : inout std_logic;

  -- FIFO  interface signals
  ds_fifo_dout_o        : out   std_logic_vector(35 downto 0);
  ds_fifo_rd_en_i       : in    std_logic;
  ds_fifo_empty_o       : out   std_logic;

  us_fifo_din_i         : in    std_logic_vector(35 downto 0);
  us_fifo_wr_en_i       : in    std_logic;
  us_fifo_full_o        : out   std_logic
);
end component;

component us_packet_tx
port(
  clk                 : in  std_logic;
  reset_n             : in  std_logic;

  us_fifo_din_o       : out std_logic_vector(35 downto 0);
  us_fifo_wr_en_o     : out std_logic;
  us_fifo_full_i      : in  std_logic;

  xil_fifo_dout_i     : in  std_logic_vector(31 downto 0);
  xil_fifo_rd_en_o    : out std_logic;
  xil_fifo_rd_empty_i : in  std_logic
);
end component;

component ds_packet_rx
port(
  clk                 : in  std_logic;
  reset_n             : in  std_logic;

  ds_fifo_dout_i      : in  std_logic_vector(35 downto 0);
  ds_fifo_rd_en_o     : out std_logic;
  ds_fifo_empty_i     : in  std_logic;

  xil_fifo_din_o      : out std_logic_vector(31 downto 0);
  xil_fifo_wr_en_o    : out std_logic;
  xil_fifo_rd_full_i  : in  std_logic
);
end component;

component fifo_xil_rd
port(
  rst               : in  std_logic;
  wr_clk            : in  std_logic;
  rd_clk            : in  std_logic;
  din               : in  std_logic_vector(31 downto 0);
  wr_en             : in  std_logic;
  rd_en             : in  std_logic;
  dout              : out std_logic_vector(31 downto 0);
  full              : out std_logic;
  empty             : out std_logic
);
end component;

component fifo_xil_wr
port(
  rst               : in  std_logic;
  wr_clk            : in  std_logic;
  rd_clk            : in  std_logic;
  din               : in  std_logic_vector(31 downto 0);
  wr_en             : in  std_logic;
  rd_en             : in  std_logic;
  dout              : out std_logic_vector(31 downto 0);
  full              : out std_logic;
  empty             : out std_logic
);
end component;

component fifo_xil_rd_spi
port(
  rst               : in  std_logic;
  wr_clk            : in  std_logic;
  rd_clk            : in  std_logic;
  din               : in  std_logic_vector(31 downto 0);
  wr_en             : in  std_logic;
  rd_en             : in  std_logic;
  dout              : out std_logic_vector(31 downto 0);
  full              : out std_logic;
  empty             : out std_logic
);
end component;

component fifo_xil_wr_spi
port(
  rst               : in  std_logic;
  wr_clk            : in  std_logic;
  rd_clk            : in  std_logic;
  din               : in  std_logic_vector(31 downto 0);
  wr_en             : in  std_logic;
  rd_en             : in  std_logic;
  dout              : out std_logic_vector(31 downto 0);
  full              : out std_logic;
  empty             : out std_logic
);
end component;

component diff_clk_0_to_20_gen
port(
  clk_in_100   : in std_logic;
  reset_n      : in std_logic;

  clk_out_00_p : out std_logic;
  clk_out_00_n : out std_logic;
  clk_out_01_p : out std_logic;
  clk_out_01_n : out std_logic;
  clk_out_02_p : out std_logic;
  clk_out_02_n : out std_logic;
  clk_out_03_p : out std_logic;
  clk_out_03_n : out std_logic;
  clk_out_04_p : out std_logic;
  clk_out_04_n : out std_logic;
  clk_out_05_p : out std_logic;
  clk_out_05_n : out std_logic;
  clk_out_06_p : out std_logic;
  clk_out_06_n : out std_logic;
  clk_out_07_p : out std_logic;
  clk_out_07_n : out std_logic;
  clk_out_08_p : out std_logic;
  clk_out_08_n : out std_logic;
  clk_out_09_p : out std_logic;
  clk_out_09_n : out std_logic;
  clk_out_10_p : out std_logic;
  clk_out_10_n : out std_logic;
  clk_out_11_p : out std_logic;
  clk_out_11_n : out std_logic;
  clk_out_12_p : out std_logic;
  clk_out_12_n : out std_logic;
  clk_out_13_p : out std_logic;
  clk_out_13_n : out std_logic;
  clk_out_14_p : out std_logic;
  clk_out_14_n : out std_logic;
  clk_out_15_p : out std_logic;
  clk_out_15_n : out std_logic;
  clk_out_16_p : out std_logic;
  clk_out_16_n : out std_logic;
  clk_out_17_p : out std_logic;
  clk_out_17_n : out std_logic;
  clk_out_18_p : out std_logic;
  clk_out_18_n : out std_logic;
  clk_out_19_p : out std_logic;
  clk_out_19_n : out std_logic;
  clk_out_20_p : out std_logic;
  clk_out_20_n : out std_logic
);
end component;

component led_rgb
port(
  clk          : in  std_logic;
  reset_n      : in  std_logic;
  led0_red_o   : out std_logic;
  led0_green_o : out std_logic;
  led0_blue_o  : out std_logic
);
end component;

component spi_master_periph
port (
  --  system clk and reset
  clk_i              : in  std_logic;  -- 200 mhz
  rst_n_i            : in  std_logic;  -- system reset (active low)

  --  read from fifo interface
  in_data_i          : in  std_logic_vector(31 downto 0);
  fifo_empty_i       : in  std_logic;
  fifo_rd_en_o       : out std_logic;

  --  write to fifo interface
  out_data_o         : out std_logic_vector(31 downto 0);
  fifo_full_i        : in  std_logic;
  fifo_wr_en_o       : out std_logic;

  --lane_0 slave spi interface
  cfg0_sck0_o        : out std_logic;
  cfg0_sck1_o        : out std_logic;
  cfg0_sck2_o        : out std_logic;
  cfg0_sck3_o        : out std_logic;
  cfg0_sck4_o        : out std_logic;
  cfg0_sck5_o        : out std_logic;
  cfg0_sck6_o        : out std_logic;
  cfg0_miso_i        : in  std_logic;
  cfg0_mosi_o        : out std_logic;
  cfg0_cs0n_o        : out std_logic;
  cfg0_cs1n_o        : out std_logic;
  cfg0_cs2n_o        : out std_logic;
  cfg0_cs3n_o        : out std_logic;
  cfg0_cs4n_o        : out std_logic;
  cfg0_cs5n_o        : out std_logic;
  cfg0_cs6n_o        : out std_logic;
  cfg0_cs_dir        : out std_logic;
  cfg0_programn_o    : out std_logic;

  --lane_1 slave spi interface
  cfg1_sck0_o        : out std_logic;
  cfg1_sck1_o        : out std_logic;
  cfg1_sck2_o        : out std_logic;
  cfg1_sck3_o        : out std_logic;
  cfg1_sck4_o        : out std_logic;
  cfg1_sck5_o        : out std_logic;
  cfg1_sck6_o        : out std_logic;
  cfg1_miso_i        : in  std_logic;
  cfg1_mosi_o        : out std_logic;
  cfg1_cs0n_o        : out std_logic;
  cfg1_cs1n_o        : out std_logic;
  cfg1_cs2n_o        : out std_logic;
  cfg1_cs3n_o        : out std_logic;
  cfg1_cs4n_o        : out std_logic;
  cfg1_cs5n_o        : out std_logic;
  cfg1_cs6n_o        : out std_logic;
  cfg1_cs_dir        : out std_logic;
  cfg1_programn_o    : out std_logic;

  --lane_2 slave spi interface
  cfg2_sck0_o        : out std_logic;
  cfg2_sck1_o        : out std_logic;
  cfg2_sck2_o        : out std_logic;
  cfg2_sck3_o        : out std_logic;
  cfg2_sck4_o        : out std_logic;
  cfg2_sck5_o        : out std_logic;
  cfg2_sck6_o        : out std_logic;
  cfg2_miso_i        : in  std_logic;
  cfg2_mosi_o        : out std_logic;
  cfg2_cs0n_o        : out std_logic;
  cfg2_cs1n_o        : out std_logic;
  cfg2_cs2n_o        : out std_logic;
  cfg2_cs3n_o        : out std_logic;
  cfg2_cs4n_o        : out std_logic;
  cfg2_cs5n_o        : out std_logic;
  cfg2_cs6n_o        : out std_logic;
  cfg2_cs_dir        : out std_logic;
  cfg2_programn_o    : out std_logic--;
);
end component;

--component ipmi
--port(
--    -- SPI Slave interface connected to ATMEGA1284P
--  ipmi_csn_ls_i            : in  std_logic;
--  ipmi_sclk_ls_i           : in  std_logic;
--  ipmi_mosi_ls_i           : in  std_logic;
--  ipmi_miso_ls_o           : out std_logic
--);
--end component;

signal reset_n                      : std_logic;
signal reset                        : std_logic;
signal clk_wiz_reset                : std_logic;
signal clk_main_200                 : std_logic;
signal clk_spi                      : std_logic;
signal clk_dc_fpgas                 : std_logic;
signal clk_par_if                   : std_logic;
signal clk_par_if_n                 : std_logic;
signal lane0_ds_fifo_dout           : std_logic_vector(35 downto 0);
signal lane0_ds_fifo_rd_en          : std_logic;
signal lane0_ds_fifo_empty          : std_logic;
signal lane0_us_fifo_din            : std_logic_vector(35 downto 0);
signal lane0_us_fifo_wr_en          : std_logic;
signal lane0_us_fifo_full           : std_logic;
signal lane1_ds_fifo_dout           : std_logic_vector(35 downto 0);
signal lane1_ds_fifo_rd_en          : std_logic;
signal lane1_ds_fifo_empty          : std_logic;
signal lane1_us_fifo_din            : std_logic_vector(35 downto 0);
signal lane1_us_fifo_wr_en          : std_logic;
signal lane1_us_fifo_full           : std_logic;
signal lane2_ds_fifo_dout           : std_logic_vector(35 downto 0);
signal lane2_ds_fifo_rd_en          : std_logic;
signal lane2_ds_fifo_empty          : std_logic;
signal lane2_us_fifo_din            : std_logic_vector(35 downto 0);
signal lane2_us_fifo_wr_en          : std_logic;
signal lane2_us_fifo_full           : std_logic;
signal lane0_xil_wr_fifo_din        : std_logic_vector(31 downto 0);
signal lane0_xil_wr_fifo_wr_en      : std_logic;
signal lane0_xil_wr_fifo_full       : std_logic;
signal lane0_xil_wr_fifo_dout       : std_logic_vector(31 downto 0);
signal lane0_xil_wr_fifo_rd_en      : std_logic;
signal lane0_xil_wr_fifo_empty      : std_logic;
signal lane0_xil_rd_fifo_din        : std_logic_vector(31 downto 0);
signal lane0_xil_rd_fifo_wr_en      : std_logic;
signal lane0_xil_rd_fifo_full       : std_logic;
signal lane0_xil_rd_fifo_dout       : std_logic_vector(31 downto 0);
signal lane0_xil_rd_fifo_rd_en      : std_logic;
signal lane0_xil_rd_fifo_empty      : std_logic;
signal lane1_xil_wr_fifo_din        : std_logic_vector(31 downto 0);
signal lane1_xil_wr_fifo_wr_en      : std_logic;
signal lane1_xil_wr_fifo_full       : std_logic;
signal lane1_xil_wr_fifo_dout       : std_logic_vector(31 downto 0);
signal lane1_xil_wr_fifo_rd_en      : std_logic;
signal lane1_xil_wr_fifo_empty      : std_logic;
signal lane1_xil_rd_fifo_din        : std_logic_vector(31 downto 0);
signal lane1_xil_rd_fifo_wr_en      : std_logic;
signal lane1_xil_rd_fifo_full       : std_logic;
signal lane1_xil_rd_fifo_dout       : std_logic_vector(31 downto 0);
signal lane1_xil_rd_fifo_rd_en      : std_logic;
signal lane1_xil_rd_fifo_empty      : std_logic;
signal lane2_xil_wr_fifo_din        : std_logic_vector(31 downto 0);
signal lane2_xil_wr_fifo_wr_en      : std_logic;
signal lane2_xil_wr_fifo_full       : std_logic;
signal lane2_xil_wr_fifo_dout       : std_logic_vector(31 downto 0);
signal lane2_xil_wr_fifo_rd_en      : std_logic;
signal lane2_xil_wr_fifo_empty      : std_logic;
signal lane2_xil_rd_fifo_din        : std_logic_vector(31 downto 0);
signal lane2_xil_rd_fifo_wr_en      : std_logic;
signal lane2_xil_rd_fifo_full       : std_logic;
signal lane2_xil_rd_fifo_dout       : std_logic_vector(31 downto 0);
signal lane2_xil_rd_fifo_rd_en      : std_logic;
signal lane2_xil_rd_fifo_empty      : std_logic;
signal spi_xil_wr_fifo_din          : std_logic_vector(31 downto 0);
signal spi_xil_wr_fifo_wr_en        : std_logic;
signal spi_xil_wr_fifo_full         : std_logic;
signal spi_xil_wr_fifo_dout         : std_logic_vector(31 downto 0);
signal spi_xil_wr_fifo_rd_en        : std_logic;
signal spi_xil_wr_fifo_empty        : std_logic;
signal spi_xil_rd_fifo_din          : std_logic_vector(31 downto 0);
signal spi_xil_rd_fifo_wr_en        : std_logic;
signal spi_xil_rd_fifo_full         : std_logic;
signal spi_xil_rd_fifo_dout         : std_logic_vector(31 downto 0);
signal spi_xil_rd_fifo_rd_en        : std_logic;
signal spi_xil_rd_fifo_empty        : std_logic;
signal cfg0_sck0_ls                 : std_logic;
signal cfg0_sck1_ls                 : std_logic;
signal cfg0_sck2_ls                 : std_logic;
signal cfg0_sck3_ls                 : std_logic;
signal cfg0_sck4_ls                 : std_logic;
signal cfg0_sck5_ls                 : std_logic;
signal cfg0_sck6_ls                 : std_logic;
signal cfg0_miso_ls                 : std_logic;
signal cfg0_mosi_ls                 : std_logic;
signal cfg0_cs0n_ls                 : std_logic;
signal cfg0_cs1n_ls                 : std_logic;
signal cfg0_cs2n_ls                 : std_logic;
signal cfg0_cs3n_ls                 : std_logic;
signal cfg0_cs4n_ls                 : std_logic;
signal cfg0_cs5n_ls                 : std_logic;
signal cfg0_cs6n_ls                 : std_logic;
signal cfg0_cs_dir                  : std_logic;
signal cfg0_programn_ls             : std_logic;
signal cfg1_sck0_ls                 : std_logic;
signal cfg1_sck1_ls                 : std_logic;
signal cfg1_sck2_ls                 : std_logic;
signal cfg1_sck3_ls                 : std_logic;
signal cfg1_sck4_ls                 : std_logic;
signal cfg1_sck5_ls                 : std_logic;
signal cfg1_sck6_ls                 : std_logic;
signal cfg1_miso_ls                 : std_logic;
signal cfg1_mosi_ls                 : std_logic;
signal cfg1_cs0n_ls                 : std_logic;
signal cfg1_cs1n_ls                 : std_logic;
signal cfg1_cs2n_ls                 : std_logic;
signal cfg1_cs3n_ls                 : std_logic;
signal cfg1_cs4n_ls                 : std_logic;
signal cfg1_cs5n_ls                 : std_logic;
signal cfg1_cs6n_ls                 : std_logic;
signal cfg1_cs_dir                  : std_logic;
signal cfg1_programn_ls             : std_logic;
signal cfg2_sck0_ls                 : std_logic;
signal cfg2_sck1_ls                 : std_logic;
signal cfg2_sck2_ls                 : std_logic;
signal cfg2_sck3_ls                 : std_logic;
signal cfg2_sck4_ls                 : std_logic;
signal cfg2_sck5_ls                 : std_logic;
signal cfg2_sck6_ls                 : std_logic;
signal cfg2_miso_ls                 : std_logic;
signal cfg2_mosi_ls                 : std_logic;
signal cfg2_cs0n_ls                 : std_logic;
signal cfg2_cs1n_ls                 : std_logic;
signal cfg2_cs2n_ls                 : std_logic;
signal cfg2_cs3n_ls                 : std_logic;
signal cfg2_cs4n_ls                 : std_logic;
signal cfg2_cs5n_ls                 : std_logic;
signal cfg2_cs6n_ls                 : std_logic;
signal cfg2_cs_dir                  : std_logic;
signal cfg2_programn_ls             : std_logic;

begin

reset                   <= not reset_n;
clk_wiz_reset           <= not reset_n_in;

lane0_xil_wr_fifo_din   <= xil0_wr_fifo_din_i;
lane0_xil_wr_fifo_wr_en <= xil0_wr_fifo_wr_en_i;
xil0_wr_fifo_full_o     <= lane0_xil_wr_fifo_full;
xil0_rd_fifo_dout_o     <= lane0_xil_rd_fifo_dout;
lane0_xil_rd_fifo_rd_en <= xil0_rd_fifo_rd_en_i;
xil0_rd_fifo_empty_o    <= lane0_xil_rd_fifo_empty;

lane1_xil_wr_fifo_din   <= xil1_wr_fifo_din_i;
lane1_xil_wr_fifo_wr_en <= xil1_wr_fifo_wr_en_i;
xil1_wr_fifo_full_o     <= lane1_xil_wr_fifo_full;
xil1_rd_fifo_dout_o     <= lane1_xil_rd_fifo_dout;
lane1_xil_rd_fifo_rd_en <= xil1_rd_fifo_rd_en_i;
xil1_rd_fifo_empty_o    <= lane1_xil_rd_fifo_empty;

lane2_xil_wr_fifo_din   <= xil2_wr_fifo_din_i;
lane2_xil_wr_fifo_wr_en <= xil2_wr_fifo_wr_en_i;
xil2_wr_fifo_full_o     <= lane2_xil_wr_fifo_full;
xil2_rd_fifo_dout_o     <= lane2_xil_rd_fifo_dout;
lane2_xil_rd_fifo_rd_en <= xil2_rd_fifo_rd_en_i;
xil2_rd_fifo_empty_o    <= lane2_xil_rd_fifo_empty;

spi_xil_wr_fifo_din     <= xil_spi_wr_fifo_din_i;
spi_xil_wr_fifo_wr_en   <= xil_spi_wr_fifo_wr_en_i;
xil_spi_wr_fifo_full_o  <= spi_xil_wr_fifo_full;
xil_spi_rd_fifo_dout_o  <= spi_xil_rd_fifo_dout;
spi_xil_rd_fifo_rd_en   <= xil_spi_rd_fifo_rd_en_i;
xil_spi_rd_fifo_empty_o <= spi_xil_rd_fifo_empty;

cfg0_sck0_ls_o          <= cfg0_sck0_ls;
cfg0_sck1_ls_o          <= cfg0_sck1_ls;
cfg0_sck2_ls_o          <= cfg0_sck2_ls;
cfg0_sck3_ls_o          <= cfg0_sck3_ls;
cfg0_sck4_ls_o          <= cfg0_sck4_ls;
cfg0_sck5_ls_o          <= cfg0_sck5_ls;
cfg0_sck6_ls_o          <= cfg0_sck6_ls;
cfg0_miso_ls            <= cfg0_miso_ls_i;
cfg0_mosi_ls_o          <= cfg0_mosi_ls;
cfg0_cs0n_ls_o          <= cfg0_cs0n_ls;
cfg0_cs1n_ls_o          <= cfg0_cs1n_ls;
cfg0_cs2n_ls_o          <= cfg0_cs2n_ls;
cfg0_cs3n_ls_o          <= cfg0_cs3n_ls;
cfg0_cs4n_ls_o          <= cfg0_cs4n_ls;
cfg0_cs5n_ls_o          <= cfg0_cs5n_ls;
cfg0_cs6n_ls_o          <= cfg0_cs6n_ls;
cfg0_cs_dir_o           <= cfg0_cs_dir;
cfg0_programn_ls_o      <= cfg0_programn_ls;

cfg1_sck0_ls_o          <= cfg1_sck0_ls;
cfg1_sck1_ls_o          <= cfg1_sck1_ls;
cfg1_sck2_ls_o          <= cfg1_sck2_ls;
cfg1_sck3_ls_o          <= cfg1_sck3_ls;
cfg1_sck4_ls_o          <= cfg1_sck4_ls;
cfg1_sck5_ls_o          <= cfg1_sck5_ls;
cfg1_sck6_ls_o          <= cfg1_sck6_ls;
cfg1_miso_ls            <= cfg1_miso_ls_i;
cfg1_mosi_ls_o          <= cfg1_mosi_ls;
cfg1_cs0n_ls_o          <= cfg1_cs0n_ls;
cfg1_cs1n_ls_o          <= cfg1_cs1n_ls;
cfg1_cs2n_ls_o          <= cfg1_cs2n_ls;
cfg1_cs3n_ls_o          <= cfg1_cs3n_ls;
cfg1_cs4n_ls_o          <= cfg1_cs4n_ls;
cfg1_cs5n_ls_o          <= cfg1_cs5n_ls;
cfg1_cs6n_ls_o          <= cfg1_cs6n_ls;
cfg1_cs_dir_o           <= cfg1_cs_dir;
cfg1_programn_ls_o      <= cfg1_programn_ls;

cfg2_sck0_ls_o          <= cfg2_sck0_ls;
cfg2_sck1_ls_o          <= cfg2_sck1_ls;
cfg2_sck2_ls_o          <= cfg2_sck2_ls;
cfg2_sck3_ls_o          <= cfg2_sck3_ls;
cfg2_sck4_ls_o          <= cfg2_sck4_ls;
cfg2_sck5_ls_o          <= cfg2_sck5_ls;
cfg2_sck6_ls_o          <= cfg2_sck6_ls;
cfg2_miso_ls            <= cfg2_miso_ls_i;
cfg2_mosi_ls_o          <= cfg2_mosi_ls;
cfg2_cs0n_ls_o          <= cfg2_cs0n_ls;
cfg2_cs1n_ls_o          <= cfg2_cs1n_ls;
cfg2_cs2n_ls_o          <= cfg2_cs2n_ls;
cfg2_cs3n_ls_o          <= cfg2_cs3n_ls;
cfg2_cs4n_ls_o          <= cfg2_cs4n_ls;
cfg2_cs5n_ls_o          <= cfg2_cs5n_ls;
cfg2_cs6n_ls_o          <= cfg2_cs6n_ls;
cfg2_cs_dir_o           <= cfg2_cs_dir;
cfg2_programn_ls_o      <= cfg2_programn_ls;

clk_wiz_main_o : clk_wiz_main
port map(
  reset     => clk_wiz_reset,
  clk_in1_p => clk_ref_p,
  clk_in1_n => clk_ref_n,
  locked    => reset_n,
  clk_out1  => clk_main_200,
  clk_out2  => clk_dc_fpgas,
  clk_out3  => clk_par_if,
  clk_out4  => clk_par_if_n,
  clk_out5  => clk_spi
);

parallel_if_sdr_diff_lane_0 : parallel_if_sdr_diff
port map(
  clk_fifo_if        => clk_main_200,
  clk_par_if         => clk_par_if,
  clk_par_if_n       => clk_par_if_n,
  reset_n            => reset_n,
  sdr_clk_lr_p_o     => lane0_sdr_clk_lr_p_o,
  sdr_clk_lr_n_o     => lane0_sdr_clk_lr_n_o,
  sdr_clk_rl_p_i     => lane0_sdr_clk_rl_p_i,
  sdr_clk_rl_n_i     => lane0_sdr_clk_rl_n_i,
  sdr_data_p_io      => lane0_sdr_data_p_io,
  sdr_data_n_io      => lane0_sdr_data_n_io,
  sdr_data_type_p_io => lane0_sdr_data_type_p_io,
  sdr_data_type_n_io => lane0_sdr_data_type_n_io,
  sdr_dir_o          => lane0_sdr_dir_o,
  has_data_i         => lane0_has_data_i,
  ready_io           => lane0_ready_io,
  ds_fifo_dout_o     => lane0_ds_fifo_dout,
  ds_fifo_rd_en_i    => lane0_ds_fifo_rd_en,
  ds_fifo_empty_o    => lane0_ds_fifo_empty,
  us_fifo_din_i      => lane0_us_fifo_din,
  us_fifo_wr_en_i    => lane0_us_fifo_wr_en,
  us_fifo_full_o     => lane0_us_fifo_full
);

parallel_if_sdr_diff_lane_1 : parallel_if_sdr_diff
port map(
  clk_fifo_if        => clk_main_200,
  clk_par_if         => clk_par_if,
  clk_par_if_n       => clk_par_if_n,
  reset_n            => reset_n,
  sdr_clk_lr_p_o     => lane1_sdr_clk_lr_p_o,
  sdr_clk_lr_n_o     => lane1_sdr_clk_lr_n_o,
  sdr_clk_rl_p_i     => lane1_sdr_clk_rl_p_i,
  sdr_clk_rl_n_i     => lane1_sdr_clk_rl_n_i,
  sdr_data_p_io      => lane1_sdr_data_p_io,
  sdr_data_n_io      => lane1_sdr_data_n_io,
  sdr_data_type_p_io => lane1_sdr_data_type_p_io,
  sdr_data_type_n_io => lane1_sdr_data_type_n_io,
  sdr_dir_o          => lane1_sdr_dir_o,
  has_data_i         => lane1_has_data_i,
  ready_io           => lane1_ready_io,
  ds_fifo_dout_o     => lane1_ds_fifo_dout,
  ds_fifo_rd_en_i    => lane1_ds_fifo_rd_en,
  ds_fifo_empty_o    => lane1_ds_fifo_empty,
  us_fifo_din_i      => lane1_us_fifo_din,
  us_fifo_wr_en_i    => lane1_us_fifo_wr_en,
  us_fifo_full_o     => lane1_us_fifo_full
);

parallel_if_sdr_diff_lane_2 : parallel_if_sdr_diff
port map(
  clk_fifo_if        => clk_main_200,
  clk_par_if         => clk_par_if,
  clk_par_if_n       => clk_par_if_n,
  reset_n            => reset_n,
  sdr_clk_lr_p_o     => lane2_sdr_clk_lr_p_o,
  sdr_clk_lr_n_o     => lane2_sdr_clk_lr_n_o,
  sdr_clk_rl_p_i     => lane2_sdr_clk_rl_p_i,
  sdr_clk_rl_n_i     => lane2_sdr_clk_rl_n_i,
  sdr_data_p_io      => lane2_sdr_data_p_io,
  sdr_data_n_io      => lane2_sdr_data_n_io,
  sdr_data_type_p_io => lane2_sdr_data_type_p_io,
  sdr_data_type_n_io => lane2_sdr_data_type_n_io,
  sdr_dir_o          => lane2_sdr_dir_o,
  has_data_i         => lane2_has_data_i,
  ready_io           => lane2_ready_io,
  ds_fifo_dout_o     => lane2_ds_fifo_dout,
  ds_fifo_rd_en_i    => lane2_ds_fifo_rd_en,
  ds_fifo_empty_o    => lane2_ds_fifo_empty,
  us_fifo_din_i      => lane2_us_fifo_din,
  us_fifo_wr_en_i    => lane2_us_fifo_wr_en,
  us_fifo_full_o     => lane2_us_fifo_full
);

us_packet_tx_lane_0 : us_packet_tx
port map(
  clk                 => clk_main_200,
  reset_n             => reset_n,
  us_fifo_din_o       => lane0_us_fifo_din,
  us_fifo_wr_en_o     => lane0_us_fifo_wr_en,
  us_fifo_full_i      => lane0_us_fifo_full,
  xil_fifo_dout_i     => lane0_xil_wr_fifo_dout,
  xil_fifo_rd_en_o    => lane0_xil_wr_fifo_rd_en,
  xil_fifo_rd_empty_i => lane0_xil_wr_fifo_empty
);

ds_packet_rx_lane_0 : ds_packet_rx
port map(
  clk                 => clk_main_200,
  reset_n             => reset_n,
  ds_fifo_dout_i      => lane0_ds_fifo_dout,
  ds_fifo_rd_en_o     => lane0_ds_fifo_rd_en,
  ds_fifo_empty_i     => lane0_ds_fifo_empty,
  xil_fifo_din_o      => lane0_xil_rd_fifo_din,
  xil_fifo_wr_en_o    => lane0_xil_rd_fifo_wr_en,
  xil_fifo_rd_full_i  => lane0_xil_rd_fifo_full
);

fifo_xil_wr_lane0 : fifo_xil_wr
port map(
  rst    => reset,
  wr_clk => xil_bus_clk,
  rd_clk => clk_main_200,
  din    => lane0_xil_wr_fifo_din,
  wr_en  => lane0_xil_wr_fifo_wr_en,
  full   => lane0_xil_wr_fifo_full,
  rd_en  => lane0_xil_wr_fifo_rd_en,
  dout   => lane0_xil_wr_fifo_dout,
  empty  => lane0_xil_wr_fifo_empty
);

fifo_xil_rd_lane0 : fifo_xil_rd
port map(
  rst    => reset,
  wr_clk => clk_main_200,
  rd_clk => xil_bus_clk,
  din    => lane0_xil_rd_fifo_din,
  wr_en  => lane0_xil_rd_fifo_wr_en,
  full   => lane0_xil_rd_fifo_full,
  rd_en  => lane0_xil_rd_fifo_rd_en,
  dout   => lane0_xil_rd_fifo_dout,
  empty  => lane0_xil_rd_fifo_empty
);

us_packet_tx_lane_1 : us_packet_tx
port map(
  clk                 => clk_main_200,
  reset_n             => reset_n,
  us_fifo_din_o       => lane1_us_fifo_din,
  us_fifo_wr_en_o     => lane1_us_fifo_wr_en,
  us_fifo_full_i      => lane1_us_fifo_full,
  xil_fifo_dout_i     => lane1_xil_wr_fifo_dout,
  xil_fifo_rd_en_o    => lane1_xil_wr_fifo_rd_en,
  xil_fifo_rd_empty_i => lane1_xil_wr_fifo_empty
);

ds_packet_rx_lane_1 : ds_packet_rx
port map(
  clk                 => clk_main_200,
  reset_n             => reset_n,
  ds_fifo_dout_i      => lane1_ds_fifo_dout,
  ds_fifo_rd_en_o     => lane1_ds_fifo_rd_en,
  ds_fifo_empty_i     => lane1_ds_fifo_empty,
  xil_fifo_din_o      => lane1_xil_rd_fifo_din,
  xil_fifo_wr_en_o    => lane1_xil_rd_fifo_wr_en,
  xil_fifo_rd_full_i  => lane1_xil_rd_fifo_full
);

fifo_xil_wr_lane1 : fifo_xil_wr
port map(
  rst    => reset,
  wr_clk => xil_bus_clk,
  rd_clk => clk_main_200,
  din    => lane1_xil_wr_fifo_din,
  wr_en  => lane1_xil_wr_fifo_wr_en,
  full   => lane1_xil_wr_fifo_full,
  rd_en  => lane1_xil_wr_fifo_rd_en,
  dout   => lane1_xil_wr_fifo_dout,
  empty  => lane1_xil_wr_fifo_empty
);

fifo_xil_rd_lane1 : fifo_xil_rd
port map(
  rst    => reset,
  wr_clk => clk_main_200,
  rd_clk => xil_bus_clk,
  din    => lane1_xil_rd_fifo_din,
  wr_en  => lane1_xil_rd_fifo_wr_en,
  full   => lane1_xil_rd_fifo_full,
  rd_en  => lane1_xil_rd_fifo_rd_en,
  dout   => lane1_xil_rd_fifo_dout,
  empty  => lane1_xil_rd_fifo_empty
);

us_packet_tx_lane_2 : us_packet_tx
port map(
  clk                 => clk_main_200,
  reset_n             => reset_n,
  us_fifo_din_o       => lane2_us_fifo_din,
  us_fifo_wr_en_o     => lane2_us_fifo_wr_en,
  us_fifo_full_i      => lane2_us_fifo_full,
  xil_fifo_dout_i     => lane2_xil_wr_fifo_dout,
  xil_fifo_rd_en_o    => lane2_xil_wr_fifo_rd_en,
  xil_fifo_rd_empty_i => lane2_xil_wr_fifo_empty
);

ds_packet_rx_lane_2 : ds_packet_rx
port map(
  clk                 => clk_main_200,
  reset_n             => reset_n,
  ds_fifo_dout_i      => lane2_ds_fifo_dout,
  ds_fifo_rd_en_o     => lane2_ds_fifo_rd_en,
  ds_fifo_empty_i     => lane2_ds_fifo_empty,
  xil_fifo_din_o      => lane2_xil_rd_fifo_din,
  xil_fifo_wr_en_o    => lane2_xil_rd_fifo_wr_en,
  xil_fifo_rd_full_i  => lane2_xil_rd_fifo_full
);

fifo_xil_wr_lane2 : fifo_xil_wr
port map(
  rst    => reset,
  wr_clk => xil_bus_clk,
  rd_clk => clk_main_200,
  din    => lane2_xil_wr_fifo_din,
  wr_en  => lane2_xil_wr_fifo_wr_en,
  full   => lane2_xil_wr_fifo_full,
  rd_en  => lane2_xil_wr_fifo_rd_en,
  dout   => lane2_xil_wr_fifo_dout,
  empty  => lane2_xil_wr_fifo_empty
);

fifo_xil_rd_lane2 : fifo_xil_rd
port map(
  rst    => reset,
  wr_clk => clk_main_200,
  rd_clk => xil_bus_clk,
  din    => lane2_xil_rd_fifo_din,
  wr_en  => lane2_xil_rd_fifo_wr_en,
  full   => lane2_xil_rd_fifo_full,
  rd_en  => lane2_xil_rd_fifo_rd_en,
  dout   => lane2_xil_rd_fifo_dout,
  empty  => lane2_xil_rd_fifo_empty
);

fifo_xil_wr_spi_0 : fifo_xil_wr_spi
port map(
  rst    => reset,
  wr_clk => xil_bus_clk,
  rd_clk => clk_spi,
  din    => spi_xil_wr_fifo_din,
  wr_en  => spi_xil_wr_fifo_wr_en,
  full   => spi_xil_wr_fifo_full,
  rd_en  => spi_xil_wr_fifo_rd_en,
  dout   => spi_xil_wr_fifo_dout,
  empty  => spi_xil_wr_fifo_empty
);

fifo_xil_rd_spi_0 : fifo_xil_rd_spi
port map(
  rst    => reset,
  wr_clk => clk_spi,
  rd_clk => xil_bus_clk,
  din    => spi_xil_rd_fifo_din,
  wr_en  => spi_xil_rd_fifo_wr_en,
  full   => spi_xil_rd_fifo_full,
  rd_en  => spi_xil_rd_fifo_rd_en,
  dout   => spi_xil_rd_fifo_dout,
  empty  => spi_xil_rd_fifo_empty
);

diff_clk_0_to_20_gen_0 : diff_clk_0_to_20_gen
port map(
  clk_in_100   => clk_dc_fpgas,
  reset_n      => reset_n,
  clk_out_00_p => cm0_clk_p_o,
  clk_out_00_n => cm0_clk_n_o,
  clk_out_01_p => cm1_clk_p_o,
  clk_out_01_n => cm1_clk_n_o,
  clk_out_02_p => cm2_clk_p_o,
  clk_out_02_n => cm2_clk_n_o,
  clk_out_03_p => cm3_clk_p_o,
  clk_out_03_n => cm3_clk_n_o,
  clk_out_04_p => cm4_clk_p_o,
  clk_out_04_n => cm4_clk_n_o,
  clk_out_05_p => cm5_clk_p_o,
  clk_out_05_n => cm5_clk_n_o,
  clk_out_06_p => cm6_clk_p_o,
  clk_out_06_n => cm6_clk_n_o,
  clk_out_07_p => cm7_clk_p_o,
  clk_out_07_n => cm7_clk_n_o,
  clk_out_08_p => cm8_clk_p_o,
  clk_out_08_n => cm8_clk_n_o,
  clk_out_09_p => cm9_clk_p_o,
  clk_out_09_n => cm9_clk_n_o,
  clk_out_10_p => cm10_clk_p_o,
  clk_out_10_n => cm10_clk_n_o,
  clk_out_11_p => cm11_clk_p_o,
  clk_out_11_n => cm11_clk_n_o,
  clk_out_12_p => cm12_clk_p_o,
  clk_out_12_n => cm12_clk_n_o,
  clk_out_13_p => cm13_clk_p_o,
  clk_out_13_n => cm13_clk_n_o,
  clk_out_14_p => cm14_clk_p_o,
  clk_out_14_n => cm14_clk_n_o,
  clk_out_15_p => cm15_clk_p_o,
  clk_out_15_n => cm15_clk_n_o,
  clk_out_16_p => cm16_clk_p_o,
  clk_out_16_n => cm16_clk_n_o,
  clk_out_17_p => cm17_clk_p_o,
  clk_out_17_n => cm17_clk_n_o,
  clk_out_18_p => cm18_clk_p_o,
  clk_out_18_n => cm18_clk_n_o,
  clk_out_19_p => cm19_clk_p_o,
  clk_out_19_n => cm19_clk_n_o,
  clk_out_20_p => cm20_clk_p_o,
  clk_out_20_n => cm20_clk_n_o
);


led_rgb_0 : led_rgb
port map(
  clk          => clk_main_200,
  reset_n      => reset_n,
  led0_red_o   => led0_red_o,
  led0_green_o => led0_green_o,
  led0_blue_o  => led0_blue_o
);

spi_master_periph_0 : spi_master_periph
port map (
  clk_i              => clk_spi,
  rst_n_i            => reset_n,
  in_data_i          => spi_xil_wr_fifo_dout,
  fifo_empty_i       => spi_xil_wr_fifo_empty,
  fifo_rd_en_o       => spi_xil_wr_fifo_rd_en,
  out_data_o         => spi_xil_rd_fifo_din,
  fifo_full_i        => spi_xil_rd_fifo_full,
  fifo_wr_en_o       => spi_xil_rd_fifo_wr_en,
  cfg0_sck0_o        => cfg0_sck0_ls,
  cfg0_sck1_o        => cfg0_sck1_ls,
  cfg0_sck2_o        => cfg0_sck2_ls,
  cfg0_sck3_o        => cfg0_sck3_ls,
  cfg0_sck4_o        => cfg0_sck4_ls,
  cfg0_sck5_o        => cfg0_sck5_ls,
  cfg0_sck6_o        => cfg0_sck6_ls,
  cfg0_miso_i        => cfg0_miso_ls,
  cfg0_mosi_o        => cfg0_mosi_ls,
  cfg0_cs0n_o        => cfg0_cs0n_ls,
  cfg0_cs1n_o        => cfg0_cs1n_ls,
  cfg0_cs2n_o        => cfg0_cs2n_ls,
  cfg0_cs3n_o        => cfg0_cs3n_ls,
  cfg0_cs4n_o        => cfg0_cs4n_ls,
  cfg0_cs5n_o        => cfg0_cs5n_ls,
  cfg0_cs6n_o        => cfg0_cs6n_ls,
  cfg0_cs_dir        => cfg0_cs_dir,
  cfg0_programn_o    => cfg0_programn_ls,
  cfg1_sck0_o        => cfg1_sck0_ls,
  cfg1_sck1_o        => cfg1_sck1_ls,
  cfg1_sck2_o        => cfg1_sck2_ls,
  cfg1_sck3_o        => cfg1_sck3_ls,
  cfg1_sck4_o        => cfg1_sck4_ls,
  cfg1_sck5_o        => cfg1_sck5_ls,
  cfg1_sck6_o        => cfg1_sck6_ls,
  cfg1_miso_i        => cfg1_miso_ls,
  cfg1_mosi_o        => cfg1_mosi_ls,
  cfg1_cs0n_o        => cfg1_cs0n_ls,
  cfg1_cs1n_o        => cfg1_cs1n_ls,
  cfg1_cs2n_o        => cfg1_cs2n_ls,
  cfg1_cs3n_o        => cfg1_cs3n_ls,
  cfg1_cs4n_o        => cfg1_cs4n_ls,
  cfg1_cs5n_o        => cfg1_cs5n_ls,
  cfg1_cs6n_o        => cfg1_cs6n_ls,
  cfg1_cs_dir        => cfg1_cs_dir,
  cfg1_programn_o    => cfg1_programn_ls,
  cfg2_sck0_o        => cfg2_sck0_ls,
  cfg2_sck1_o        => cfg2_sck1_ls,
  cfg2_sck2_o        => cfg2_sck2_ls,
  cfg2_sck3_o        => cfg2_sck3_ls,
  cfg2_sck4_o        => cfg2_sck4_ls,
  cfg2_sck5_o        => cfg2_sck5_ls,
  cfg2_sck6_o        => cfg2_sck6_ls,
  cfg2_miso_i        => cfg2_miso_ls,
  cfg2_mosi_o        => cfg2_mosi_ls,
  cfg2_cs0n_o        => cfg2_cs0n_ls,
  cfg2_cs1n_o        => cfg2_cs1n_ls,
  cfg2_cs2n_o        => cfg2_cs2n_ls,
  cfg2_cs3n_o        => cfg2_cs3n_ls,
  cfg2_cs4n_o        => cfg2_cs4n_ls,
  cfg2_cs5n_o        => cfg2_cs5n_ls,
  cfg2_cs6n_o        => cfg2_cs6n_ls,
  cfg2_cs_dir        => cfg2_cs_dir,
  cfg2_programn_o    => cfg2_programn_ls
);

--ipmi_0 : ipmi
--port map(
--  ipmi_csn_ls_i  => ipmi_csn_ls_i,
--  ipmi_sclk_ls_i => ipmi_sclk_ls_i,
--  ipmi_mosi_ls_i => ipmi_mosi_ls_i,
--  ipmi_miso_ls_o => ipmi_miso_ls_o
--);

end rtl;
