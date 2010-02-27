library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity i2c_scl_cntr is
  port(
    clk         : in  std_logic;
    scl         : in  std_logic;
    rst_n       : in  std_logic;
    cnt_en      : in  std_logic;
    ack_cnt_en  : in  std_logic;
    stop_rcving : out std_logic
    );
end i2c_scl_cntr;

architecture structural of i2c_scl_cntr is
  component op_register_8b
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      op       : in  std_logic_vector(2 downto 0);
      in_en    : in  std_logic_vector(7 downto 0);
      data_in  : in  std_logic_vector(7 downto 0);
      data_out : out std_logic_vector(7 downto 0));
  end component;

  component edge_detector
    port (
      clk     : in  std_logic;
      rst     : in  std_logic;
      sig     : in  std_logic;
      enable  : in  std_logic;
      rising  : out std_logic;
      falling : out std_logic);
  end component;

  signal count     : std_logic_vector(7 downto 0);
  signal stop_flag : std_logic;
  signal cnt_reset : std_logic;
  signal rising    : std_logic;
  signal falling   : std_logic;
  signal over_full : std_logic;

begin
  -----------------------------------------------------------------------------
  -- i2c_scl_cntr:  This counter counts up on the falling edge of SCL.
  --
  -- The controller expects STOP_RCVING to be set on the falling edge of SCL
  -- between the 8th bit, and the ACK cycle.
  --
  -- As soon as the ACK cycle is over, STOP_RCVING should be deasserted, to let
  -- the controller know that it's time for a new tx cycle
  -----------------------------------------------------------------------------  
  stop_flag   <= '1'     when count = b"00001001" else '0';
  over_full   <= '1' when count = b"00001010" else '0';
  stop_rcving <= stop_flag;
  cnt_reset   <= not cnt_en
                 or over_full
                 or rst_n;

  edge_detector_1 : edge_detector
    port map (
      clk     => clk,
      rst     => rst_n,
      sig     => scl,
      enable  => cnt_en,
      rising  => rising,
      falling => falling);

  op_register_8b_1 : op_register_8b
    port map (
      clk      => falling,
      rst      => cnt_reset,
      op       => "001",                -- op reg in increment mode
      in_en    => b"00000000",
      data_in  => b"00000000",
      data_out => count);

end structural;
