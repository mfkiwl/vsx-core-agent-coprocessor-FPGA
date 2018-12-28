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

------------------------------------------------------------------------------
-- Forwarding downstream packets from downstream FIFO to xillybus read FIFO --
-- by adding packet preamble at the start of each packet                    --
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ds_packet_rx is
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
end ds_packet_rx;

architecture rtl of ds_packet_rx is

  constant PREAMBLE_START       : std_logic_vector(63 downto 0) := X"FEDCBA9876543210";

  constant STATE_READ_DATA      : std_logic_vector(3 downto 0) := X"0";
  constant STATE_START_PACKET_1 : std_logic_vector(3 downto 0) := X"1";
  constant STATE_START_PACKET_2 : std_logic_vector(3 downto 0) := X"2";
  constant STATE_FIRST_DATA     : std_logic_vector(3 downto 0) := X"3";

  signal start_packet           : std_logic;
  signal state                  : std_logic_vector(3 downto 0);
  signal ds_data                : std_logic_vector(31 downto 0);
  signal ds_fifo_rd_en          : std_logic;
  signal xil_fifo_wr_en         : std_logic;
  signal xil_fifo_din           : std_logic_vector(31 downto 0);
  signal pr_start_wr_en         : std_logic;
  signal pr_start_dout          : std_logic_vector(31 downto 0);
  signal packet_count           : std_logic_vector(31 downto 0);

begin

  xil_fifo_din_o   <= xil_fifo_din;

  ds_data          <= ds_fifo_dout_i(34 downto 27) & ds_fifo_dout_i(25 downto 18) & ds_fifo_dout_i(16 downto 9) & ds_fifo_dout_i(7 downto 0);
  start_packet     <= ds_fifo_dout_i(35) and (not ds_fifo_empty_i);

  ds_fifo_rd_en_o  <= ds_fifo_rd_en;
  xil_fifo_wr_en_o <= xil_fifo_wr_en;

  xil_fifo_din     <= pr_start_dout when (pr_start_wr_en = '1') else ds_data;

  xil_fifo_wr_en   <= pr_start_wr_en or ds_fifo_rd_en;

  ds_fifo_rd_en    <= '1' when ((((state = STATE_READ_DATA) and (start_packet = '0')) or (state = STATE_FIRST_DATA)) and xil_fifo_rd_full_i = '0' and ds_fifo_empty_i = '0') else '0';

  pr_start_wr_en   <= '1' when (((state = STATE_START_PACKET_1) or (state = STATE_START_PACKET_2)) and (xil_fifo_rd_full_i = '0')) else '0';

  pr_start_dout    <= PREAMBLE_START(63 downto 32) when (state = STATE_START_PACKET_1) else
                      PREAMBLE_START(31 downto 0);

-- State-machine of the module.
  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      state <= STATE_READ_DATA;
    elsif (clk = '1' and clk'event) then
      case state is
        when STATE_READ_DATA =>
          if(start_packet = '1') then
            state <= STATE_START_PACKET_1;
          end if;

        when STATE_START_PACKET_1 =>
          if(pr_start_wr_en = '1') then
            state <= STATE_START_PACKET_2;
          end if;

        when STATE_START_PACKET_2 =>
          if(pr_start_wr_en = '1') then
            state <= STATE_FIRST_DATA;
          end if;

        when STATE_FIRST_DATA =>
          if(ds_fifo_rd_en = '1') then
            state <= STATE_READ_DATA;
          end if;

        when others =>
      end case;
    end if;
  end process;

end rtl;
