entity i2c_scl_cntr is
  port(
    clk         : in  std_logic;
    scl         : in  std_logic;
    rst_n       : in  std_logic;
    cnt_en      : in  std_logic;
    ack_cnt_en  : out std_logic;
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

  signal count     : std_logic_vector(7 downto 0);
  signal count_clk : std_logic;
  signal stop_flag : std_logic;

begin
  stop_flag   <= '1' when count = b"00001000" else '0';
  count_clk   <= scl when stop_flag = '0'     else '0';
  stop_rcving <= stop_flag;
  
  op_register_8b_1 : op_register_8b
    port map (
      clk      => count_clk,
      rst      => not cnt_en,
      op       => "001",                -- op reg in increment mode
      in_en    => b"00000000",
      data_in  => b"00000000",
      data_out => count);

end structural;
