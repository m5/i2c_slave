-- $Id: $
-- File name:   tb_i2c_sda_sel.vhd
-- Created:     2/25/2010
-- Author:      Micah Fivecoate
-- Lab Section: 337-04
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_i2c_sda_sel is
end tb_i2c_sda_sel;

architecture TEST of tb_i2c_sda_sel is

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

  component i2c_sda_sel
    PORT(
         sda_out_en : in std_logic;
         sr_sda_out : in std_logic;
         sda_ack : in std_logic;
         sda_out : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal sda_out_en : std_logic;
  signal sr_sda_out : std_logic;
  signal sda_ack : std_logic;
  signal sda_out : std_logic;

-- signal <name> : <type>;

begin
  DUT: i2c_sda_sel port map(
                sda_out_en => sda_out_en,
                sr_sda_out => sr_sda_out,
                sda_ack => sda_ack,
                sda_out => sda_out
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process
  procedure reset is
    sda_out_en <= '0';
    sr_sda_out <= '0';
    sda_ack <= '0';
  end reset;
  begin

  reset;
  wait for 10 ns;
  sda_ack <= '1';
  wait for 10 ns;
  sda_out_en <= '1';
  wait for 10 ns;
  sr_sda_out <= '1';
  wait for 10 ns;
  sda_out_en <= '0';
  wait for 10 ns;
  sda_out <= '1';
  wait for 10 ns;



  end process;
end TEST;
