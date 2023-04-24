-- Title : Spiker
-- Author : Jonathan Jennycloss
-- Description: Sends a spike out to the post-synaptic neuron for 1 ms if the synapse has decided to send a current to the post-synaptic neuron. 
--              This is initiated by the synapses that have delays between the pre-synaptic neuron and the post-synaptic neuron.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity spiking is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        sending     : in std_logic;

        post_spike  : out std_logic
    );
end spiking;

architecture RTL of spiking is
    
    signal cnt2       : integer                 := 0; 
    constant delay2   : integer                 := 7; -- when delay > 0
    signal sp2        : std_logic               := '0';

    type FSM_States is (no_spike, spike_out1, spike_out2);
	signal current_state : FSM_States;

begin

    process(clk, rst, sending)
    begin
        if (rst = '1') then
            current_state <= no_spike;
        elsif(rising_edge(clk)) then
            case current_state is
                when no_spike =>
                    if (sending = '1') then
                        cnt2 <= 0;
                        sp2  <= '1';
                        current_state  <= spike_out1;
                    else
                        current_state <= no_spike;
                    end if;

                when spike_out1 =>
                    if(cnt2 = delay2) then
                        sp2	     <= '0';
                        current_state     <= no_spike;
                    else
                        sp2  <= '1';
                        cnt2 <= cnt2 + 1;
                        current_state  <= spike_out2; 
                    end if;
                        
                when spike_out2 =>
                    if(cnt2 = delay2) then
                        sp2	     <= '0';
                        current_state     <= no_spike;
                    else
                        sp2  <= '1';
                        cnt2 <= cnt2 + 1;
                        current_state  <= spike_out1; 
                    end if;
                
                when others =>
                     current_state <= no_spike;
            end case;
        end if;
    end process;
    post_spike <= sp2;
    
end RTL;  