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
    bored,
    curious,
    dazed,
    ack_will_speak,
    ack_heard,
    check_heard,
    speech_prep1,
    speech_prep2,
    speaking,
    listening,
    heard,
    yawning,
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
    case state is
      when bored => if start_flag = '1' then
                      next_state <= curious;
                    else
                      next_state <= bored;
                    end if;
      when dazed => if start_flag = '1' then
                      next_state <= dazed;
                    else
                      next_state <= curious;
                    end if;

      when curious => if start_flag = '1' or stop_flag = '1' then
                        next_state <= yawning;
                      else
                        if stop_rcving = '1' then
                          if addr_match = '1' then
                            if rw_flag = '1' then
                              next_state <= ack_speak;
                            else
                              next_state <= ack_listen;
                            end if;
                          else
                            next_state <= bored;
                          end if;
                        else
                          next_state <= curious;
                        end if;
                      end if;

      when ack_heard => if start_flag = '1' or stop_flag = '1' then
                          next_state <= yawning;
                        else
                          if mack_flag <= '1' then
                            next_state <= listening;
                          else
                            next_state <= ack_listen;
                          end if;
                        end if;
                        

      when ack_will_speak => if start_flag = '1' or stop_flag = '1' then
                               next_state <= yawning;
                             else
                               if mack_flag <= '1' then
                                 next_state <= speech_prep1;
                               else
                                 next_state <= ack_will_speak;
                               end if;
                             end if;

      when check_heard => if start_flag = '1' or stop_flag = '1' then
                            next_state <= yawning;
                          else
                            if mack_flag <= '1' then
                              next_state <= speech_prep1;
                            else
                              next_state <= check_heard;
                            end if;
                          end if;
                          
      when speech_prep1 => if start_flag = '1' or stop_flag = '1' then
                             next_state <= yawning;
                           else
                             next_state <= speech_prep2;
                           end if;

      when speech_prep2 => if start_flag = '1' or stop_flag = '1' then
                             next_state <= yawning;
                           else
                             next_state <= speaking;
                           end if;
                           
      when speaking => if start_flag = '1' or stop_flag = '1' then
                         next_state <= yawning;
                       else
                         if stop_rcving = '1' then
                           next_state = check_heard;
                         else
                           next_state = speaking;
                         end if;
                       end if;
                       
      when listening => if start_flag = '1' or stop_flag = '1' then
                          next_state <= yawning;
                        else
                          if stop_rcving = '1' then
                            next_state = ack_heard;
                          else
                            next_state = listening;
                          end if;
                        end if;

      when yawning => next_state <= bored;

      when others => next_state <= yawning;
    end case;
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
      when bored =>
        sda_ack    <= '1';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
        
      when dazed =>
        sda_ack    <= '1';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
        
      when curious =>
        sda_ack    <= '1';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '1';
        ack_cnt_en <= '0';
        tx_renable <= '0';
        
      when ack_heard =>
        sda_ack    <= '0';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '1';
        tx_renable <= '0';
        
      when ack_will_speak =>
        sda_ack    <= '0';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '1';
        tx_renable <= '0';
        
      when check_heard =>
        sda_ack    <= '1';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '1';
        tx_renable <= '0';
        
      when speech_prep1 =>
        sda_ack    <= '1';
        sda_out_en <= '1';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"11";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
        
      when speech_prep2 =>
        sda_ack    <= '1';
        sda_out_en <= '1';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '1';
        
      when speaking =>
        sda_ack    <= '1';
        sda_out_en <= '1';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= "01";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
        
      when listening =>
        sda_ack    <= '1';
        sda_out_en <= '0';
        rxsr_ctrl  <= '1';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
        
      when yawning =>
        sda_ack    <= '1';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
        
      when others =>
        sda_ack    <= '1';
        sda_out_en <= '0';
        rxsr_ctrl  <= '0';
        txsr_ctrl  <= b"00";
        cnt_en     <= '0';
        ack_cnt_en <= '0';
        tx_renable <= '0';
    end process;
  end case;
  

end behavioral;

