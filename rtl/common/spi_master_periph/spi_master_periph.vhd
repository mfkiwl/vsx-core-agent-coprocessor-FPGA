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

---------------------------------------------------------------
-- Top module for SPI Master. Connects to xillybus spi write --
-- and spi read FIFOs to SPI interfaces of each lane.        --
---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity spi_master_periph is
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
        cfg2_programn_o    : out std_logic;

        fpgas_reset_n_0_o  : out std_logic;
        fpgas_reset_n_1_o  : out std_logic;
        fpgas_reset_n_2_o  : out std_logic
    );
end entity spi_master_periph;

architecture struct of spi_master_periph is

component spi_fifo_controller
  port (
      --  system clk and reset
    clk_i               : in  std_logic;  -- 200 mhz
    rst_n_i             : in  std_logic;  -- system reset (active low)
      --  read from fifo interface
    in_data_i           : in  std_logic_vector(31 downto 0);
    fifo_empty_i        : in  std_logic;
    fifo_rd_en_o        : out std_logic;
      --  write to fifo interface
    out_data_o          : out std_logic_vector(31 downto 0);
    fifo_full_i         : in  std_logic;
    fifo_wr_en_o        : out std_logic;
      --  lane0 write data interface
    lane0_wrdata_o      : out std_logic_vector( 7 downto 0);
    lane0_wraddress_o   : out std_logic_vector( 2 downto 0);
    lane0_wrdata_valid_o: out std_logic;
    lane0_wrdata_ready_i: in  std_logic;
      --  lane0 read data interface
    lane0_rddata_i      : in  std_logic_vector( 7 downto 0);
    lane0_rdaddress_o   : out std_logic_vector( 2 downto 0);
    lane0_rddata_valid_i: in  std_logic;
    lane0_rddata_ready_o: out std_logic;
      --  lane1 write data interface
    lane1_wrdata_o      : out std_logic_vector( 7 downto 0);
    lane1_wraddress_o   : out std_logic_vector( 2 downto 0);
    lane1_wrdata_valid_o: out std_logic;
    lane1_wrdata_ready_i: in  std_logic;
      --  lane1 read data interface
    lane1_rddata_i      : in  std_logic_vector( 7 downto 0);
    lane1_rdaddress_o   : out std_logic_vector( 2 downto 0);
    lane1_rddata_valid_i: in  std_logic;
    lane1_rddata_ready_o: out std_logic;
      --  lane2 write data interface
    lane2_wrdata_o      : out std_logic_vector( 7 downto 0);
    lane2_wraddress_o   : out std_logic_vector( 2 downto 0);
    lane2_wrdata_valid_o: out std_logic;
    lane2_wrdata_ready_i: in  std_logic;
      --  lane2 read data interface
    lane2_rddata_i      : in  std_logic_vector( 7 downto 0);
    lane2_rdaddress_o   : out std_logic_vector( 2 downto 0);
    lane2_rddata_valid_i: in  std_logic;
    lane2_rddata_ready_o: out std_logic--;
  );
end component;

component data_and_configuration_controller
  generic (
    rtl_clk_frequency : natural := 200_000_000--; -- 200 mhz
  );
  port (
  -- system signals
    clk_i                 : in  std_logic;
    rstn_i                : in  std_logic;
  -- register write interface
    wr_data_i             : in  std_logic_vector( 7 downto 0);
    wr_address_i          : in  std_logic_vector( 2 downto 0);
    wr_data_valid_i       : in  std_logic;
    wr_data_ready_o       : out std_logic;
  -- register read interface
    rd_data_o             : out std_logic_vector( 7 downto 0);
    rd_address_i          : in  std_logic_vector( 2 downto 0);
    rd_data_valid_o       : out std_logic;
    rd_data_ready_i       : in  std_logic;
  -- data input interface from spi core
    spim_in_data_i        : in  std_logic_vector (7 downto 0);
    spim_in_data_valid_i  : in  std_logic;
    spim_in_data_ready_o  : out std_logic;
  -- data output interface to spi core
    spim_out_data_o       : out std_logic_vector (7 downto 0);
    spim_out_data_valid_o : out std_logic;
    spim_out_data_ready_i : in  std_logic;
  -- spi configuration signals
    spim_mode_o           : out std_logic_vector( 1 downto 0);
    spim_first_trans_o    : out std_logic;
  -- fpga select signals
    spim_lane_ss_i        : in  std_logic;
    fpga_ssn_o            : out std_logic_vector( 6 downto 0);
  -- fpga programn pin
    programn_o            : out std_logic;
  -- spi master clock (clock enable)
    spim_clk_en_o         : out std_logic;
  -- others
    cfg_cs_dir_o          : out std_logic;
    fpgas_reset_n_o       : out std_logic
  );
