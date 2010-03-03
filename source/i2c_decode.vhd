library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity i2c_decode is
  port(clk        : in  std_logic;
       rst        : in  std_logic;
       scl_in     : in  std_logic;
       sda_in     : in  std_logic;
       data       : in  std_logic_vector(7 downto 0);
       start_flag : out std_logic;
       stop_flag  : out std_logic;
       mack_flag  : out std_logic;
       addr_match : out std_logic;
       rw_flag    : out std_logic
       );
end i2c_decode;



architecture structural of i2c_decode is
  
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

  component matcher_8b
    port (
      pattern : in  std_logic_vector(7 downto 0);
      data    : in  std_logic_vector(7 downto 0);
      matches : out std_logic);
  end component;

  signal match_data : std_logic_vector(7 downto 0);

  signal delay_in : std_logic_vector(7 downto 0);
  signal delay_out : std_logic_vector(7 downto 0);
  signal delayed_sda : std_logic;

begin
  
  match_data <= data(7 downto 1) & '0';
  check_addr : matcher_8b
    port map (
      pattern => b"11110000",
      data    => match_data,
      matches => addr_match);

  
  stop_start_det : edge_detector
    port map (
      clk     => clk,
      rst     => rst,
      sig     => sda_in,
      enable  => scl_in,
      rising  => start_flag,
      falling => stop_flag);

  rw_flag   <= data(0);
  mack_flag <= not data(0);


  
  delay_in <= b"0000000" & sda_in;
              
  op_register_8b_1 : op_register_8b
    port map (
      clk      => clk,
      rst      => rst,
      op       => "010",
      in_en    => in_en,
      data_in  => delayed_in;
      data_out => delayed_out);
  
  delayed_sda <= delayed_out(4);
  
end structural;
