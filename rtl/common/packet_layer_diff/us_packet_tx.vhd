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

---------------------------------------------------------------------------
-- Forwarding upstream packets from xillybus write FIFO to upstream FIFO --
-- by removing packet preamble at the start of each packet               --
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity us_packet_tx is
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
end us_packet_tx;

architecture rtl of us_packet_tx is

  constant PREAMBLE_VALUE         : std_logic_vector(63 downto 0) := X"FEDCBA9876543210";

  signal   preamble_detected      : std_logic;
  signal   set_start_packet       : std_logic;
  signal   preamble_reg_0         : std_logic_vector(31 downto 0);
  signal   preamble_reg_1         : std_logic_vector(31 downto 0);

  signal   preamble_reg           : std_logic_vector(63 downto 0);
  signal   reg_wr_en              : std_logic;
  signal   us_fifo_wr_en          : std_logic;
  signal   counter_reg            : std_logic_vector(15 downto 0);
  signal   start_packet           : std_logic;

begin

  reg_wr_en          <= (not xil_fifo_rd_empty_i) and (not us_fifo_full_i);
  xil_fifo_rd_en_o   <= reg_wr_en;
  us_fifo_wr_en_o    <= us_fifo_wr_en;


  preamble_reg       <= preamble_reg_0 & preamble_reg_1;
  preamble_detected  <= '1' when ((preamble_reg = PREAMBLE_VALUE) and (counter_reg = X"0000")) else '0';


  start_packet       <= '1' when (reg_wr_en = '1' and set_start_packet = '1') else '0';

  us_fifo_din_o      <= start_packet & xil_fifo_dout_i(31 downto 24) &
                        '0' &          xil_fifo_dout_i(23 downto 16) &
                        '0' &          xil_fifo_dout_i(15 downto  8) &
                        '0' &          xil_fifo_dout_i( 7 downto  0);

  us_fifo_wr_en      <= '1' when (reg_wr_en = '1' and counter_reg /= X"0000") else '0';

  preamble_reg_1 <= xil_fifo_dout_i;

-- Storing 2 last 32-bits words from Xillybus write FIFO.
-- Is used to compare with 64-bit preamble value.
  process(clk, reset_n)
  begin
    if(reset_n = '0') then
      preamble_reg_0 <= (others => '0');
    elsif(clk = '1' and clk'event) then
      if(reg_wr_en = '1') then
        preamble_reg_0 <= preamble_reg_1;
      end if;
    end if;
  end process;

-- Formation of start packet signal when preamble is detected.
-- Counting forwarded packet length.
  process(clk, reset_n)
  begin
    if(reset_n = '0') then
      counter_reg          <= (others => '0');
      set_start_packet     <= '0';
    elsif(clk = '1' and clk'event) then
      if(preamble_detected = '1') then
        set_start_packet <= '1';
      end if;
      if(reg_wr_en = '1') then
        if(preamble_detected = '1') then
          counter_reg <= X"0001";
        elsif(set_start_packet = '1') then
          set_start_packet <= '0';
          counter_reg      <= xil_fifo_dout_i(15 downto 0);
        end if;

        if(counter_reg /= X"0000" and preamble_detected = '0' and set_start_packet = '0') then
          counter_reg <= counter_reg - '1';
        end if;
      end if;
    end if;
  end process;

end rtl;
