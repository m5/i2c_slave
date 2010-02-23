entity sync is
  port(
    clk  : in  std_logic;
    sig  : in  std_logic;
    sync : out std_logic
    );
end sync;

architecture behavioral of sync is
  signal sig_sync : std_logic;
begin
  procedure(CLK, RST_N) is
    begin
      if CLK'event and CLK = '1' then
        sig_sync <= sig;
      else
        sig_sync <= sig_sync;
      end if;
    end procedure;
end behavioral;

