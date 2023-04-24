-- Title : Synapse with no delay
-- Author : Jonathan Jennycloss
-- Description: This synapse is for when there is no delay between the pre-synaptic neuron spikeing and sending a current to the post-synaptic neuron.
--              This allows a current to be sent for sufficient time to be received by the post-synaptic neuron.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity synapse0 is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        pre_spike   : in std_logic;
        post_spike  : out std_logic
    );
end synapse0;

architecture RTL of synapse0 is


    signal sp2        : std_logic := '0';
    
    signal cnt2       : integer                 := 0; 
    constant delay2   : integer                 := 8; -- when delay = 0

    type FSM_States is (initial, processing1, processing2, spike_out1, spike_out2);
	signal current_state : FSM_States;


begin

    process(clk, rst, pre_spike)
    begin
        if (rst = '1') then
            current_state <= initial;
        elsif(rising_edge(clk)) then
            case current_state is
                when initial =>
                    if (pre_spike = '1') then
                        cnt2 <= 0;
                        sp2  <= '1';
                        current_state <= spike_out1;
                    else
                        current_state <= initial;
                    end if;
                

                when spike_out1 =>
                    if(cnt2 = delay2) then
                        sp2	   <= '0';
                        current_state <= initial;
                    else
                        sp2  <= '1';
                        cnt2 <= cnt2 + 1;
                        current_state <= spike_out2; 
                    end if;
                
                when spike_out2 =>
                    if(cnt2 = delay2) then
                        sp2	   <= '0';
                        current_state <= initial;
                    else
                        sp2  <= '1';
                        cnt2 <= cnt2 + 1;
                        current_state <= spike_out1; 
                    end if;
                
                when others => 
                  current_state <= initial;
            end case;
        end if;
	end process;
    post_spike <= sp2;


end RTL;