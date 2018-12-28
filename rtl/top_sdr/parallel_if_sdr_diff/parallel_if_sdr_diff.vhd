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

------------------------------------------------------
-- Parallel interface (transport layer) for Artix   --
-- with FIFO interface to/from internal logic and   --
-- parallel bus to/from external (first slave) FPGA --
------------------------------------------------------

library ieee;
library unisim;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use unisim.vcomponents.all;

entity parallel_if_sdr_diff is
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
end parallel_if_sdr_diff;

architecture rtl of parallel_if_sdr_diff is

  component fifo_ds
    port (
      rst         : in  std_logic;
      wr_clk      : in  std_logic;
      din         : in  std_logic_vector( 8 downto 0);
      wr_en       : in  std_logic;
      full        : out std_logic;
      rd_clk      : in  std_logic;
      dout        : out std_logic_vector(35 downto 0);
      rd_en       : in  std_logic;
      empty       : out std_logic;
      prog_full   : out std_logic
    );
  end component;

  component fifo_us
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      din           : in  std_logic_vector(35 downto 0);
      wr_en         : in  std_logic;
      full          : out std_logic;
      rd_clk        : in  std_logic;
      dout          : out std_logic_vector( 8 downto 0);
      rd_en         : in  std_logic;
      empty         : out std_logic
    );
  end component;

constant STATE_TRANSMIT          : std_logic_vector( 7 downto 0) := X"00";
constant STATE_SEND_00_0         : std_logic_vector( 7 downto 0) := X"01";
constant STATE_SEND_00_1         : std_logic_vector( 7 downto 0) := X"02";
constant STATE_SEND_00_2         : std_logic_vector( 7 downto 0) := X"03";
constant STATE_SEND_00_3         : std_logic_vector( 7 downto 0) := X"04";
constant STATE_SEND_11_0         : std_logic_vector( 7 downto 0) := X"05";
constant STATE_SEND_11_1         : std_logic_vector( 7 downto 0) := X"06";
constant STATE_WAIT_1_1          : std_logic_vector( 7 downto 0) := X"07";
constant STATE_WAIT_1_2          : std_logic_vector( 7 downto 0) := X"08";
constant STATE_WAIT_1_3          : std_logic_vector( 7 downto 0) := X"09";
constant STATE_RECEIVE           : std_logic_vector( 7 downto 0) := X"0A";
constant STATE_WAIT_11           : std_logic_vector( 7 downto 0) := X"0B";
constant STATE_WAIT_2_1          : std_logic_vector( 7 downto 0) := X"0C";
constant STATE_WAIT_2_2          : std_logic_vector( 7 downto 0) := X"0D";
constant STATE_SEND_00_4         : std_logic_vector( 7 downto 0) := X"0E";
constant STATE_SEND_00_5         : std_logic_vector( 7 downto 0) := X"0F";
constant STATE_SEND_00_6         : std_logic_vector( 7 downto 0) := X"10";

constant MAX_TRANSMIT_COUNT      : std_logic_vector(15 downto 0) := X"0080";
constant MAX_RECEIVE_COUNT       : std_logic_vector(15 downto 0) := X"0080";

signal state                     : std_logic_vector( 7 downto 0);

signal downstream_en             : std_logic;
signal downstream_en_reg_1       : std_logic;
signal downstream_en_reg_2       : std_logic;
signal downstream_en_reg_int     : std_logic;
signal downstream_en_reg_ext_1   : std_logic;
signal downstream_en_reg_ext_2   : std_logic;
signal data_tri_state            : std_logic;
signal ready_tri_state           : std_logic;

signal us_fifo_rst               : std_logic;
signal us_fifo_wr_clk            : std_logic;
signal us_fifo_din               : std_logic_vector(35 downto 0);
signal us_fifo_wr_en             : std_logic;
signal us_fifo_full              : std_logic;
signal us_fifo_rd_clk            : std_logic;
signal us_fifo_dout              : std_logic_vector(8 downto 0);
signal us_fifo_rd_en             : std_logic;
signal us_fifo_empty             : std_logic;

signal ds_fifo_rst               : std_logic;
signal ds_fifo_wr_clk            : std_logic;
signal ds_fifo_din               : std_logic_vector(8 downto 0);
signal ds_fifo_wr_en             : std_logic;
signal ds_fifo_full              : std_logic;
signal ds_fifo_almost_full       : std_logic;
signal ds_fifo_rd_clk            : std_logic;
signal ds_fifo_dout              : std_logic_vector(35 downto 0);
signal ds_fifo_rd_en             : std_logic;
signal ds_fifo_empty             : std_logic;

