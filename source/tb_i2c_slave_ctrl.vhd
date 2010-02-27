-- $Id: $
-- File name:   tb_i2c_slave_ctrl.vhd
-- Created:     2/25/2010
-- Author:      Micah Fivecoate
-- Lab Section: 337-04
-- Version:     1.0  Initial Test Bench

library ieee;
--library gold_lib;   --UNCOMMENT if you're using a GOLD model
use ieee.std_logic_1164.all;
--use gold_lib.all;   --UNCOMMENT if you're using a GOLD model

entity tb_i2c_slave_ctrl is
end tb_i2c_slave_ctrl;

architecture TEST of tb_i2c_slave_ctrl is

  function INT_TO_STD_LOGIC( X: INTEGER; NumBits: INTEGER )
     return STD_LOGIC_VECTOR is
    variable RES : STD_LOGIC_VECTOR(NumBits-1 downto 0);
    variable tmp : INTEGER;
  begin
    tmp := X;
    for i in 0 to NumBits-1 loop
      if (tmp mod 2)=1 then
        res(i) := '1';
      else
        res(i) := '0';
      end if;
      tmp := tmp/2;
    end loop;
    return res;
  end;

  component i2c_slave_ctrl
    PORT(
         clk : in std_logic;
         rst_n : in std_logic;
         start_flag : in std_logic;
         stop_flag : in std_logic;
         mack_flag : in std_logic;
         stop_rcving : in std_logic;
         rw_flag : in std_logic;
         addr_match : in std_logic;
         sda_ack : out std_logic;
         sda_out_en : out std_logic;
         rxsr_ctrl : out std_logic;
         txsr_ctrl : out std_logic_vector(1 downto 0);
         cnt_en : out std_logic;
         ack_cnt_en : out std_logic;
         tx_renable : out std_logic
    );
  end component;

-- Insert signals Declarations here
  signal clk : std_logic;
  signal rst_n : std_logic;
  signal start_flag : std_logic;
  signal stop_flag : std_logic;
  signal mack_flag : std_logic;
  signal stop_rcving : std_logic;
  signal rw_flag : std_logic;
  signal addr_match : std_logic;
  signal sda_ack : std_logic;
  signal sda_out_en : std_logic;
  signal rxsr_ctrl : std_logic;
  signal txsr_ctrl : std_logic_vector(1 downto 0);
  signal cnt_en : std_logic;
  signal ack_cnt_en : std_logic;
  signal tx_renable : std_logic;

   signal good_sda_ack   : std_logic; 
   signal good_sda_out_en: std_logic; 
   signal good_rxsr_ctrl : std_logic; 
   signal good_txsr_ctrl : std_logic_vector(1 downto 0); 
   signal good_cnt_en    : std_logic; 
   signal good_ack_cnt_en: std_logic; 
   signal good_tx_renable: std_logic; 
-- signal <name> : <type>;

begin
  DUT: i2c_slave_ctrl port map(
                clk => clk,
                rst_n => rst_n,
                start_flag => start_flag,
                stop_flag => stop_flag,
                mack_flag => mack_flag,
                stop_rcving => stop_rcving,
                rw_flag => rw_flag,
                addr_match => addr_match,
                sda_ack => sda_ack,
                sda_out_en => sda_out_en,
                rxsr_ctrl => rxsr_ctrl,
                txsr_ctrl => txsr_ctrl,
                cnt_en => cnt_en,
                ack_cnt_en => ack_cnt_en,
                tx_renable => tx_renable
                );

--   GOLD: <GOLD_NAME> port map(<put mappings here>);

