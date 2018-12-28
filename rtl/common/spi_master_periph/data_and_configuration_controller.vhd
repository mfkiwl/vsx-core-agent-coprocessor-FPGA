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

-----------------------------------------------------
-- Configuration of SPI fast programming interface --
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity data_and_configuration_controller is
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
end entity data_and_configuration_controller;


architecture rtl of data_and_configuration_controller is

type register_write_fsm_type is ( idle,
                                  delay_ms,
                                  write_to_spi_master,
                                  wait_to_spi_complite,
                                  set_prg_pin,
                                  reset_fpgas
                                );
  -- system signals
signal  clk                 : std_logic;
signal  rstn                : std_logic;
  -- register write interface
signal  wr_data             : std_logic_vector( 7 downto 0);
signal  wr_address          : std_logic_vector( 2 downto 0);
signal  wr_data_valid       : std_logic;
signal  wr_data_ready       : std_logic;
  -- register read interface
signal  rd_data             : std_logic_vector( 7 downto 0);
signal  rd_address          : std_logic_vector( 2 downto 0);
signal  rd_data_valid       : std_logic;
signal  rd_data_ready       : std_logic;
  -- data input interface from spi core
signal  spim_in_data        : std_logic_vector (7 downto 0);
signal  spim_in_data_valid  : std_logic;
signal  spim_in_data_ready  : std_logic;
  -- data output interface to spi core
signal  spim_out_data       : std_logic_vector (7 downto 0);
signal  spim_out_data_valid : std_logic;
signal  spim_out_data_ready : std_logic;
  -- spi configuration signals
-- master mode registers (spi_master_mode_reg(1) => cpol
--                        spi_master_mode_reg(0) => cpha)
signal  spi_master_mode_reg : std_logic_vector( 1 downto 0);
signal  spim_first_trans    : std_logic;
  -- fpga select signals
signal  spim_lane_ss        : std_logic;
signal  fpga_ssn            : std_logic_vector( 6 downto 0);
--  programmn
signal  programn            : std_logic;
signal  cfg_cs_dir          : std_logic;

  -- spi master clock (clock enable)
signal  spim_clk_en         : std_logic;

-------- configuration registers ---------------
-- master baud rate registers defines the spi clock
signal spi_master_baud_rate_reg     : std_logic_vector( 5 downto 0);
signal spi_clk_enable_counter       : natural range 0 to 255;
-- select the active fpga
signal  active_fpga_select_reg      : std_logic_vector( 6 downto 0);
signal  reset_selected_fpgas_reg    : std_logic_vector( 6 downto 0);

-- delay registers
signal delay_for_ms_reg             : std_logic_vector( 7 downto 0);

signal one_ms_pulse_counter         : natural range 0 to 1000;
signal one_ms_pulse                 : std_logic;

signal one_us_pulse_counter         : natural range 0 to 1000;
signal one_us_pulse                 : std_logic;
signal reset_fpgas_counter          : natural range 0 to 1000;

signal register_write_fsm           : register_write_fsm_type;

begin

-- Generating 1 us pulses which is used to generate 1 ms pulses
one_us_pulse_generator : process (clk)
begin
  if clk = '1' and clk'event then
    if rstn = '0' then
      one_us_pulse          <= '0';
      one_us_pulse_counter  <= 0;
    else
      if one_us_pulse_counter < rtl_clk_frequency/1000_000 -1 then --
        one_us_pulse_counter  <= one_us_pulse_counter + 1;
        one_us_pulse          <= '0';
      else
        one_us_pulse_counter  <= 0;
        one_us_pulse          <= '1';
      end if;
    end if;
  end if;
end process one_us_pulse_generator;

-- Generating 1 ms pulses which is used when delay command is received (Delay register should be written)
one_ms_pulse_generator : process (clk)
begin
  if clk = '1' and clk'event then
    if rstn = '0' then
      one_ms_pulse          <= '0';
      one_ms_pulse_counter  <= 0;
    elsif one_us_pulse = '1' then
      if one_ms_pulse_counter < 999 then --
        one_ms_pulse_counter  <= one_ms_pulse_counter + 1;
        one_ms_pulse          <= '0';
      else
        one_ms_pulse_counter  <= 0;
        one_ms_pulse          <= '1';
      end if;
    end if;
  end if;
