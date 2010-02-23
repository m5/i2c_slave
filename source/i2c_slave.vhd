entity i2c_slave is
  port(
    CLK        : in  std_logic;
    RST_N      : in  std_logic;
    SCL        : in  std_logic;
    SDA_IN     : in  std_logic;
    TX_WENABLE : in  std_logic;
    TX_WDATA   : in  std_logic_vector(7 downto 0);
    SDA_OUT    : out std_logic;
    TX_EMPTY   : out std_logic;
    TX_FULL    : out std_logic
    );
end i2c_slave;

architecture structural of i2c_slave is
  component sync
    port (
      clk  : in  std_logic;
      sig  : in  std_logic;
      sync : out std_logic
      );
  end component;
  signal scl_sync : std_logic;


  component i2c_slave_ctrl
    port (
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      start_flag  : in  std_logic;
      stop_flag   : in  std_logic;
      mack_flag   : in  std_logic;
      stop_rcving : in  std_logic;
      rw_flag     : in  std_logic;
      addr_match  : in  std_logic;
      sda_ack     : out std_logic;
      sda_out_en  : out std_logic;
      rxsr_ctrl   : out std_logic;
      txsr_ctrl   : out std_logic_vector(1 downto 0);
      cnt_en      : out std_logic;
      ack_cnt_en  : out std_logic;
      tx_renable  : out std_logic);
  end component;
  signal sda_ack    : std_logic;
  signal sda_out_en : std_logic;
  signal rxsr_ctrl  : std_logic;
  signal txsr_ctrl  : std_logic_vector(1 downto 0);
  signal cnt_en     : std_logic;
  signal ack_cnt_en : std_logic;
  signal tx_renable : std_logic;

  component i2c_decode
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      scl_in     : in  std_logic;
      sda_in     : in  std_logic;
      data       : in  std_logic_vector(7 downto 0);
      start_flag : out std_logic;
      stop_flag  : out std_logic;
      mack_flag  : out std_logic;
      addr_match : out std_logic;
      rw_flag    : out std_logic);
  end component;
  signal start_flag : std_logic;
  signal stop_flag  : std_logic;
  signal mack_flag  : std_logic;
  signal addr_match : std_logic;
  signal rw_flag    : std_logic;


  component rxsr_8bit
    port (
      clk       : in  std_logic;
      scl       : in  std_logic;
      rst_n     : in  std_logic;
      ctrl      : in  std_logic;
      slsi      : in  std_logic;
      rxsr_data : out std_logic_vector(7 downto 0));
  end component;
  signal rxsr_data : std_logic_vector(7 downto 0);

  component txsr_8bit
    port (
      clk       : in  std_logic;
      scl       : in  std_logic;
      rst_n     : in  std_logic;
      ctrl      : in  std_logic_vector(1 downto 0);
      load      : in  std_logic_vector(7 downto 0);
      txsr_data : out std_logic);
  end component;
  signal txsr_data : std_logic;

  component tx_fifo
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      renable : in  std_logic;
      wenable : in  std_logic;
      wdata   : in  std_logic_vector(7 downto 0);
      rdata   : out std_logic_vector(7 downto 0);
      empty   : out std_logic;
      full    : out std_logic);
  end component;
  signal rdata   : std_logic_vector(7 downto 0);
  signal empty   : std_logic;
  signal full    : std_logic;

  component i2c_sda_sel
    port (
      sda_out_en : in  std_logic;
      sr_sda_out : in  std_logic;
      sda_ack    : in  std_logic;
      sda_out    : out std_logic);
  end component;

  component i2c_scl_cntr
    port (
      clk         : in  std_logic;
      scl         : in  std_logic;
      rst_n       : in  std_logic;
      cnt_en      : in  std_logic;
      ack_cnt_en  : out std_logic;
      stop_rcving : out std_logic);
  end component;
  signal ack_cnt_en  : std_logic;
  signal stop_rcving : std_logic;
  
begin
  sync_1 : sync
    port map (
      clk  => CLK,
      sig  => SCL,
      sync => scl_sync
      );

  i2c_slave_ctrl_1 : i2c_slave_ctrl
    port map (
      clk         => CLK,
      rst_n       => RST_N,
      start_flag  => start_flag,
      stop_flag   => stop_flag,
      mack_flag   => mack_flag,
      stop_rcving => stop_rcving,
      rw_flag     => rw_flag,
      addr_match  => addr_match,
      sda_ack     => sda_ack,
      sda_out_en  => sda_out_en,
      rxsr_ctrl   => rxsr_ctrl,
      txsr_ctrl   => txsr_ctrl,
      cnt_en      => cnt_en,
      ack_cnt_en  => ack_cnt_en,
      tx_renable  => tx_renable);

  i2c_decode_1 : i2c_decode
    port map (
      clk        => CLK,
      rst        => RST_N,
      scl_in     => scl_sync,
      sda_in     => SDA_IN,
      data       => rxsr_data,
      start_flag => start_flag,
      stop_flag  => stop_flag,
      mack_flag  => mack_flag,
      addr_match => addr_match,
      rw_flag    => rw_flag);

  rxsr_8bit_1 : rxsr_8bit
    port map (
      clk       => CLK,
      scl       => scl_sync,
      rst_n     => RST_N,
      ctrl      => ctrl,
      slsi      => slsi,
      rxsr_data => rxsr_data);

  txsr_8bit_1 : txsr_8bit
    port map (
      clk       => CLK,
      scl       => scl_sync,
      rst_n     => RST_N,
      ctrl      => ctrl,
      load      => rdata,
      txsr_data => sr_sda_out);
  
  tx_fifo_1: tx_fifo
    port map (
      clk     => CLK,
      rst_n   => RST_N,
      renable => renable,
      wenable => TX_WENABLE,
      wdata   => TX_WDATA,
      rdata   => rdata,
      empty   => TX_EMPTY,
      full    => TX_FULL);
  
  i2c_sda_sel_1: i2c_sda_sel
    port map (
      sda_out_en => sda_out_en,
      sr_sda_out => sr_sda_out,
      sda_ack    => sda_ack,
      sda_out    => SDA_OUT);
  
  i2c_scl_cntr_1: i2c_scl_cntr
    port map (
      clk         => CLK,
      scl         => scl_sync,
      rst_n       => RST_N,
      cnt_en      => cnt_en,
      ack_cnt_en  => ack_cnt_en,
      stop_rcving => stop_rcving);

end structural;