end component;

component spi_master_core
  port (
      --  system clk and reset
    clk_i             : in  std_logic;  -- 200 mhz
    rst_n_i           : in  std_logic;  -- system reset (active low)
      --
    spi_clk_en_i      : in  std_logic;
      -- from configuration registers
    spi_cfg_i         : in  std_logic_vector (1 downto 0);  --
    first_trans_i     : in  std_logic;  -- release then assert ssn pin
      -- data input interface
    in_data_i         : in  std_logic_vector (7 downto 0);
    in_data_valid_i   : in  std_logic;
    in_data_ready_o   : out std_logic;
      -- data output interface
    out_data_o        : out std_logic_vector (7 downto 0);
    out_data_valid_o  : out std_logic;
    out_data_ready_i  : in  std_logic;
      -- spi interface
    miso_i            : in  std_logic;
    mosi_o            : out std_logic;
    sck_o             : out std_logic;
    ssn_o             : out std_logic--;
  );
end component;

signal lane0_wrdata              : std_logic_vector( 7 downto 0);
signal lane0_wraddress           : std_logic_vector( 2 downto 0);
signal lane0_wrdata_valid        : std_logic;
signal lane0_wrdata_ready        : std_logic;
signal lane0_rddata              : std_logic_vector( 7 downto 0);
signal lane0_rdaddress           : std_logic_vector( 2 downto 0);
signal lane0_rddata_valid        : std_logic;
signal lane0_rddata_ready        : std_logic;
signal lane1_wrdata              : std_logic_vector( 7 downto 0);
signal lane1_wraddress           : std_logic_vector( 2 downto 0);
signal lane1_wrdata_valid        : std_logic;
signal lane1_wrdata_ready        : std_logic;
signal lane1_rddata              : std_logic_vector( 7 downto 0);
signal lane1_rdaddress           : std_logic_vector( 2 downto 0);
signal lane1_rddata_valid        : std_logic;
signal lane1_rddata_ready        : std_logic;
signal lane2_wrdata              : std_logic_vector( 7 downto 0);
signal lane2_wraddress           : std_logic_vector( 2 downto 0);
signal lane2_wrdata_valid        : std_logic;
signal lane2_wrdata_ready        : std_logic;
signal lane2_rddata              : std_logic_vector( 7 downto 0);
signal lane2_rdaddress           : std_logic_vector( 2 downto 0);
signal lane2_rddata_valid        : std_logic;
signal lane2_rddata_ready        : std_logic;

signal lane0_spim_in_data        : std_logic_vector (7 downto 0);
signal lane0_spim_in_data_valid  : std_logic;
signal lane0_spim_in_data_ready  : std_logic;
signal lane0_spim_out_data       : std_logic_vector (7 downto 0);
signal lane0_spim_out_data_valid : std_logic;
signal lane0_spim_out_data_ready : std_logic;
signal lane0_spim_mode           : std_logic_vector( 1 downto 0);
signal lane0_spim_first_trans    : std_logic;
signal lane0_spim_lane_ss        : std_logic;
signal lane0_spim_clk_en         : std_logic;
signal lane1_spim_in_data        : std_logic_vector (7 downto 0);
signal lane1_spim_in_data_valid  : std_logic;
signal lane1_spim_in_data_ready  : std_logic;
signal lane1_spim_out_data       : std_logic_vector (7 downto 0);
signal lane1_spim_out_data_valid : std_logic;
signal lane1_spim_out_data_ready : std_logic;
signal lane1_spim_mode           : std_logic_vector( 1 downto 0);
signal lane1_spim_first_trans    : std_logic;
signal lane1_spim_lane_ss        : std_logic;
signal lane1_spim_clk_en         : std_logic;
signal lane2_spim_in_data        : std_logic_vector (7 downto 0);
signal lane2_spim_in_data_valid  : std_logic;
signal lane2_spim_in_data_ready  : std_logic;
signal lane2_spim_out_data       : std_logic_vector (7 downto 0);
signal lane2_spim_out_data_valid : std_logic;
signal lane2_spim_out_data_ready : std_logic;
signal lane2_spim_mode           : std_logic_vector( 1 downto 0);
signal lane2_spim_first_trans    : std_logic;
signal lane2_spim_lane_ss        : std_logic;
signal lane2_spim_clk_en         : std_logic;

