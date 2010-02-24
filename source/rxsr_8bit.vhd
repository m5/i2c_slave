library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rxsr_8bit is
  port(
    clk       : in std_logic;
    scl       : in std_logic;
    rst_n     : in std_logic;
    ctrl      : in std_logic;
    slsi      : in std_logic;
    rxsr_data : out std_logic_vector(7 downto 0)
    );
end rxsr_8bit;

architecture structural of rxsr_8bit is
  component op_register_8b
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      op       : in  std_logic_vector(2 downto 0);
      in_en    : in  std_logic_vector(7 downto 0);
      data_in  : in  std_logic_vector(7 downto 0);
      data_out : out std_logic_vector(7 downto 0));
  end component;
  signal shift_clock : std_logic;
  signal shift_in    : std_logic_vector(7 downto 0);

begin
  shift_clock <= scl and ctrl;
  shift_in    <= b"0000000" & slsi;

  op_register_8b_1 : op_register_8b
    port map (
      clk      => shift_clock,
      rst      => rst_n,
      op       => b"010",
      in_en    => b"00000001",
      data_in  => shift_in,
      data_out => rxsr_data);
end structural;

