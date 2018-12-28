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

-------------------------------------------------------------
-- 1. Forwarding data from xillybus spi write FIFO to a    --
--    corresponding lane data and configuration controller --
-- 2. Forwarding data from lane data and configuration     --
--    controller to xillybus spi read FIFO.                --
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity spi_fifo_controller is
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
end entity spi_fifo_controller;

architecture rtl of spi_fifo_controller is

signal clk                    : std_logic;
signal rst_n                  : std_logic;
signal in_data                : std_logic_vector(31 downto 0);
signal fifo_empty             : std_logic;
signal fifo_empty_reg         : std_logic;
signal fifo_rd_en             : std_logic;
signal out_data               : std_logic_vector(31 downto 0);
signal fifo_full              : std_logic;
signal fifo_wr_en             : std_logic;
signal lane0_wrdata           : std_logic_vector( 7 downto 0);
signal lane0_wraddress        : std_logic_vector( 2 downto 0);
signal lane0_wrdata_valid     : std_logic;
signal lane0_wrdata_ready     : std_logic;
signal lane1_wrdata           : std_logic_vector( 7 downto 0);
signal lane1_wraddress        : std_logic_vector( 2 downto 0);
signal lane1_wrdata_valid     : std_logic;
signal lane1_wrdata_ready     : std_logic;
signal lane2_wrdata           : std_logic_vector( 7 downto 0);
signal lane2_wraddress        : std_logic_vector( 2 downto 0);
signal lane2_wrdata_valid     : std_logic;
signal lane2_wrdata_ready     : std_logic;
signal lane0_rddata           : std_logic_vector( 7 downto 0);
signal lane0_rdaddress        : std_logic_vector( 2 downto 0);
signal lane0_rddata_valid     : std_logic;
signal lane0_rddata_ready     : std_logic;
signal lane1_rddata           : std_logic_vector( 7 downto 0);
signal lane1_rdaddress        : std_logic_vector( 2 downto 0);
signal lane1_rddata_valid     : std_logic;
signal lane1_rddata_ready     : std_logic;
signal lane2_rddata           : std_logic_vector( 7 downto 0);
signal lane2_rdaddress        : std_logic_vector( 2 downto 0);
signal lane2_rddata_valid     : std_logic;
signal lane2_rddata_ready     : std_logic;
signal lane_select            : std_logic_vector( 2 downto 0);
signal write_data             : std_logic;
signal read_data              : std_logic;
signal lane0_wrdata_valid_reg : std_logic;
signal lane1_wrdata_valid_reg : std_logic;
signal lane2_wrdata_valid_reg : std_logic;

begin

clk                   <= clk_i;
rst_n                 <= rst_n_i;
in_data               <= in_data_i;
fifo_empty            <= fifo_empty_i;
fifo_full             <= fifo_full_i;
lane0_wrdata_ready    <= lane0_wrdata_ready_i;
lane1_wrdata_ready    <= lane1_wrdata_ready_i;
lane2_wrdata_ready    <= lane2_wrdata_ready_i;
lane0_rddata          <= lane0_rddata_i;
lane0_rddata_valid    <= lane0_rddata_valid_i;
lane1_rddata          <= lane1_rddata_i;
lane1_rddata_valid    <= lane1_rddata_valid_i;
lane2_rddata          <= lane2_rddata_i;
lane2_rddata_valid    <= lane2_rddata_valid_i;
fifo_rd_en_o          <= fifo_rd_en;
out_data_o            <= out_data;
fifo_wr_en_o          <= fifo_wr_en;
lane0_wrdata_o        <= lane0_wrdata;
lane0_wraddress_o     <= lane0_wraddress;
lane0_rdaddress_o     <= lane0_rdaddress;
lane0_wrdata_valid_o  <= lane0_wrdata_valid;
lane1_wrdata_o        <= lane1_wrdata;
lane1_wraddress_o     <= lane1_wraddress;
lane1_rdaddress_o     <= lane1_rdaddress;
lane1_wrdata_valid_o  <= lane1_wrdata_valid;
lane2_wrdata_o        <= lane2_wrdata;
lane2_wraddress_o     <= lane2_wraddress;
lane2_rdaddress_o     <= lane2_rdaddress;
lane2_wrdata_valid_o  <= lane2_wrdata_valid;
lane0_rddata_ready_o  <= lane0_rddata_ready;
lane1_rddata_ready_o  <= lane1_rddata_ready;
lane2_rddata_ready_o  <= lane2_rddata_ready;

lane0_wrdata          <= in_data( 7 downto  0);
lane1_wrdata          <= in_data(15 downto  8);
lane2_wrdata          <= in_data(23 downto 16);
lane0_wraddress       <= in_data(26 downto 24);
lane1_wraddress       <= in_data(26 downto 24);
lane2_wraddress       <= in_data(26 downto 24);
lane_select           <= in_data(31 downto 29);
write_data            <= in_data(27);
read_data             <= in_data(28);

fifo_rd_en            <= (not fifo_empty) and
                         (not(lane0_wrdata_valid or lane1_wrdata_valid or lane2_wrdata_valid)) and
                         (lane0_wrdata_valid_reg or lane1_wrdata_valid_reg or lane2_wrdata_valid_reg);

fifo_wr_en            <= '0';
out_data              <= X"00000000";
lane0_rdaddress       <= "000";
lane0_rddata_ready    <= '1';
lane1_rdaddress       <= "000";
lane1_rddata_ready    <= '1';
lane2_rdaddress       <= "000";
lane2_rddata_ready    <= '1';

-- Forming write data valid signals for each lane depending on xillybus write FIFO data out
process (clk, rst_n) begin
  if(rst_n = '0') then
    lane0_wrdata_valid     <= '0';
    lane1_wrdata_valid     <= '0';
    lane2_wrdata_valid     <= '0';
    lane0_wrdata_valid_reg <= '0';
    lane1_wrdata_valid_reg <= '0';
    lane2_wrdata_valid_reg <= '0';
  elsif(clk = '1' and clk'event) then
    if(lane0_wrdata_valid = '0') then
      if(((not fifo_empty_reg) and (not fifo_empty) and lane_select(0) and write_data and (not fifo_rd_en)) = '1') then
        lane0_wrdata_valid <= '1';
      end if;
    else
      if(lane0_wrdata_ready = '1') then
        lane0_wrdata_valid <= '0';
      end if;
    end if;

    if(lane1_wrdata_valid = '0') then
      if(((not fifo_empty_reg) and (not fifo_empty) and lane_select(1) and write_data and (not fifo_rd_en)) = '1') then
        lane1_wrdata_valid <= '1';
      end if;
    else
      if(lane1_wrdata_ready = '1') then
        lane1_wrdata_valid <= '0';
      end if;
    end if;

    if(lane2_wrdata_valid = '0') then
      if(((not fifo_empty_reg) and (not fifo_empty) and lane_select(2) and write_data and (not fifo_rd_en)) = '1') then
        lane2_wrdata_valid <= '1';
      end if;
    else
      if(lane2_wrdata_ready = '1') then
        lane2_wrdata_valid <= '0';
      end if;
    end if;
    lane0_wrdata_valid_reg <= lane0_wrdata_valid;
    lane1_wrdata_valid_reg <= lane1_wrdata_valid;
    lane2_wrdata_valid_reg <= lane2_wrdata_valid;
  end if;
end process;

process (clk, rst_n) begin
  if(rst_n = '0') then
    fifo_empty_reg <= '0';
  elsif(clk = '1' and clk'event) then
    fifo_empty_reg <= fifo_empty;
  end if;
end process;

end architecture rtl;