signal has_data_reg              : std_logic;
signal ready_up_reg              : std_logic;

signal has_data_in               : std_logic;
signal ready_up_in               : std_logic;
signal ready_down_out            : std_logic;

signal sdr_data_out              : std_logic_vector(7 downto 0);
signal sdr_data_out_d            : std_logic_vector(7 downto 0);
signal sdr_data_type_out         : std_logic_vector(1 downto 0);
signal sdr_data_type_out_d       : std_logic_vector(1 downto 0);
signal sdr_valid_out             : std_logic;
signal sdr_start_packet_out      : std_logic;
signal sdr_dir_out               : std_logic;
signal sdr_dir_out_d             : std_logic;
signal sdr_clk_out               : std_logic;
signal sdr_clk_out_n             : std_logic;

signal sdr_data_in               : std_logic_vector(7 downto 0);
signal sdr_data_in_d             : std_logic_vector(7 downto 0);
signal sdr_data_type_in          : std_logic_vector(1 downto 0);
signal sdr_data_type_in_d        : std_logic_vector(1 downto 0);
signal sdr_valid_in_d            : std_logic;
signal sdr_start_packet_in_d     : std_logic;
signal sdr_clk_in                : std_logic;
signal sdr_clk_lr                : std_logic;
signal sdr_data_type_in_d_int_11 : std_logic;
signal sdr_data_type_in_d_ext_11 : std_logic;

signal transmit_counter          : std_logic_vector(15 downto 0);
signal receive_counter           : std_logic_vector(15 downto 0);

begin

sdr_clk_out            <= clk_par_if;
sdr_clk_out_n          <= clk_par_if_n;

data_tri_state         <= '0' when (state = STATE_TRANSMIT ) else
                          '0' when (state = STATE_SEND_00_0) else
                          '0' when (state = STATE_SEND_00_1) else
                          '0' when (state = STATE_SEND_00_2) else
                          '0' when (state = STATE_SEND_00_3) else
                          '0' when (state = STATE_SEND_11_0) else
                          '0' when (state = STATE_SEND_11_1) else
                          '0' when (state = STATE_WAIT_1_1 ) else
                          '0' when (state = STATE_SEND_00_4) else
                          '0' when (state = STATE_SEND_00_5) else
                          '0' when (state = STATE_SEND_00_6) else '1';

ready_tri_state        <= '0' when (state = STATE_RECEIVE   ) else
                          '0' when (state = STATE_WAIT_11   ) else '1';

sdr_dir_out            <= '0' when (state = STATE_SEND_11_0) else
                          '0' when (state = STATE_SEND_11_1) else
                          '0' when (state = STATE_WAIT_1_1 ) else
                          '0' when (state = STATE_WAIT_1_2 ) else
                          '0' when (state = STATE_WAIT_1_3 ) else
                          '0' when (state = STATE_RECEIVE  ) else '1';

sdr_valid_out          <= us_fifo_rd_en;
sdr_start_packet_out   <= sdr_valid_out and us_fifo_dout(8);
sdr_data_out           <= us_fifo_dout(7 downto 0);

sdr_data_type_out      <= "11" when (state = STATE_SEND_11_0   ) else
                          "11" when (state = STATE_SEND_11_1   ) else
                          "01" when (sdr_start_packet_out = '1') else
                          "10" when (sdr_valid_out = '1'       ) else
                          "00";

sdr_valid_in_d         <= '1' when (((sdr_data_type_in_d = "01") or (sdr_data_type_in_d = "10")) and (downstream_en = '1')) else '0';
sdr_start_packet_in_d  <= '1' when ((sdr_data_type_in_d = "01") and (downstream_en = '1')) else '0';

ready_down_out         <= not ds_fifo_almost_full;

us_fifo_rst            <= not reset_n;
us_fifo_wr_clk         <= clk_fifo_if;
us_fifo_din            <= us_fifo_din_i;
us_fifo_wr_en          <= us_fifo_wr_en_i;
us_fifo_full_o         <= us_fifo_full;
us_fifo_rd_clk         <= sdr_clk_out;
us_fifo_rd_en          <= '1' when ((us_fifo_empty = '0') and (state = STATE_TRANSMIT) and (ready_up_reg = '1')) else '0';

