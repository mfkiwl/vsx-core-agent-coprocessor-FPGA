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

----------------------------------------------
-- Generation of 1 second pulses on RGB led --
----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity led_rgb is
port(
  clk          : in  std_logic;
  reset_n      : in  std_logic;
  led0_red_o   : out std_logic;
  led0_green_o : out std_logic;
  led0_blue_o  : out std_logic
);
end led_rgb;

architecture rtl of led_rgb is

signal led0_red_reg   : std_logic;
signal led0_green_reg : std_logic;
signal led0_blue_reg  : std_logic;
signal led_counter    : std_logic_vector(24 downto 0);

begin

led0_red_o   <= led0_red_reg;
led0_green_o <= led0_green_reg;
led0_blue_o  <= led0_blue_reg;

-- Generates 1 second pulses which are connected to LEDs.
process (clk, reset_n) begin
  if(reset_n = '0') then
    led0_red_reg   <= '1';
    led0_green_reg <= '0';
    led0_blue_reg  <= '0';
    led_counter    <= (others => '0');
  elsif(clk = '1' and clk'event) then
    led_counter <= led_counter + 1;
    if(led_counter = 100000000) then
      led0_red_reg   <= not led0_blue_reg;
      led0_green_reg <= not led0_red_reg;
      led0_blue_reg  <= not led0_green_reg;
      led_counter    <= (others => '0');
    end if;
  end if;
end process;

end rtl;
