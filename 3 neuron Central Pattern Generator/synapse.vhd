-- Title : Synapse
-- Author : Jonathan Jennycloss
-- Description: Takes a spike from the pre-synaptic neuron and starts a counter to dekay the time of sending a current to the post-synaptic neuroon.
--              If the counter is still counting down and a spike from the pre-synaptic neuron is detected then a new delay will be stored in a ring buffer.
--              Once the counter is finished, the ring buffer updates the current delay and restarts the counter if there are still current to the post-synaptic neuron.
--              If the counter is finished and there are no more spikes to send to the post-synaptic neuron then the neuron returns to its idle state.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity synapse is
    generic (
        DEPTH : natural
    );
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        pre_spike   : in std_logic;
        delay_orig  : in integer;
        post_spike  : out std_logic

    );
end synapse;

architecture RTL of synapse is

    signal sending          : std_logic     := '0';
    signal cnt              : integer       := 1;
    signal cur_delay        : integer;
    signal new_delay        : integer;
    signal distHt           : integer       := 1;
    signal add_t_h          : std_logic     := '0';
    signal posts_n_pres     : std_logic     := '0';
    signal dh1change        : std_logic     := '0';

    
    type FSM_States is (initial, processing1, processing2, fin_proc);
	signal current_state : FSM_States;

    type FSM_States1 is (init, adder);
	signal CS : FSM_States1;

    type ram_type is array (0 to DEPTH - 1) of integer range 0 to 63;
    signal ram : ram_type;

    subtype index_type is integer range ram_type'range;
    signal head : index_type;
    signal tail : index_type;
    
    -- For incrementing and wrapping around if necessary
    procedure inc(signal index : inout index_type) is
    begin
        if (index = index_type'high) then
            index <= index_type'low;
        else
            index <= index + 1;
        end if;
    end procedure;

    component spiking is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            sending     : in std_logic;
    
            post_spike  : out std_logic
        );
    end component;


begin

    out_s : spiking port map (clk => clk, rst => rst, sending => sending, post_spike => post_spike);

    process(clk, rst, pre_spike)
    begin
        if (rst = '1') then
            current_state <= initial;
        elsif(rising_edge(clk)) then
            case current_state is
                when initial =>
                    if(pre_spike = '1') then
                        cur_delay  <= delay_orig;
                        distHt     <= 1;
                        cnt        <= 1;
                        current_state <= processing1;
                    else
                        current_state <= initial;
                    end if;
                    
                when processing1 =>
                    if (cnt = cur_delay) then
                        sending <= '1';
                        current_state <= fin_proc;
                        if (pre_spike = '1') then
                            posts_n_pres <= '1';
                            new_delay   <= delay_orig;
                            add_t_h     <= '1';
                            distHt <= distHt;
                            if (distHt = 1) then
                                dh1change <= '1';
                            end if;
                        else
                            posts_n_pres <= '0';
                            add_t_h     <= '0';  
                            distHt <= distHt - 1;
                        end if;
                    elsif (cnt < cur_delay) then
                        cnt <= cnt + 1;
                        current_state <= processing2;
                        if (pre_spike = '1') then
                            new_delay   <= delay_orig - cnt;
                            add_t_h     <= '1';
                            distHt      <= distHt + 1;
                        else
                            add_t_h     <= '0';  
                            distHt <= distHt;  
                        end if;
                    end if;
                        
                    
                
                when processing2 =>
                    if (cnt = cur_delay) then
                        sending <= '1';
                        current_state <= fin_proc;
                        if (pre_spike = '1') then
                            posts_n_pres <= '1';
                            new_delay   <= delay_orig;
                            add_t_h     <= '1';
                            distHt <= distHt;
                            if (distHt = 1) then
                                dh1change <= '1';
                            end if;
                        else
                            posts_n_pres <= '0';
                            add_t_h     <= '0';  
                            distHt <= distHt - 1;
                        end if;
                    elsif (cnt < cur_delay) then
                        cnt <= cnt + 1;
                        current_state  <= processing1;
                        if (pre_spike = '1') then
                            new_delay   <= delay_orig - cnt;
                            add_t_h     <= '1';
                            distHt      <= distHt + 1;
                        else
                            add_t_h     <= '0';  
                            distHt <= distHt;  
                        end if;
                    end if;
                    
                
                when fin_proc => 
                    sending     <= '0';
                    inc(tail);
                    if(distHt > 0) then
                        cnt <= 2;
                        posts_n_pres <= '0';
                        current_state <= processing1;
                        if (dh1change = '1') then
                            cur_delay <= delay_orig;
                            dh1change <= '0';
                        else
                            cur_delay <= ram(tail);
                        end if;

                    elsif(distHt = 0) then
                        cur_delay <= delay_orig;
                        if(posts_n_pres = '1') then
                            distHt    <= 1;
                            cnt       <= 2;
                            posts_n_pres <= '0';
                            current_state <= processing1;
                        else
                            current_state <= initial;
                        end if;
                    end if;

                when others => 
                    current_state <= initial;
            end case;
        end if;
	end process;

    process(clk, rst, add_t_h)
    begin
        if (rst = '1') then
            CS            <= init;
        elsif (rising_edge(clk)) then
            case CS is
                when init =>
                    if (add_t_h = '1') then
                        CS <= adder;
                    else
                         CS <= init;
                    end if;
                
                when adder =>
                    ram(head) <= new_delay;
                    inc(head);
                    CS <= init;
                
                when others => 
                    CS <= init;
                
            end case;
        end if;
    end process;

end RTL;