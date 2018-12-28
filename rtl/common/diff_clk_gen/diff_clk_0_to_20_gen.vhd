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

--------------------------------------------------
-- Generation of 21 differential 100 MHz clocks --
-- from 100 MHz single-ended input clock        --
--------------------------------------------------

library ieee;
library unisim;
use ieee.std_logic_1164.all;
use unisim.vcomponents.all;

entity diff_clk_0_to_20_gen is
port (
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
end diff_clk_0_to_20_gen;

architecture rtl of diff_clk_0_to_20_gen is

  signal clkout0       : std_logic;
  signal clkout0b      : std_logic;
  signal clkfbout      : std_logic;
  signal clkfboutb     : std_logic;
  signal clk_ddr       : std_logic;
  signal locked        : std_logic;
  signal pwrdwn        : std_logic;
  signal rst           : std_logic;
  signal clkfbin       : std_logic;
  signal clk_obufds_00 : std_logic;
  signal clk_obufds_01 : std_logic;
  signal clk_obufds_02 : std_logic;
  signal clk_obufds_03 : std_logic;
  signal clk_obufds_04 : std_logic;
  signal clk_obufds_05 : std_logic;
  signal clk_obufds_06 : std_logic;
  signal clk_obufds_07 : std_logic;
  signal clk_obufds_08 : std_logic;
  signal clk_obufds_09 : std_logic;
  signal clk_obufds_10 : std_logic;
  signal clk_obufds_11 : std_logic;
  signal clk_obufds_12 : std_logic;
  signal clk_obufds_13 : std_logic;
  signal clk_obufds_14 : std_logic;
  signal clk_obufds_15 : std_logic;
  signal clk_obufds_16 : std_logic;
  signal clk_obufds_17 : std_logic;
  signal clk_obufds_18 : std_logic;
  signal clk_obufds_19 : std_logic;
  signal clk_obufds_20 : std_logic;
  signal ce            : std_logic;

begin

  rst <= not reset_n;

  ce     <= '1';
  pwrdwn <= '0';

  MMCME2_BASE_INST : MMCME2_BASE
  generic map (
    BANDWIDTH          => "OPTIMIZED",
    CLKFBOUT_MULT_F    => 10.0,
    CLKFBOUT_PHASE     => 0.0,
    CLKIN1_PERIOD      => 10.0,
    -- clkout0_divide   - clkout6_divide: divide amount for each clkout (1-128)
    CLKOUT1_DIVIDE     => 1,
    CLKOUT2_DIVIDE     => 1,
    CLKOUT3_DIVIDE     => 1,
    CLKOUT4_DIVIDE     => 1,
    CLKOUT5_DIVIDE     => 1,
    CLKOUT6_DIVIDE     => 1,
    CLKOUT0_DIVIDE_F   => 10.0,
    -- clkout0_duty_cycle - clkout6_duty_cycle: duty cycle for each clkout (0.01-0.99).
    CLKOUT0_DUTY_CYCLE => 0.5,
    CLKOUT1_DUTY_CYCLE => 0.5,
    CLKOUT2_DUTY_CYCLE => 0.5,
    CLKOUT3_DUTY_CYCLE => 0.5,
    CLKOUT4_DUTY_CYCLE => 0.5,
    CLKOUT5_DUTY_CYCLE => 0.5,
    CLKOUT6_DUTY_CYCLE => 0.5,
    -- clkout0_phase - clkout6_phase: phase offset for each clkout (-360.000-360.000).
    CLKOUT0_PHASE      => 0.0,
    CLKOUT1_PHASE      => 0.0,
    CLKOUT2_PHASE      => 0.0,
    CLKOUT3_PHASE      => 0.0,
    CLKOUT4_PHASE      => 0.0,
    CLKOUT5_PHASE      => 0.0,
    CLKOUT6_PHASE      => 0.0,
    CLKOUT4_CASCADE    => false,
    DIVCLK_DIVIDE      => 1,
    REF_JITTER1        => 0.0,
    STARTUP_WAIT       => false
  )
  port map (
    -- clock outputs: 1-bit (each) output: user configurable clock outputs
    clkout0            => clkout0 ,
    clkout0b           => clkout0b ,
    clkout1            => open ,
    clkout1b           => open ,
    clkout2            => open ,
    clkout2b           => open ,
    clkout3            => open ,
    clkout3b           => open ,
    clkout4            => open ,
    clkout5            => open ,
    clkout6            => open ,
    -- feedback clocks: 1-bit (each) output: clock feedback ports
    clkfbout           => clkfbout,
    clkfboutb          => clkfboutb,
    -- status ports: 1-bit (each) output: mmcm status ports
    locked             => locked,
    -- clock inputs: 1-bit (each) input: clock input
    clkin1             => clk_in_100,
    -- control ports: 1-bit (each) input: mmcm control ports
    pwrdwn             => pwrdwn,
    rst                => rst,
    -- feedback clocks: 1-bit (each) input: clock feedback ports
    clkfbin            => clkfbin
  );

  BUFG_inst_0 : BUFG
  port map (
    I => clkfbout,
    O => clkfbin
  );

  BUFG_inst_1 : BUFG
  port map (
    I => clkout0,
    O => clk_ddr
  );

  ODDR_INST_00 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_00,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_01 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_01,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_02 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_02,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_03 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_03,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_04 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_04,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_05 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_05,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_06 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_06,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_07 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_07,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_08 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_08,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_09 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_09,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_10 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_10,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_11 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_11,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_12 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_12,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_13 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_13,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_14 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_14,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_15 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_15,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_16 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_16,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_17 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_17,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_18 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_18,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_19 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_19,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  ODDR_INST_20 : ODDR
  generic map (
    ddr_clk_edge => "OPPOSITE_EDGE",
    init => '0',
    srtype => "SYNC"  -- reset type ("async" or "sync")
  )
  port map (
    q  => clk_obufds_20,
    c  => clk_ddr,
    ce => ce,
    d1 => '1',
    d2 => '0',
    r  => rst,
    s  => '0'
  );

  OBUFDS_00 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_00_p,
    ob        => clk_out_00_n,
    i         => clk_obufds_00
  );

  OBUFDS_01 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_01_p,
    ob        => clk_out_01_n,
    i         => clk_obufds_01
  );

  OBUFDS_02 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_02_p,
    ob        => clk_out_02_n,
    i         => clk_obufds_02
  );

  OBUFDS_03 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_03_p,
    ob        => clk_out_03_n,
    i         => clk_obufds_03
  );

  OBUFDS_04 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_04_p,
    ob        => clk_out_04_n,
    i         => clk_obufds_04
  );

  OBUFDS_05 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_05_p,
    ob        => clk_out_05_n,
    i         => clk_obufds_05
  );

  OBUFDS_06 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_06_p,
    ob        => clk_out_06_n,
    i         => clk_obufds_06
  );

  OBUFDS_07 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_07_p,
    ob        => clk_out_07_n,
    i         => clk_obufds_07
  );

  OBUFDS_08 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_08_p,
    ob        => clk_out_08_n,
    i         => clk_obufds_08
  );

  OBUFDS_09 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_09_p,
    ob        => clk_out_09_n,
    i         => clk_obufds_09
  );

  OBUFDS_10 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_10_p,
    ob        => clk_out_10_n,
    i         => clk_obufds_10
  );

  OBUFDS_11 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_11_p,
    ob        => clk_out_11_n,
    i         => clk_obufds_11
  );

  OBUFDS_12 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_12_p,
    ob        => clk_out_12_n,
    i         => clk_obufds_12
  );

  OBUFDS_13 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_13_p,
    ob        => clk_out_13_n,
    i         => clk_obufds_13
  );

  OBUFDS_14 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_14_p,
    ob        => clk_out_14_n,
    i         => clk_obufds_14
  );

  OBUFDS_15 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_15_p,
    ob        => clk_out_15_n,
    i         => clk_obufds_15
  );

  OBUFDS_16 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_16_p,
    ob        => clk_out_16_n,
    i         => clk_obufds_16
  );

  OBUFDS_17 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_17_p,
    ob        => clk_out_17_n,
    i         => clk_obufds_17
  );

  OBUFDS_18 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_18_p,
    ob        => clk_out_18_n,
    i         => clk_obufds_18
  );

  OBUFDS_19 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_19_p,
    ob        => clk_out_19_n,
    i         => clk_obufds_19
  );

  OBUFDS_20 : OBUFDS
  generic map (
    iostandard => "default",
    slew       => "slow"
  )
  port map (
    o         => clk_out_20_p,
    ob        => clk_out_20_n,
    i         => clk_obufds_20
  );

end rtl;