process is


      procedure idle is begin
        good_sda_ack    <= 'Z';
        good_sda_out_en <= '0';
        good_rxsr_ctrl  <= '0';
        good_txsr_ctrl  <= b"00";
        good_cnt_en     <= '0';
        good_ack_cnt_en <= '0';
        good_tx_renable <= '0';
      end idle;
        
      procedure start_on is begin
        good_sda_ack    <= 'Z';
        good_sda_out_en <= '0';
        good_rxsr_ctrl  <= '0';
        good_txsr_ctrl  <= b"00";
        good_cnt_en     <= '0';
        good_ack_cnt_en <= '0';
        good_tx_renable <= '0';
      end start_on;

      procedure address_loading is begin
        good_sda_ack    <= 'Z';
        good_sda_out_en <= '0';
        good_rxsr_ctrl  <= '1';
        good_txsr_ctrl  <= b"00";
        good_cnt_en     <= '1';
        good_ack_cnt_en <= '0';
        good_tx_renable <= '0';
      end address_loading;

      procedure address_full is begin
        good_sda_ack    <= 'Z';
        good_sda_out_en <= '0';
        good_rxsr_ctrl  <= '1';
        good_txsr_ctrl  <= b"00";
        good_cnt_en     <= '1';
        good_ack_cnt_en <= '0';
        good_tx_renable <= '0';
      end address_full;

      procedure send_ack is begin
        good_sda_ack    <= '0';
        good_sda_out_en <= '0';
        good_rxsr_ctrl  <= '0';
        good_txsr_ctrl  <= b"11";
        good_cnt_en     <= '1';
        good_ack_cnt_en <= '1';
        good_tx_renable <= '0';
      end send_ack;

      procedure transmit_data is begin
        good_sda_ack    <= 'Z';
        good_sda_out_en <= '1';
        good_rxsr_ctrl  <= '0';
        good_txsr_ctrl  <= b"10";
        good_cnt_en     <= '1';
        good_ack_cnt_en <= '0';
        good_tx_renable <= '0';
      end transmit_data;

      procedure receive_ack is begin
        good_sda_ack    <= 'Z';
        good_sda_out_en <= '0';
        good_rxsr_ctrl  <= '0';
        good_txsr_ctrl  <= b"00";
        good_cnt_en     <= '1';
        good_ack_cnt_en <= '1';
        good_tx_renable <= '1';
      end receive_ack;
        
      procedure ack_received is begin
        good_sda_ack    <= 'Z';
        good_sda_out_en <= '0';
        good_rxsr_ctrl  <= '0';
        good_txsr_ctrl  <= b"11";
        good_cnt_en     <= '0';
        good_ack_cnt_en <= '0';
        good_tx_renable <= '1';
      end ack_received;

  procedure tick is
  begin
    wait for 10 ns;
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
  end tick;

  procedure start is
  begin
    tick;
    tick;
    start_flag <= '1';
    addr_match <= '0';
    mack_flag <= '1';
    tick;
    start_flag <= '0';
    stop_rcving <= '0';
    tick;
    address_loading;
    tick;
  end start;

  procedure stop is
  begin
    tick;
    tick;
    stop_flag <= '1';
    stop_rcving <= '0';
    tick;
    stop_flag <= '0';
    tick;
    idle;
    tick;
  end stop;

  procedure rmatch is
  begin
    tick;
    tick;
    stop_rcving <= '1';
    addr_match <= '1';
    rw_flag <= '1';
    tick;
    address_full;
    tick;
    send_ack;
    tick;
  end rmatch;

  procedure wmatch is
  begin
    tick;
    tick;
    stop_rcving <= '1';
    addr_match <= '1';
    rw_flag <= '0';
    tick;
    address_full;
    tick;
    idle;
    tick;
  end wmatch;

  procedure nrmatch is
  begin
    tick;
    tick;
    stop_rcving <= '1';
    addr_match <= '0';
    tick;
    address_full;
    tick;
    idle;
    tick;
    tick;
  end nrmatch;

  procedure nwmatch is
  begin
    tick;
    tick;
    rw_flag <= '1';
    stop_rcving <= '1';
    addr_match <= '0';
    tick;
    address_full;
    tick;
    idle;
  end nwmatch;

  procedure sack is
  begin
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    addr_match <= '0';
    tick;
    transmit_data;
  end sack;

  procedure read is
  begin
    transmit_data;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
  end read;

  procedure write is
  begin
    idle;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
    tick;
  end write;

  procedure gack is
  begin
    stop_rcving <= '1';
    tick;
    receive_ack;
    tick;
    mack_flag <= '0';
    tick;
    ack_received;
    tick;
    tick;
    tick;
    tick;
    stop_rcving <= '0';
    mack_flag <= '1';
    tick;
  end gack;

  procedure gnack is
  begin
     stop_rcving <= '1';
     tick;
     receive_ack;
     tick;
     mack_flag <= '1';
     tick;
     tick;
     tick;
     tick;
     tick;
     tick;
     stop_rcving <= '0';
     tick;
     idle;
     transmit_data;
  end gnack;

  procedure rend is
  begin
    tick;
    tick;
    stop_rcving <= '1';
    tick;
    receive_ack;
  end rend;

  procedure reset is
  begin
    idle;
    clk <= '0';
    rst_n <= '1';
    start_flag <= '0';
    stop_flag <= '0';
    mack_flag <= '1';
    stop_rcving <= '0';
    rw_flag <= '0';
    addr_match <= '0';
    tick;
    tick;
    rst_n <= '0';
  end reset;

  begin
    reset;

    start;
    rmatch;
    sack;
    read;
    gack;
    read;
    gack;
    read;
    gack;
    stop;





  end process;
end TEST;