signal lane0_fpga_ssn            : std_logic_vector( 6 downto 0);
signal lane0_programn            : std_logic;
signal lane0_cfg0_cs_dir         : std_logic;
signal lane0_mosi                : std_logic;
signal lane0_miso                : std_logic;
signal lane0_sck                 : std_logic;
signal lane1_fpga_ssn            : std_logic_vector( 6 downto 0);
signal lane1_programn            : std_logic;
signal lane1_cfg0_cs_dir         : std_logic;
signal lane1_mosi                : std_logic;
signal lane1_miso                : std_logic;
signal lane1_sck                 : std_logic;
signal lane2_fpga_ssn            : std_logic_vector( 6 downto 0);
signal lane2_programn            : std_logic;
signal lane2_cfg0_cs_dir         : std_logic;
signal lane2_mosi                : std_logic;
signal lane2_miso                : std_logic;
signal lane2_sck                 : std_logic;

begin

cfg0_sck0_o        <= lane0_sck;
cfg0_sck1_o        <= lane0_sck;
cfg0_sck2_o        <= lane0_sck;
cfg0_sck3_o        <= lane0_sck;
cfg0_sck4_o        <= lane0_sck;
cfg0_sck5_o        <= lane0_sck;
cfg0_sck6_o        <= lane0_sck;
lane0_miso         <= cfg0_miso_i;
cfg0_mosi_o        <= lane0_mosi;
cfg0_cs0n_o        <= lane0_fpga_ssn(0);
cfg0_cs1n_o        <= lane0_fpga_ssn(1);
cfg0_cs2n_o        <= lane0_fpga_ssn(2);
cfg0_cs3n_o        <= lane0_fpga_ssn(3);
cfg0_cs4n_o        <= lane0_fpga_ssn(4);
cfg0_cs5n_o        <= lane0_fpga_ssn(5);
cfg0_cs6n_o        <= lane0_fpga_ssn(6);
cfg0_cs_dir        <= lane0_cfg0_cs_dir;
cfg0_programn_o    <= lane0_programn;

cfg1_sck0_o        <= lane1_sck;
cfg1_sck1_o        <= lane1_sck;
cfg1_sck2_o        <= lane1_sck;
cfg1_sck3_o        <= lane1_sck;
cfg1_sck4_o        <= lane1_sck;
cfg1_sck5_o        <= lane1_sck;
cfg1_sck6_o        <= lane1_sck;
lane1_miso         <= cfg1_miso_i;
cfg1_mosi_o        <= lane1_mosi;
cfg1_cs0n_o        <= lane1_fpga_ssn(0);
cfg1_cs1n_o        <= lane1_fpga_ssn(1);
cfg1_cs2n_o        <= lane1_fpga_ssn(2);
cfg1_cs3n_o        <= lane1_fpga_ssn(3);
cfg1_cs4n_o        <= lane1_fpga_ssn(4);
cfg1_cs5n_o        <= lane1_fpga_ssn(5);
cfg1_cs6n_o        <= lane1_fpga_ssn(6);
cfg1_cs_dir        <= lane1_cfg0_cs_dir;
cfg1_programn_o    <= lane1_programn;

cfg2_sck0_o        <= lane2_sck;
cfg2_sck1_o        <= lane2_sck;
cfg2_sck2_o        <= lane2_sck;
cfg2_sck3_o        <= lane2_sck;
cfg2_sck4_o        <= lane2_sck;
cfg2_sck5_o        <= lane2_sck;
cfg2_sck6_o        <= lane2_sck;
lane2_miso         <= cfg2_miso_i;
cfg2_mosi_o        <= lane2_mosi;
cfg2_cs0n_o        <= lane2_fpga_ssn(0);
cfg2_cs1n_o        <= lane2_fpga_ssn(1);
cfg2_cs2n_o        <= lane2_fpga_ssn(2);
cfg2_cs3n_o        <= lane2_fpga_ssn(3);
cfg2_cs4n_o        <= lane2_fpga_ssn(4);
cfg2_cs5n_o        <= lane2_fpga_ssn(5);
cfg2_cs6n_o        <= lane2_fpga_ssn(6);
cfg2_cs_dir        <= lane2_cfg0_cs_dir;
cfg2_programn_o    <= lane2_programn;

