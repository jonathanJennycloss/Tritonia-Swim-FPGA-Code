library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity network_top_tb is
end network_top_tb;

architecture tb of network_top_tb is
    signal clk          : std_logic := '1';
    signal rst          : std_logic := '0';


    signal vDSI : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal uDSI : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_DSI : std_logic := '0';

    signal vC2 : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal uC2 : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_C2 : std_logic := '0';

    signal vVSI : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal uVSI : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_VSI : std_logic := '0';

    signal I_D : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal I_C : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal I_V : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal output1 : std_logic_vector(2 downto 0) := "000";

    constant clk_period   : time := 5 ns;

begin
    clk   <= not clk after clk_period /2; -- generate clock
    DUT : entity work.network port map (clk => clk, rst => rst, vDSI => vDSI, uDSI => uDSI, spike_DSI => spike_DSI, vC2 => vC2, uC2 => uC2, spike_C2 => spike_C2, vVSI => vVSI, uVSI => uVSI, spike_VSI => spike_VSI, I_D => I_D, I_C => I_C, I_V => I_V, output1 => output1);
    --DUT : entity work.network port map (clk => clk, rst => rst, output1 => output1);
    
    Neuron_Proc : process
    begin
        rst <= '1';
        wait for clk_period;
        rst <='0';
        wait for clk_period;
        wait;

    end process;

end tb;