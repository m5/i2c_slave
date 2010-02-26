-- $Id: $
-- File name:   tb_i2c_scl_cntr.vhd
-- Created:     2/25/2010
-- Author:      Micah Fivecoate
-- Lab Section: 337-04
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_i2c_scl_cntr is
end tb_i2c_scl_cntr;

architecture TEST of tb_i2c_scl_cntr is

  function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
     return STD_LOGIC_VECTOR is
    variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
    variable tmp : INTEGER;
  begin
    tmp := X;
    for i in 0 to NumBits-1 loop
      if (tmp mod 2)=1 then
        res(i) := '1';
      else
        res(i) := '0';
      end if;
      tmp := tmp/2;
    end loop;
    return res;
  end;

  component i2c_scl_cntr
    PORT(
         clk : in std_logic;
         scl : in std_logic;
         rst_n : in std_logic;
         cnt_en : in std_logic;
         ack_cnt_en : in std_logic;
         stop_rcving : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal scl : std_logic;
  signal rst_n : std_logic;
  signal cnt_en : std_logic;
  signal ack_cnt_en : std_logic;
  signal stop_rcving : std_logic;

-- signal <name> : <type>;

begin
  DUT: i2c_scl_cntr port map(
                clk => clk,
                scl => scl,
                rst_n => rst_n,
                cnt_en => cnt_en,
                ack_cnt_en => ack_cnt_en,
                stop_rcving => stop_rcving
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process is
  procedure reset is
  begin 
    clk <= '0';
    scl <= '0';
    rst_n <= '1';
    cnt_en <= '0';
    ack_cnt_en <= '0';
    wait for 10 ns;
    rst_n <= '0';
    
  end reset;

  procedure tick is
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
    clk <- '0';
  end tick;

  procedure multitick(
    constant count : integer) is
  begin
    for i in 1 to count loop
      tick;
    end loop;
  end multitick;

  begin
    reset;
    cnt_en <= '1';
    multitick(10);
    cnt_en <= '0';
    tick;
    ack_cnt_en <= '1';
    multitick(5);
    ack_cnt_en <= '0';
    tick;
    
    cnt_en <= '1';
    multitick(3);
    cnt_en <= '0';
    tick;
    ack_cnt_en <= '1';
    multitick(5);
    ack_cnt_en <= '0';
    tick;

    cnt_en <= '1';
    multitick(9);
    cnt_en <= '0';
    tick;
    ack_cnt_en <= '1';
    multitick(1);
    ack_cnt_en <= '0';
    tick;

  end process;
end TEST;