spi_fifo_controller_0 : spi_fifo_controller
  port map(
    clk_i                => clk_i,
    rst_n_i              => rst_n_i,
    in_data_i            => in_data_i,
    fifo_empty_i         => fifo_empty_i,
    fifo_rd_en_o         => fifo_rd_en_o,
    out_data_o           => out_data_o,
    fifo_full_i          => fifo_full_i,
    fifo_wr_en_o         => fifo_wr_en_o,
    lane0_wrdata_o       => lane0_wrdata,
    lane0_wraddress_o    => lane0_wraddress,
    lane0_wrdata_valid_o => lane0_wrdata_valid,
    lane0_wrdata_ready_i => lane0_wrdata_ready,
    lane0_rddata_i       => lane0_rddata,
    lane0_rdaddress_o    => lane0_rdaddress,
    lane0_rddata_valid_i => lane0_rddata_valid,
    lane0_rddata_ready_o => lane0_rddata_ready,
    lane1_wrdata_o       => lane1_wrdata,
    lane1_wraddress_o    => lane1_wraddress,
    lane1_wrdata_valid_o => lane1_wrdata_valid,
    lane1_wrdata_ready_i => lane1_wrdata_ready,
    lane1_rddata_i       => lane1_rddata,
    lane1_rdaddress_o    => lane1_rdaddress,
    lane1_rddata_valid_i => lane1_rddata_valid,
    lane1_rddata_ready_o => lane1_rddata_ready,
    lane2_wrdata_o       => lane2_wrdata,
    lane2_wraddress_o    => lane2_wraddress,
    lane2_wrdata_valid_o => lane2_wrdata_valid,
    lane2_wrdata_ready_i => lane2_wrdata_ready,
    lane2_rddata_i       => lane2_rddata,
    lane2_rdaddress_o    => lane2_rdaddress,
    lane2_rddata_valid_i => lane2_rddata_valid,
    lane2_rddata_ready_o => lane2_rddata_ready
  );

data_and_configuration_controller_0 : data_and_configuration_controller
  generic map(
    rtl_clk_frequency => 200_000_000
  )
  port map(
    clk_i                 => clk_i,
    rstn_i                => rst_n_i,
    wr_data_i             => lane0_wrdata,
    wr_address_i          => lane0_wraddress,
    wr_data_valid_i       => lane0_wrdata_valid,
    wr_data_ready_o       => lane0_wrdata_ready,
    rd_data_o             => lane0_rddata,
    rd_address_i          => lane0_rdaddress,
    rd_data_valid_o       => lane0_rddata_valid,
    rd_data_ready_i       => lane0_rddata_ready,
    spim_in_data_i        => lane0_spim_in_data,
    spim_in_data_valid_i  => lane0_spim_in_data_valid,
    spim_in_data_ready_o  => lane0_spim_in_data_ready,
    spim_out_data_o       => lane0_spim_out_data,
    spim_out_data_valid_o => lane0_spim_out_data_valid,
    spim_out_data_ready_i => lane0_spim_out_data_ready,
    spim_mode_o           => lane0_spim_mode,
    spim_first_trans_o    => lane0_spim_first_trans,
    spim_lane_ss_i        => lane0_spim_lane_ss,
    fpga_ssn_o            => lane0_fpga_ssn,
    programn_o            => lane0_programn,
    spim_clk_en_o         => lane0_spim_clk_en,
    cfg_cs_dir_o          => lane0_cfg0_cs_dir,
    fpgas_reset_n_o       => fpgas_reset_n_0_o
  );

data_and_configuration_controller_1 : data_and_configuration_controller
  generic map(
    rtl_clk_frequency => 200_000_000
  )
  port map(
    clk_i                 => clk_i,
    rstn_i                => rst_n_i,
    wr_data_i             => lane1_wrdata,
    wr_address_i          => lane1_wraddress,
    wr_data_valid_i       => lane1_wrdata_valid,
    wr_data_ready_o       => lane1_wrdata_ready,
    rd_data_o             => lane1_rddata,
    rd_address_i          => lane1_rdaddress,
    rd_data_valid_o       => lane1_rddata_valid,
    rd_data_ready_i       => lane1_rddata_ready,
    spim_in_data_i        => lane1_spim_in_data,
    spim_in_data_valid_i  => lane1_spim_in_data_valid,
    spim_in_data_ready_o  => lane1_spim_in_data_ready,
    spim_out_data_o       => lane1_spim_out_data,
    spim_out_data_valid_o => lane1_spim_out_data_valid,
    spim_out_data_ready_i => lane1_spim_out_data_ready,
    spim_mode_o           => lane1_spim_mode,
    spim_first_trans_o    => lane1_spim_first_trans,
    spim_lane_ss_i        => lane1_spim_lane_ss,
    fpga_ssn_o            => lane1_fpga_ssn,
    programn_o            => lane1_programn,
    spim_clk_en_o         => lane1_spim_clk_en,
    cfg_cs_dir_o          => lane1_cfg0_cs_dir,
    fpgas_reset_n_o       => fpgas_reset_n_1_o
  );