end process one_ms_pulse_generator;

-- Forming clock enable for SPI master, used in "spi_master_core" main state machine
spi_clk_enable_generator : process (clk)
begin
  if clk = '1' and clk'event then
    if rstn = '0' then
      spi_clk_enable_counter  <= 2;
      spim_clk_en             <= '0';
    else
      if spim_clk_en = '1' then
        spim_clk_en <= '0';
      elsif spi_clk_enable_counter >= to_integer(unsigned(spi_master_baud_rate_reg)) then
        spi_clk_enable_counter <= 2;
        spim_clk_en            <= '1';
      else
        spi_clk_enable_counter <= spi_clk_enable_counter + 1;
        spim_clk_en            <= '0';
      end if;
    end if;
  end if;
end process spi_clk_enable_generator;

-- Writing interface for configuration,
-- data and control registers.
regiter_write_proc : process (clk)
begin
  if clk = '1' and clk'event then
    if rstn = '0' then
      spi_master_mode_reg       <= "00";
      spi_master_baud_rate_reg  <= "010100";  -- 100mhz/20 = 5mb/s defult br
      active_fpga_select_reg    <= (others => '0');
      reset_selected_fpgas_reg  <= (others => '0');
      spim_out_data             <= (others => '0');
      delay_for_ms_reg          <= (others => '0');

      spim_first_trans          <= '0';
      wr_data_ready             <= '0';
      spim_out_data_valid       <= '0';
      cfg_cs_dir                <= '1';
      programn                  <= '1';
      register_write_fsm        <= idle;
    else
      case register_write_fsm is
        when idle =>
          wr_data_ready       <= '1';
          spim_out_data_valid <= '0';
          if wr_data_valid = '1' and wr_data_ready = '1' then -- data transfer
            wr_data_ready       <= '0';
            spim_out_data_valid <= '0';
            case wr_address is
              when "000" => -- write to spi master
                spim_out_data <= wr_data;
                spim_out_data_valid <= '1';
                register_write_fsm  <= write_to_spi_master;
              when "001" => -- delay register
                register_write_fsm  <= delay_ms;
                delay_for_ms_reg    <= wr_data;
              when "010" => -- reset selected fpgas
                register_write_fsm  <= reset_fpgas;
                reset_selected_fpgas_reg <= wr_data(6 downto 0);
              when "011" => -- first byte in burst transfer
                spim_first_trans <= wr_data(0);
              when "100" => -- spi master mode (cpol & cpha)
                -- baud rate register
                if wr_data < "001010" then
                  spi_master_baud_rate_reg <= "001010";
                else
                  spi_master_baud_rate_reg <= wr_data(7 downto 2);
                end if;
                -- spi mode register register
                spi_master_mode_reg <= wr_data(1 downto 0);
              when "101" => -- select fpgas to be programmed
                active_fpga_select_reg <= wr_data(6 downto 0);
              when "110" => -- set programn pin low for minimum 1 us
                register_write_fsm  <= set_prg_pin;
              when "111" => -- level translator directions
                cfg_cs_dir <= wr_data(0);
              when others => --
            end case;
          end if;
        when delay_ms =>
          if delay_for_ms_reg > "0000000" then
            if one_ms_pulse = '1' then
              delay_for_ms_reg <= delay_for_ms_reg - 1;
            end if;
          else
            register_write_fsm <= idle;
          end if;
        when write_to_spi_master =>
          if spim_out_data_ready = '1' and spim_out_data_valid = '1' then
            spim_out_data_valid <= '0';
            register_write_fsm  <= wait_to_spi_complite;
          end if;
        when wait_to_spi_complite =>
          if spim_out_data_ready = '1' then
            register_write_fsm <= idle;
          end if;
        when reset_fpgas =>
          if reset_fpgas_counter < 500 then
            reset_fpgas_counter  <= reset_fpgas_counter + 1;
          else
            reset_fpgas_counter <= 0;
            register_write_fsm  <= idle;
          end if;
        when set_prg_pin =>
          if reset_fpgas_counter  < 500 then
            reset_fpgas_counter   <= reset_fpgas_counter + 1;
            programn              <= '0';
          else
            reset_fpgas_counter   <= 0;
            register_write_fsm    <= idle;
            programn              <= '1';
          end if;
        when others =>
          register_write_fsm <= idle;
      end case;
    end if;
  end if;
