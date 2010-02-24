library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

entity matcher_8b is
  port(
    pattern : in std_logic_vector(7 downto 0);
    data : in std_logic_vector(7 downto 0);
    matches : out std_logic
    );
end matcher_8b;

architecture dataflow of matcher_8b is
begin
    matches <= '1' when data = pattern else '0';
end dataflow;
