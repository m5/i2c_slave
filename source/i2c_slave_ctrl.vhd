library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity i2c_slave_ctrl is
  port(
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
end i2c_slave_ctrl;

architecture behavioral of i2c_slave_ctrl is
  type state_type is (
    idle,
    start_on,
    address_loading,
    address_full,
    send_ack,
    transmit_data,
    done_transmitting,
    receive_ack,
    ack_received
    );

  signal state      : state_type;
  signal next_state : state_type;

begin
  
  process (clk, rst_n)
  begin
    if rst_n = '1' then
      state <= bored;
    elsif clk'event and clk = '1' then
      state <= next_state;
    end if;
  end process;

  process (state,
           start_flag,
           stop_flag,
           mack_flag,
           stop_rcving,
           rw_flag,
           addr_match)
  begin
    if (not (state = idle or state = start_on) and start_flag = '1')
      or stop_flag = '1' then
      next_state <= idle;
    else
      case state is
        when idle => if start_flag = '1' then
                       next_state <= start_on;
                     else
                       next_state <= idle;
                     end if;
                     
        when start_on => if start_flag = '1' then
                           next_state <= start_on;
                         else
                           next_state <= address_loading;
                         end if;
                         
        when address_loading => if stop_rcving = '1' then
                                  next_state <= address_full;
                                else
                                  next_state <= address_loading;
                                end if;
                                
        when address_full => if addr_match = '1' and rw_flag = '1' then
                               next_state <= send_ack;
                             else
                               next_state <= idle;
                             end if;

        when send_ack => if stop_rcving = '0' then
                           next_state <= transmit_data;
                         else
                           next_state <= send_ack;
                         end if;

        when transmit_data => if stop_rcving = '1' then
                                next_state <= receive_ack;
                              else
                                next_state <= transmit_data;
                              end if;

        when receive_ack => if stop_rcving = '0' then
                              next_state <= idle;
                            elsif mack_flag = '0' then
                              next_state <= ack_received;
                            else
                              next_state <= receive_ack;
                            end if;

        when ack_received => if stop_rcving = '0' then
                               next_state <= transmit_data;
                             else
                               next_state <= ack_received;
                             end if;

        when others => next_state <= idle;

      end case;
    end if;
  end process;

  process (state,
           start_flag,
           stop_flag,
           mack_flag,
           stop_rcving,
           rw_flag,
           addr_match)
  begin
    case state is
      -------------------------------------------------------------------------
      -- Moore outputs
      -------------------------------------------------------------------------
      
      -------------------------------------------------------------------------
      -- idle: Don't do anything. Disable all outputs.
      -------------------------------------------------------------------------
      when idle =>
        sda_ack    <= 'Z';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
        
      -------------------------------------------------------------------------
      -- start_on: another idle state. We're just waiting for the start
      --           flag to clear.
      -------------------------------------------------------------------------
      when start_on =>
        sda_ack    <= 'Z';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';

      -------------------------------------------------------------------------
      -- address_loading: This begins when SCL goes LOW for the first time,
      --                    before the first address bit is sent.
      --
      --            1) Load the address and rw bit into rxsr
      --            2) Start the scl counter, so we'll know when it's full
      -------------------------------------------------------------------------
      when address_loading =>
        sda_ack    <= 'Z';
        sda_out_en <= '0';
        rxsr_ctrl  <= '1';
        txsr_ctrl  <= b"00";
        cnt_en     <= '1';
        ack_cnt_en <= '0';
        tx_renable <= '0';

      -------------------------------------------------------------------------
      -- address_full: This begins as soon as SCL goes LOW after the R/W bit is
      --                 stored in rxsr. Nothing new needs to be done here.
      -------------------------------------------------------------------------
      when address_full =>
        sda_ack    <= 'Z';
        sda_out_en <= '0';
        rxsr_ctrl  <= '1';
        txsr_ctrl  <= b"00";
        cnt_en     <= '1';
        ack_cnt_en <= '0';
        tx_renable <= '0';

      -------------------------------------------------------------------------
      -- send_ack: This begins immediately after we have confirmed that the
      --           master is talking to us, and wants us to transmit.
      --           SCL is still low between 8th and 9th bits.
      --
      --      1) Pull sda_ack to 0
      --      2) Keep sda_out_en at 0
      --
      --   Also, we need to load the txsr with the next byte
      --      3) Set txsr_ctrl to "11", load. Data will be loaded when SCL goes
      --         LOW after ACK is sent.
      -------------------------------------------------------------------------
      when send_ack =>
        sda_ack    <= '0';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"11";
        cnt_en     <= '1';
        ack_cnt_en <= '1';
        tx_renable <= '0';

      -------------------------------------------------------------------------
      -- transmit_data: This begins as SCL goes LOW between the 9th bit of the
      --                previous cycle, and the first bit of the new one.
      --
      --      1) Set txsr_ctrl to "10". This will shift the next bit onto
      --         SDA_OUT on the falling edge of each SCL
      --      2) Set sda_out_en to 1. This switches SDA_OUT from our ACK
      --         flag to the txsr's output.
      --      3) Set ack_cnt_en to 1, so we'll know when to quit.
      -------------------------------------------------------------------------
      when transmit_data =>
        sda_ack    <= 'Z';
        sda_out_en <= '1';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"10";
        cnt_en     <= '1';
        ack_cnt_en <= '0';
        tx_renable <= '0';

      -------------------------------------------------------------------------
      -- receive_ack: This starts as SCL goes LOW between the 8th bit, and the
      --              ACK cycle.
      --
      --      1) Set ack_cnt_enable, so the counter will know we're waiting on
      --         an ACK
      --      2) Turn off sda_out_en, in case it would interfere with the master
      --         ACK transmission.
      --
      --   Since the tx cycle completed, we need to tell the txfifo that we
      --   sent the data, so:
      --
      --      3) Set tx_renable. This will decrement the read pointer when SCL
      --         goes to HIGH at the beginning of the ACK cycle
      -------------------------------------------------------------------------
      when recieve_ack =>
        sda_ack    <= 'Z';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '1';
        ack_cnt_en <= '1';
        tx_renable <= '1';
        
      -------------------------------------------------------------------------
      -- ack_received: this starts as soon as an ACK is detected from the
      --               master. This should happen near the beginning of the ACK
      --               cycle, while SCL is still high.
      --
      --      Since we received an ACK, we can load tx data for a new cycle. If
      --      we end up receiving a STOP, it doesn't matter, because we don't
      --      tell the txfifo that we read the data until after we've sent it.
      --
      --      1) Set txsr_ctrl to b"11", to load the new data from the txfifo,
      --         at the end of the ACK cycle.
      -------------------------------------------------------------------------
      when ack_received =>
        sda_ack    <= 'Z';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"11";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '1';

      -------------------------------------------------------------------------
      -- others: This should never happen. If it does, treat it as an idle. It
      --         will be sent to idle on the next clock cycle.
      -------------------------------------------------------------------------
      when others =>
        sda_ack    <= 'Z';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
    end case;
  end process;

end behavioral;

