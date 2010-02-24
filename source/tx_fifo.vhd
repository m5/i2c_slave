library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tx_fifo is
  port(
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    renable : in  std_logic;
    wenable : in  std_logic;
    wdata   : in  std_logic_vector(7 downto 0);
    rdata   : out std_logic_vector(7 downto 0);
    empty   : out std_logic;
    full    : out std_logic
    );
end tx_fifo;

LIBRARY ECE337_IP;

architecture structural of tx_fifo is
  component Fifo337IP
    port (
      rclk    : in  std_logic;
      wclk    : in  std_logic;
      rst_n   : in  std_logic;
      renable : in  std_logic;
      wenable : in  std_logic;
      wdata   : in  std_logic_vector(7 downto 0);
      rdata   : out std_logic_vector(7 downto 0);
      empty   : out std_logic;
      full    : out std_logic
      );
  end component;

  signal wclock_in : std_logic;

begin
  wclock_in <= not clk;

  Fifo337IP_1 : Fifo337IP
    port map (
      rclk    => clk,
      wclk    => wclock_in,
      rst_n   => rst_n,
      renable => renable,
      wenable => wenable,
      wdata   => wdata,
      rdata   => rdata,
      empty   => empty,
      full    => full);
end structural;