end process regiter_write_proc;

fpga_ssn(0) <= not reset_selected_fpgas_reg(0) when register_write_fsm = reset_fpgas else
                spim_lane_ss or (not active_fpga_select_reg(0));
fpga_ssn(1) <= not reset_selected_fpgas_reg(1) when register_write_fsm = reset_fpgas else
                spim_lane_ss or (not active_fpga_select_reg(1));
fpga_ssn(2) <= not reset_selected_fpgas_reg(2) when register_write_fsm = reset_fpgas else
                spim_lane_ss or (not active_fpga_select_reg(2));
fpga_ssn(3) <= not reset_selected_fpgas_reg(3) when register_write_fsm = reset_fpgas else
                spim_lane_ss or (not active_fpga_select_reg(3));
fpga_ssn(4) <= not reset_selected_fpgas_reg(4) when register_write_fsm = reset_fpgas else
                spim_lane_ss or (not active_fpga_select_reg(4));
fpga_ssn(5) <= not reset_selected_fpgas_reg(5) when register_write_fsm = reset_fpgas else
                spim_lane_ss or (not active_fpga_select_reg(5));
fpga_ssn(6) <= not reset_selected_fpgas_reg(6) when register_write_fsm = reset_fpgas else
                spim_lane_ss or (not active_fpga_select_reg(6));

rd_data            <= spim_in_data                    when (rd_address = "000") else
                      delay_for_ms_reg                when (rd_address = "001") else
                      '0' & reset_selected_fpgas_reg  when (rd_address = "010") else
                      "0000000" & spim_first_trans    when (rd_address = "011") else
                      spi_master_baud_rate_reg & "00" when (rd_address = "100") else
                      '0' & active_fpga_select_reg    when (rd_address = "101") else
                      "00000001"                      when (rd_address = "110") else
                      "0000000" & cfg_cs_dir;       --when (rd_address = "111")

rd_data_valid      <= spim_in_data_valid              when (rd_address = "000") else '1';
spim_in_data_ready <= rd_data_valid                   when (rd_address = "000") else '1';

clk                   <= clk_i;
rstn                  <= rstn_i;
wr_data               <= wr_data_i;
wr_address            <= wr_address_i;
wr_data_valid         <= wr_data_valid_i;
rd_address            <= rd_address_i;
rd_data_ready         <= rd_data_ready_i;
spim_in_data          <= spim_in_data_i;
spim_in_data_valid    <= spim_in_data_valid_i;
spim_out_data_ready   <= spim_out_data_ready_i;
spim_lane_ss          <= spim_lane_ss_i;
wr_data_ready_o       <= wr_data_ready;
rd_data_o             <= rd_data;
rd_data_valid_o       <= rd_data_valid;
spim_in_data_ready_o  <= spim_in_data_ready;
spim_out_data_o       <= spim_out_data;
spim_out_data_valid_o <= spim_out_data_valid;
spim_mode_o           <= spi_master_mode_reg;
spim_first_trans_o    <= spim_first_trans;
fpga_ssn_o            <= fpga_ssn;
spim_clk_en_o         <= spim_clk_en;
programn_o            <= programn;
cfg_cs_dir_o          <= cfg_cs_dir;
fpgas_reset_n_o       <= '0' when ((register_write_fsm = reset_fpgas) and (reset_fpgas_counter < 4)) else '1';

end architecture rtl;

