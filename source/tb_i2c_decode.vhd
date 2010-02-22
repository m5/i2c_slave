-- $Id: $
-- File name:   tb_i2c_decode.vhd
-- Created:     2/21/2010
-- Author:      Micah Fivecoate
-- Lab Section: 337-04
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_i2c_decode is
end tb_i2c_decode;

architecture TEST of tb_i2c_decode is

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

  component i2c_decode
    PORT(
         clk : in std_logic;
         rst : in std_logic;
         scl_in : in std_logic;
         sda_in : in std_logic;
         data : in std_logic_vector(7 downto 0);
         start_flag : out std_logic;
         stop_flag : out std_logic;
         mack_flag : out std_logic;
         addr_match : out std_logic;
         rw_flag : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal rst : std_logic;
  signal scl_in : std_logic;
  signal sda_in : std_logic;
  signal data : std_logic_vector(7 downto 0);
  signal start_flag : std_logic;
  signal stop_flag : std_logic;
  signal mack_flag : std_logic;
  signal addr_match : std_logic;
  signal rw_flag : std_logic;

-- signal <name> : <type>;

begin
  DUT: i2c_decode port map(
                clk => clk,
                rst => rst,
                scl_in => scl_in,
                sda_in => sda_in,
                data => data,
                start_flag => start_flag,
                stop_flag => stop_flag,
                mack_flag => mack_flag,
                addr_match => addr_match,
                rw_flag => rw_flag
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process
  procedure tick is begin
    clk <='1';
    wait for 10 ns;
    clk <='0';
    wait for 10 ns;
  end tick;

  procedure tock is begin
    scl_in <='1';
    clk <='1';
    wait for 10 ns;
    scl_in <='0';
    clk <='0';
    wait for 10 ns;
  end tock;
  begin

-- Insert TEST BENCH Code Here

    clk <= '0';
    rst <= '0';
    scl_in <= '0';
    sda_in <= '0';
    data <= b"00000000";

    tock;
    data <= b"11111111";

    sda_in <= '1';
    tock;

    sda_in <='0';
    data <= b"11110001";
    tock;

    sda_in <= '1';
    data <= b"11110000";
    tock;

    sda_in <= '1';
    data <= b"11110000";
    tock;

    sda_in <= '1';
    data <= b"11110100";
    tock;

    sda_in <= '0';
    tick;
    scl_in <= '1';
    tick;
    sda_in <= '0';
    tick;
    sda_in <= '0';
    tick;
    tick;
    tick;
    sda_in <= '1';
    tick;
    tick;
    tick;
    sda_in <= '0';
    tick;
    tick;
    tick;
    sda_in <= '1';
    tick;
    sda_in <= '0';
    tick;
    sda_in <= '1';
    tick;
    sda_in <= '0';
    tick;

    sda_in <= '0';
    data <= b"10110000";
    tock;

    sda_in <= '1';
    data <= b"11011101";
    tock;
    wait;
  end process;
end TEST;
