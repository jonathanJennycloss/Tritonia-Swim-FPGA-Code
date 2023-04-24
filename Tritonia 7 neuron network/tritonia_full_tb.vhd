library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity s_cells_tb is
end s_cells_tb;

architecture tb of s_cells_tb is
    signal clk : std_logic := '1';
    signal rst : std_logic := '0';

    signal v_TR1 : sfixed(7 downto -10) := to_sfixed(-65, 7, -10);
    signal u_TR1 : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_TR1 : std_logic := '0';

    signal v_DRI : sfixed(7 downto -10) := to_sfixed(-65, 7, -10);
    signal u_DRI : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_DRI : std_logic := '0';

    signal v_DSI : sfixed(7 downto -10) := to_sfixed(-65, 7, -10);
    signal u_DSI : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_DSI : std_logic := '0';

    signal v_C2 : sfixed(7 downto -10) := to_sfixed(-65, 7, -10);
    signal u_C2 : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_C2 : std_logic := '0';

    signal v_VSI : sfixed(7 downto -10) := to_sfixed(-65, 7, -10);
    signal u_VSI : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_VSI : std_logic := '0';

    signal v_VFN : sfixed(7 downto -10) := to_sfixed(-65, 7, -10);
    signal u_VFN : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_VFN : std_logic := '0';

    signal v_DFNB : sfixed(7 downto -10) := to_sfixed(-65, 7, -10);
    signal u_DFNB : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal spike_DFNB : std_logic := '0';

    signal I_D : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal I_C : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal I_V : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal I_VFN : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal output1 : std_logic_vector(6 downto 0) := "0000000";

    constant clk_period : time := 5 ns;

begin

    clk <= not clk after clk_period/2;
    DUT : entity work.network port map(clk => clk, rst => rst, v_TR1 => v_TR1, u_TR1 => u_TR1, spike_TR1 => spike_TR1, v_DRI => v_DRI, u_DRI => u_DRI, spike_DRI => spike_DRI, v_DSI => v_DSI, u_DSI => u_DSI, spike_DSI => spike_DSI, v_C2 => v_C2, u_C2 => u_C2, spike_C2 => spike_C2, v_VSI => v_VSI, u_VSI => u_VSI, spike_VSI => spike_VSI, v_VFN => v_VFN, u_VFN => u_VFN, spike_VFN => spike_VFN, v_DFNB => v_DFNB, u_DFNB => u_DFNB, spike_DFNB => spike_DFNB, I_D => I_D, I_C => I_C, I_V => I_V, I_VFN => I_VFN, output1 => output1);
    --DUT : entity work.network port map(clk => clk, rst => rst, output1 => output1);

    process
    begin
        rst <= '1';
        wait for clk_period;
        rst <='0';
        wait for clk_period;
        wait;
    end process;

end tb;