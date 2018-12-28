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

-----------------------------------------------------------------
-- 1. Serializing parallel input data to a MOSI output line.   --
-- 2. Deserializing MISO input line to a parallel output data. --
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity spi_master_core is
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
end entity spi_master_core;


architecture rtl of spi_master_core is
--  user defined types
type spi_fsm_type is (idle, ssn_release, ssn_assert, wait_assert_0, wait_assert_1, wait_assert_2, capture_data, update_data, wait_deassert_0, wait_deassert_1, wait_deassert_2);
--  input signals
signal clk            : std_logic;
signal rst_n          : std_logic;
signal first_trans    : std_logic;
signal in_data        : std_logic_vector (7 downto 0);
signal in_data_valid  : std_logic;
signal out_data_ready : std_logic;
signal miso           : std_logic;
signal spi_clk_en     : std_logic;
signal spi_cfg        : std_logic_vector (1 downto 0);
alias  cpol : std_logic is spi_cfg(1);
alias  cpha : std_logic is spi_cfg(0);
--  output signals
signal in_data_ready  : std_logic;
signal out_data       : std_logic_vector (7 downto 0);
signal out_data_valid : std_logic;
signal mosi           : std_logic;
signal sck            : std_logic;
signal ssn            : std_logic;
--  internal signals
signal spi_fsm          : spi_fsm_type;
signal spi_fsm_reg      : spi_fsm_type;
signal in_data_rd_en    : std_logic;
signal input_data_reg   : std_logic_vector (7 downto 0);
signal mosi_shift_reg   : std_logic_vector (7 downto 0);
signal miso_shift_reg   : std_logic_vector (7 downto 0);
signal first_trans_reg  : std_logic;
signal capture          : std_logic;
signal update           : std_logic;
signal active_edge_cnt  : natural range 0 to 15;
signal in_dat_reg_full  : std_logic;

begin

capture <=  not update;
update  <=  cpol xor cpha;

-- Main state machine for SPI data transfer
spi_transfer_fsm: process (clk)
begin
  if clk = '1' and clk'event then
    if rst_n = '0' then
      spi_fsm         <= idle;
      active_edge_cnt <=  0 ;
      miso_shift_reg  <= (others => '0');
      ssn             <= '1';
      sck             <= cpol;
      mosi_shift_reg  <= (others => '0');
    elsif spi_clk_en = '1' then
      case spi_fsm is
        when idle =>
          miso_shift_reg  <= (others => '0');
          active_edge_cnt <=  0 ;
          ssn             <= first_trans;
          sck             <= cpol;
          if in_data_ready = '0' then
            spi_fsm <= ssn_release;
            mosi_shift_reg <= input_data_reg;
          end if;
        when ssn_release =>
          ssn <= first_trans_reg;
          if active_edge_cnt >= 0 then
            spi_fsm <= ssn_assert;
            active_edge_cnt <= 0;
          else
            active_edge_cnt <= active_edge_cnt + 1;
          end if;
        when ssn_assert =>
          ssn   <= '0';
          spi_fsm <= wait_assert_0;
        when wait_assert_0 =>
          spi_fsm <= wait_assert_1;
        when wait_assert_1 =>
          spi_fsm <= wait_assert_2;
        when wait_assert_2 =>
          if cpha = '1' then
            spi_fsm <= update_data;
          else
            spi_fsm <= capture_data;
          end if;
        when capture_data =>
          sck <= capture;
          miso_shift_reg  <= miso_shift_reg(6 downto 0) & miso;
          if active_edge_cnt = 15 then
            spi_fsm <= wait_deassert_0;
            sck     <= cpol;
          else
            spi_fsm         <= update_data;
            active_edge_cnt <= active_edge_cnt + 1;
          end if;
        when update_data =>
          sck   <= update;
          if cpha = '0' or active_edge_cnt > 0 then
            mosi_shift_reg <= mosi_shift_reg(6 downto 0) & '0';
          end if;
          if active_edge_cnt = 15 then
            spi_fsm <= wait_deassert_0;
            sck     <= cpol;
          else
            active_edge_cnt <= active_edge_cnt + 1;
            spi_fsm <= capture_data;
          end if;
        when wait_deassert_0 =>
          spi_fsm <= wait_deassert_1;
        when wait_deassert_1 =>
          spi_fsm <= wait_deassert_2;
        when wait_deassert_2 =>
          spi_fsm <= idle;
        when others =>
          spi_fsm <= idle;
      end case;
    end if;
  end if;
end process;

-- Driving MOSI output registre
mosi_driver : process(clk)
begin
  if clk = '1' and clk'event then
    if rst_n = '0' or ssn = '1' then
      mosi  <= '1';
    else
      mosi  <= mosi_shift_reg(7);
    end if;
  end if;
end process;

-- Delay of spi_fsm (state).
-- Used in internal logic.
spi_fsm_register : process (clk)
begin
  if clk = '1' and clk'event then
    if rst_n = '0' then
      spi_fsm_reg <= idle;
    else
      spi_fsm_reg <= spi_fsm;
    end if;
  end if;
end process;

-- Forming data and valid for Xillybus side when data is received from SPI.
write_output_data: process (clk)
begin
  if clk = '1' and clk'event then
    if rst_n = '0' then
      out_data       <= (others => '0');
      out_data_valid <= '0';
    else
      if (spi_fsm_reg = capture_data or spi_fsm_reg = update_data) and spi_fsm = idle then
        out_data        <= miso_shift_reg;
        out_data_valid  <= '1';
      end if;
      if out_data_valid = '1' and out_data_ready = '1' then
        out_data_valid  <= '0';
      end if;
    end if;
  end if;
end process;

in_data_rd_en <= '1' when in_data_valid = '1' and in_data_ready = '1' else
                 '0';

-- Reading from Xillybus side.
read_input_data: process (clk)
begin
  if clk = '1' and clk'event then
    if rst_n = '0' then
      input_data_reg  <= (others => '0');
      first_trans_reg <= '0';
      in_data_ready   <= '1';
      in_dat_reg_full <= '0';
    else
      if spi_fsm = idle and in_dat_reg_full = '0' then
        in_data_ready   <= '1';
      elsif spi_fsm_reg = idle and spi_fsm = ssn_release then
        in_dat_reg_full <= '0';
      end if;
      if in_data_rd_en = '1' then
        input_data_reg  <= in_data;
        first_trans_reg <= first_trans;
        in_data_ready   <= '0';
        in_dat_reg_full <= '1';
      end if;
    end if;
  end if;
end process;

--  input signal asignments
clk               <= clk_i;
rst_n             <= rst_n_i;
first_trans       <= first_trans_i;
in_data           <= in_data_i;
in_data_valid     <= in_data_valid_i;
out_data_ready    <= out_data_ready_i;
miso              <= miso_i;
spi_clk_en        <= spi_clk_en_i;
spi_cfg           <= spi_cfg_i;
--  output signal asignments
in_data_ready_o   <= in_data_ready;
out_data_o        <= out_data;
out_data_valid_o  <= out_data_valid;
mosi_o            <= mosi;
sck_o             <= sck;
ssn_o             <= ssn;

end architecture rtl;
