library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity edge_detector is
  port(clk      : in  std_logic;
        rst     : in  std_logic;
        sig     : in  std_logic;
        enable  : in  std_logic;
        rising  : out std_logic;
        falling : out std_logic
        );
end edge_detector;

architecture behavioral of edge_detector is
  signal old_sig : std_logic;
  signal cur_sig : std_logic;

  begin
  process(clk, rst, sig, enable) is begin
    if rst = '1' or enable='0' then
      old_sig <= sig;
      cur_sig <= sig;
      falling <= '0';
      rising  <= '0';
    elsif clk'event and clk = '1' then
      old_sig <= cur_sig;
      cur_sig <= sig;
      if enable = '1' then
        if old_sig = '1' and cur_sig = '0' then
          falling <= '1';
          rising <= '0';
        elsif old_sig = '0' and cur_sig = '1' then
          rising <= '1';
          falling <= '0';
        else
          falling <= '0';
          rising  <= '0';
        end if;
      end if;
    end if;
  end process;
end architecture;