data_and_configuration_controller_2 : data_and_configuration_controller
  generic map(
    rtl_clk_frequency => 200_000_000
  )
  port map(
    clk_i                 => clk_i,
    rstn_i                => rst_n_i,
    wr_data_i             => lane2_wrdata,
    wr_address_i          => lane2_wraddress,
    wr_data_valid_i       => lane2_wrdata_valid,
    wr_data_ready_o       => lane2_wrdata_ready,
    rd_data_o             => lane2_rddata,
    rd_address_i          => lane2_rdaddress,
    rd_data_valid_o       => lane2_rddata_valid,
    rd_data_ready_i       => lane2_rddata_ready,
    spim_in_data_i        => lane2_spim_in_data,
    spim_in_data_valid_i  => lane2_spim_in_data_valid,
    spim_in_data_ready_o  => lane2_spim_in_data_ready,
    spim_out_data_o       => lane2_spim_out_data,
    spim_out_data_valid_o => lane2_spim_out_data_valid,
    spim_out_data_ready_i => lane2_spim_out_data_ready,
    spim_mode_o           => lane2_spim_mode,
    spim_first_trans_o    => lane2_spim_first_trans,
    spim_lane_ss_i        => lane2_spim_lane_ss,
    fpga_ssn_o            => lane2_fpga_ssn,
    programn_o            => lane2_programn,
    spim_clk_en_o         => lane2_spim_clk_en,
    cfg_cs_dir_o          => lane2_cfg0_cs_dir,
    fpgas_reset_n_o       => fpgas_reset_n_2_o
  );

spi_master_core_0 : spi_master_core
  port map(
    clk_i             => clk_i,
    rst_n_i           => rst_n_i,
    spi_clk_en_i      => lane0_spim_clk_en,
    spi_cfg_i         => lane0_spim_mode,
    first_trans_i     => lane0_spim_first_trans,
    in_data_i         => lane0_spim_out_data,
    in_data_valid_i   => lane0_spim_out_data_valid,
    in_data_ready_o   => lane0_spim_out_data_ready,
    out_data_o        => lane0_spim_in_data,
    out_data_valid_o  => lane0_spim_in_data_valid,
    out_data_ready_i  => lane0_spim_in_data_ready,
    miso_i            => lane0_miso,
    mosi_o            => lane0_mosi,
    sck_o             => lane0_sck,
    ssn_o             => lane0_spim_lane_ss
  );

spi_master_core_1 : spi_master_core
  port map(
    clk_i             => clk_i,
    rst_n_i           => rst_n_i,
    spi_clk_en_i      => lane1_spim_clk_en,
    spi_cfg_i         => lane1_spim_mode,
    first_trans_i     => lane1_spim_first_trans,
    in_data_i         => lane1_spim_out_data,
    in_data_valid_i   => lane1_spim_out_data_valid,
    in_data_ready_o   => lane1_spim_out_data_ready,
    out_data_o        => lane1_spim_in_data,
    out_data_valid_o  => lane1_spim_in_data_valid,
    out_data_ready_i  => lane1_spim_in_data_ready,
    miso_i            => lane1_miso,
    mosi_o            => lane1_mosi,
    sck_o             => lane1_sck,
    ssn_o             => lane1_spim_lane_ss
  );

spi_master_core_2 : spi_master_core
  port map(
    clk_i             => clk_i,
    rst_n_i           => rst_n_i,
    spi_clk_en_i      => lane2_spim_clk_en,
    spi_cfg_i         => lane2_spim_mode,
    first_trans_i     => lane2_spim_first_trans,
    in_data_i         => lane2_spim_out_data,
    in_data_valid_i   => lane2_spim_out_data_valid,
    in_data_ready_o   => lane2_spim_out_data_ready,
    out_data_o        => lane2_spim_in_data,
    out_data_valid_o  => lane2_spim_in_data_valid,
    out_data_ready_i  => lane2_spim_in_data_ready,
    miso_i            => lane2_miso,
    mosi_o            => lane2_mosi,
    sck_o             => lane2_sck,
    ssn_o             => lane2_spim_lane_ss
  );

end architecture struct;
