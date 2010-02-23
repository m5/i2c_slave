entity i2c_sda_sel is
  port(
    sda_out_en : in  std_logic;
    sr_sda_out : in  std_logic;
    sda_ack    : in  std_logic;
    sda_out    : out std_logic
    );
end i2c_sda_sel;

architecture dataflow of i2c_sda_sel is
begin
  sda_out <= sda_ack when sda_out_en = '0' else sr_sda_out;
end dataflow;