ds_fifo_rst            <= not reset_n;
ds_fifo_wr_clk         <= sdr_clk_in;
ds_fifo_din            <= sdr_start_packet_in_d & sdr_data_in_d;
ds_fifo_wr_en          <= sdr_valid_in_d;
ds_fifo_rd_clk         <= clk_fifo_if;
ds_fifo_dout_o         <= ds_fifo_dout;
ds_fifo_rd_en          <= ds_fifo_rd_en_i;
ds_fifo_empty_o        <= ds_fifo_empty;

-- State-machine for parallel bus logic
process(sdr_clk_out, reset_n)
begin
  if (reset_n = '0') then
    state   <= STATE_TRANSMIT;
  elsif (sdr_clk_out = '1' and sdr_clk_out'event) then
    case state is

      when STATE_TRANSMIT =>
        if(has_data_reg = '1') then
          if(us_fifo_empty = '1') then
            state <= STATE_SEND_00_0;
          elsif(transmit_counter = MAX_TRANSMIT_COUNT) then
            state <= STATE_SEND_00_0;
          end if;
        end if;

      when STATE_SEND_00_0 =>
        state <= STATE_SEND_00_1;

      when STATE_SEND_00_1 =>
        state <= STATE_SEND_00_2;

      when STATE_SEND_00_2 =>
        state <= STATE_SEND_00_3;

      when STATE_SEND_00_3 =>
        state <= STATE_SEND_11_0;

      when STATE_SEND_11_0 =>
        state <= STATE_SEND_11_1;

      when STATE_SEND_11_1 =>
        state <= STATE_WAIT_1_1;

      when STATE_WAIT_1_1 =>
        state <= STATE_WAIT_1_2;

      when STATE_WAIT_1_2 =>
        state <= STATE_WAIT_1_3;

      when STATE_WAIT_1_3 =>
        state <= STATE_RECEIVE;

      when STATE_RECEIVE =>
        if(has_data_reg = '0') then
          state <= STATE_WAIT_11;
        elsif(receive_counter = MAX_RECEIVE_COUNT) then
          if(us_fifo_empty = '0') then
            state <= STATE_WAIT_11;
          end if;
        end if;

      when STATE_WAIT_11 =>
        if(sdr_data_type_in_d_int_11 = '1') then
          state <= STATE_WAIT_2_1;
        end if;

      when STATE_WAIT_2_1 =>
        state <= STATE_WAIT_2_2;

      when STATE_WAIT_2_2 =>
        state <= STATE_SEND_00_4;

      when STATE_SEND_00_4 =>
        state <= STATE_SEND_00_5;

      when STATE_SEND_00_5 =>
        state <= STATE_SEND_00_6;

      when STATE_SEND_00_6 =>
        state <= STATE_TRANSMIT;

      when others =>

    end case;
  end if;
end process;

-- Counter to leave TRANSMIT state with timeout
-- when data for upstream still exists but
-- first calculation FPGA has data for downstream
process(sdr_clk_out, reset_n)
begin
  if (reset_n = '0') then
    transmit_counter <= (others => '0');
  elsif (sdr_clk_out = '1' and sdr_clk_out'event) then
    if((state = STATE_TRANSMIT) and (has_data_reg = '1'))then
      transmit_counter <= transmit_counter + '1';
    else
      transmit_counter <= (others => '0');
    end if;
  end if;
end process;

-- Counter to leave RECEIVE state with timeout
-- when first calculation FPGA has data for downstream but
-- data for upstream exists
process(sdr_clk_out, reset_n)
begin
  if (reset_n = '0') then
    receive_counter <= (others => '0');
  elsif (sdr_clk_out = '1' and sdr_clk_out'event) then
    if((state = STATE_RECEIVE) and(us_fifo_empty = '0'))then
      receive_counter <= receive_counter + '1';
    else
      receive_counter <= (others => '0');
    end if;
  end if;
end process;

-- Delays of outputs of input/bidirectional buffers with internal clock
process(sdr_clk_out, reset_n)
begin
  if (reset_n = '0') then
    has_data_reg        <= '0';
    ready_up_reg        <= '0';
  elsif (sdr_clk_out = '1' and sdr_clk_out'event) then
    has_data_reg        <= has_data_in;
    ready_up_reg        <= ready_up_in;
  end if;
end process;

-- 1 clock delay of outputs of Bidirectional buffers for use in internal logic
process(sdr_clk_in, reset_n)
begin
  if (reset_n = '0') then
    sdr_data_in_d      <= (others => '0');
    sdr_data_type_in_d <= (others => '0');
  elsif (sdr_clk_in = '1' and sdr_clk_in'event) then
    sdr_data_in_d      <= sdr_data_in;
    sdr_data_type_in_d <= sdr_data_type_in;
  end if;
end process;

-- Forming of downstream enable signal (with internal clock)
process(sdr_clk_out, reset_n)
begin
  if (reset_n = '0') then
    downstream_en_reg_int <= '0';
  elsif (sdr_clk_out = '1' and sdr_clk_out'event) then
    if(state = STATE_WAIT_1_3) then
      downstream_en_reg_int <= '1';
    elsif(sdr_data_type_in_d_int_11 = '1' and state = STATE_WAIT_11) then
      downstream_en_reg_int <= '0';
    end if;
  end if;
end process;

-- Moving downstream enable signal to external clock domain
-- using 2 times delay to prevent metastability.
process(sdr_clk_in, reset_n)
begin
  if (reset_n = '0') then
    downstream_en_reg_ext_1 <= '0';
    downstream_en_reg_ext_2 <= '0';
  elsif (sdr_clk_in = '1' and sdr_clk_in'event) then
    downstream_en_reg_ext_1 <= downstream_en_reg_int;
    downstream_en_reg_ext_2 <= downstream_en_reg_ext_1;
  end if;
end process;

-- Formation for downstream enable signal (main signal for downstream logic)
process(sdr_clk_in, reset_n)
begin
  if (reset_n = '0') then
    downstream_en <= '0';
  elsif (sdr_clk_in = '1' and sdr_clk_in'event) then
    if((downstream_en = '0') and (downstream_en_reg_1 = '0') and (downstream_en_reg_2 = '0')) then
      if((downstream_en_reg_ext_1 = '1') and (downstream_en_reg_ext_2 = '1')) then
        downstream_en <= '1';
      end if;
    else
      if(sdr_data_type_in_d = "11") then
        downstream_en <= '0';
      end if;
    end if;
  end if;
end process;

process(sdr_clk_in, reset_n)
begin
  if (reset_n = '0') then
    downstream_en_reg_1 <= '0';
    downstream_en_reg_2 <= '0';
  elsif (sdr_clk_in = '1' and sdr_clk_in'event) then
    downstream_en_reg_1 <= downstream_en;
    downstream_en_reg_2 <= downstream_en_reg_1;
  end if;
end process;

-- 1 clock delay of internal signals for connecting to inputs of Output/Bidirectional buffers
process(sdr_clk_out, reset_n)
begin
  if (reset_n = '0') then
    sdr_data_out_d            <= (others => '0');
    sdr_data_type_out_d       <= (others => '0');
    sdr_dir_out_d             <= '1';
  elsif (sdr_clk_out = '1' and sdr_clk_out'event) then
    sdr_data_out_d            <= sdr_data_out;
    sdr_data_type_out_d       <= sdr_data_type_out;
    sdr_dir_out_d             <= sdr_dir_out;
  end if;
end process;

-- Forming flag from data_type with external clock
-- This flag shows that downstream is finished
-- until next change from upstream to downstream
process(sdr_clk_in, reset_n)
begin
  if (reset_n = '0') then
    sdr_data_type_in_d_ext_11 <= '0';
  elsif (sdr_clk_in = '1' and sdr_clk_in'event) then
    if(sdr_data_type_in = "11") then
      sdr_data_type_in_d_ext_11 <= '1';
    else
      sdr_data_type_in_d_ext_11 <= '0';
    end if;
  end if;
end process;

-- Delay of "sdr_data_type_in_d_ext_11" flag with internal clock.
-- Used in state-machine logic.
process(sdr_clk_out, reset_n)
begin
  if (reset_n = '0') then
    sdr_data_type_in_d_int_11 <= '0';
  elsif (sdr_clk_out = '1' and sdr_clk_out'event) then
    sdr_data_type_in_d_int_11 <= sdr_data_type_in_d_ext_11;
  end if;
end process;

fifo_us_0 : fifo_us
port map (
  rst         => us_fifo_rst,
  wr_clk      => us_fifo_wr_clk,
  din         => us_fifo_din,
  wr_en       => us_fifo_wr_en,
  full        => us_fifo_full,
  rd_clk      => us_fifo_rd_clk,
  dout        => us_fifo_dout,
  rd_en       => us_fifo_rd_en,
  empty       => us_fifo_empty
);

fifo_ds_0 : fifo_ds
port map (
  rst         => ds_fifo_rst,
  wr_clk      => ds_fifo_wr_clk,
  din         => ds_fifo_din,
  wr_en       => ds_fifo_wr_en,
  full        => ds_fifo_full,
  prog_full   => ds_fifo_almost_full,
  rd_clk      => ds_fifo_rd_clk,
  dout        => ds_fifo_dout,
  rd_en       => ds_fifo_rd_en,
  empty       => ds_fifo_empty
);

sdr_data_0_iob : IOBUFDS
port map (
  IO  => sdr_data_p_io(0),
  IOB => sdr_data_n_io(0),
  O   => sdr_data_in(0),
  I   => sdr_data_out_d(0),
  T   => data_tri_state
);

sdr_data_1_iob : IOBUFDS
port map (
  IO  => sdr_data_p_io(1),
  IOB => sdr_data_n_io(1),
  O   => sdr_data_in(1),
  I   => sdr_data_out_d(1),
  T   => data_tri_state
);

sdr_data_2_iob : IOBUFDS
port map (
  IO  => sdr_data_p_io(2),
  IOB => sdr_data_n_io(2),
  O   => sdr_data_in(2),
  I   => sdr_data_out_d(2),
  T   => data_tri_state
);

sdr_data_3_iob : IOBUFDS
port map (
  IO  => sdr_data_p_io(3),
  IOB => sdr_data_n_io(3),
  O   => sdr_data_in(3),
  I   => sdr_data_out_d(3),
  T   => data_tri_state
);

sdr_data_4_iob : IOBUFDS
port map (
  IO  => sdr_data_p_io(4),
  IOB => sdr_data_n_io(4),
  O   => sdr_data_in(4),
  I   => sdr_data_out_d(4),
  T   => data_tri_state
);

sdr_data_5_iob : IOBUFDS
port map (
  IO  => sdr_data_p_io(5),
  IOB => sdr_data_n_io(5),
  O   => sdr_data_in(5),
  I   => sdr_data_out_d(5),
  T   => data_tri_state
);

sdr_data_6_iob : IOBUFDS
port map (
  IO  => sdr_data_p_io(6),
  IOB => sdr_data_n_io(6),
  O   => sdr_data_in(6),
  I   => sdr_data_out_d(6),
  T   => data_tri_state
);

sdr_data_7_iob : IOBUFDS
port map (
  IO  => sdr_data_p_io(7),
  IOB => sdr_data_n_io(7),
  O   => sdr_data_in(7),
  I   => sdr_data_out_d(7),
  T   => data_tri_state
);

sdr_data_type_0_iob : IOBUFDS
port map (
  IO  => sdr_data_type_p_io(0),
  IOB => sdr_data_type_n_io(0),
  O   => sdr_data_type_in(0),
  I   => sdr_data_type_out_d(0),
  T   => data_tri_state
);

sdr_data_type_1_iob : IOBUFDS
port map (
  IO  => sdr_data_type_p_io(1),
  IOB => sdr_data_type_n_io(1),
  O   => sdr_data_type_in(1),
  I   => sdr_data_type_out_d(1),
  T   => data_tri_state
);

sdr_dir_ob : OBUF
port map (
  O   => sdr_dir_o,
  I   => sdr_dir_out_d
);

has_data_ib : IBUF
port map (
  I   => has_data_i,
  O   => has_data_in
);

ready_iob : IOBUF
port map (
  IO  => ready_io,
  O   => ready_up_in,
  I   => ready_down_out,
  T   => ready_tri_state
);

sdr_clk_rl_ib : IBUFDS
port map (
  O   => sdr_clk_in,
  I   => sdr_clk_rl_p_i,
  IB  => sdr_clk_rl_n_i
);

sdr_clk_lr_ob : OBUFDS
port map (
  O   => sdr_clk_lr_p_o,
  OB  => sdr_clk_lr_n_o,
  I   => sdr_clk_lr
);

sdr_clk_lr_bufg : bufg
port map (
  O   => sdr_clk_lr,
  I   => sdr_clk_out
);

end rtl;
