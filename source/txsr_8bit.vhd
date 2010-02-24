library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity txsr_8bit is
  port(
    clk       : in  std_logic;
    scl       : in  std_logic;
    rst_n     : in  std_logic;
    ctrl      : in  std_logic_vector(1 downto 0);
    load      : in  std_logic_vector(7 downto 0);
    txsr_data : out std_logic
    );
end txsr_8bit;

architecture structural of txsr_8bit is
  component op_register_8b
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      op       : in  std_logic_vector(2 downto 0);
      in_en    : in  std_logic_vector(7 downto 0);
      data_in  : in  std_logic_vector(7 downto 0);
      data_out : out std_logic_vector(7 downto 0));
  end component;

  signal op_reg_op    : std_logic_vector(2 downto 0);
  signal op_reg_in_en : std_logic_vector(7 downto 0);
  signal op_reg_out   : std_logic_vector(7 downto 0);
  signal op_reg_clk   : std_logic;

begin
  op_reg_op <= b"010" when ctrl = b"10" else  -- shift left
               b"110" when ctrl = b"11" else  -- load
               b"000";                        -- do nothing

  op_reg_in_en <= b"11111111" when ctrl = b"11" else
                  b"00000000";

  op_reg_clk <= not scl when ctrl = b"10" or ctrl = b"11" else '1';

  txsr_data <= op_reg_out(7);

  op_register_8b_1 : op_register_8b
    port map (
      clk      => op_reg_clk,
      rst      => rst_n,
      op       => op_reg_op,
      in_en    => op_reg_in_en,
      data_in  => load,
      data_out => op_reg_out);

end structural;
