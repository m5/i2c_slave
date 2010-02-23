library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity op_register_8b is
  port(
    clk      : in  std_logic;
    rst      : in  std_logic;
    op       : in  std_logic_vector(2 downto 0);
    in_en    : in  std_logic_vector(7 downto 0);
    data_in  : in  std_logic_vector(7 downto 0);
    data_out : out std_logic_vector(7 downto 0)
    );
end op_register_8b;

architecture behavioral of op_register_8b is
  signal reg_bus   : std_logic_vector(7 downto 0);
  signal reg_state : std_logic_vector(7 downto 0);
begin

  reg_bus(0) <= data_in(0) when in_en(0) = '1' else reg_state(0);
  reg_bus(1) <= data_in(1) when in_en(1) = '1' else reg_state(1);
  reg_bus(2) <= data_in(2) when in_en(2) = '1' else reg_state(2);
  reg_bus(3) <= data_in(3) when in_en(3) = '1' else reg_state(3);
  reg_bus(4) <= data_in(4) when in_en(4) = '1' else reg_state(4);
  reg_bus(5) <= data_in(5) when in_en(5) = '1' else reg_state(5);
  reg_bus(6) <= data_in(6) when in_en(6) = '1' else reg_state(6);
  reg_bus(7) <= data_in(7) when in_en(7) = '1' else reg_state(7);

  data_out <= reg_bus;

  process(clk, rst, op, reg_bus) is
  begin
    if rst = '1' then
      reg_state <= (others => '0');
    elsif clk'event and clk = '1' then
      case op is
        when "000"  => reg_state <= reg_state;
        when "001"  => reg_state <= reg_bus + 1;
        when "010"  => reg_state <= reg_bus(6 downto 0) & '0';
        when "011"  => reg_state <= '0' & reg_bus(7 downto 1);
        when "100"  => reg_state <= reg_bus(6 downto 0) & reg_bus(7);
        when "101"  => reg_state <= reg_bus(0) & reg_bus(7 downto 1);
        when "110"  => reg_state <= reg_bus;
        when others => reg_state <= reg_state;
      end case;
    end if;
  end process;
end behavioral;
