-- Title : Tritonia top level entity for testbench
-- Author : Jonathan Jennycloss
-- Description: This file is in charge of connections between neurons and synapses according the properties of the three neuron network being simulated.
--              The currents into post-synaptic neurons is determined by a multiplexer which chooses to send the appropriate weight or zero current to
--               each neuron depending on the output of the synapses.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity network is
    port (
        Clk        : in std_logic;
        rst        : in std_logic;

        vDSI       : out sfixed;
        uDSI       : out sfixed;
        spike_DSI   : out std_logic;

        vC2        : out sfixed;
        uC2        : out sfixed;
        spike_C2    : out std_logic;

        vVSI       : out sfixed;
        uVSI       : out sfixed;
        spike_VSI   : out std_logic;

        I_D         : out sfixed;
        I_C         : out sfixed;
        I_V         : out sfixed;

        output1 : out std_logic_vector(2 downto 0)
    );
end network;

architecture RTL of network is

    constant a 		: sfixed(0 downto -10) 	:= to_sfixed(0.01953125, 0, -10); -- ~0.02
    constant b 		: sfixed(0 downto -10) 	:= to_sfixed(0.2, 0, -10); 
    constant c      : sfixed(7 downto -10)  := to_sfixed(-65, 7, -10);
	constant d		: sfixed(3 downto -10) 	:= to_sfixed(8, 3, -10);
    constant delay  : integer 				:= 5;

    constant delay5  : integer	:= 40;
    constant delay10  : integer	:= 80;
    constant delay20  : integer	:= 160;
    constant delay30  : integer	:= 240;


    constant DEPTH10      : natural   := 10;
    constant DEPTH30      : natural   := 30;
    constant DEPTH20      : natural   := 20;
    constant DEPTH5       : natural   := 5;
 
    constant s_DSI_time     : integer    := 8000; 
    constant zero			: sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    constant weight_DtoC    : sfixed(7 downto -10) := to_sfixed(30, 7, -10);
    constant weight_CtoV    : sfixed(7 downto -10) := to_sfixed(30, 7, -10);
    constant weight_VtoC    : sfixed(7 downto -10) := to_sfixed(-90, 7, -10);
    constant weight_VtoD    : sfixed(7 downto -10) := to_sfixed(-120, 7, -10);

    signal ext_I            : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal w1               : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal w2               : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal w3               : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal w4               : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal C2_current       : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal VSI_current      : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal DSI_current      : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal C2_current1      : sfixed(8 downto -10) := to_sfixed(0, 8, -10);
    signal DSI_current1     : sfixed(8 downto -10) := to_sfixed(0, 8, -10);

    signal C2_spike          : std_logic := '0';
    signal VSI_spike         : std_logic := '0';
    signal DSI_spike         : std_logic := '0';

    signal C2_spike1         : std_logic := '0';
    signal VSI_spike1        : std_logic := '0';
    signal DSI_spike1        : std_logic := '0';

    signal C2_spike2         : std_logic := '0';
    signal VSI_spike2        : std_logic := '0';
    signal DSI_spike2        : std_logic := '0';
    signal VSI_spike3        : std_logic := '0';

    signal v_C2             : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal v_VSI            : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal v_DSI            : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal u_C2             : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal u_VSI            : sfixed(6 downto -10) := to_sfixed(0, 6, -10);
    signal u_DSI            : sfixed(6 downto -10) := to_sfixed(0, 6, -10);

    signal clk2				: std_logic			   := '0';


    component neuron14 is
		Port(
            clk		: in std_logic;
            rst		: in std_logic;
            I_in	: in sfixed;
            a       : in sfixed;
            b       : in sfixed;
            c       : in sfixed;
            d       : in sfixed;
            delay   : in integer;	

            v 		: out sfixed;
            u 		: out sfixed;
            spike	: out std_logic;
            spike2  : out std_logic
        );
	end component;

    component synapse is
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
    end component;

    component s_cells
        port (
            clk 		: in std_logic;
            rst 		: in std_logic;
            ip_length	: in integer;
    
            I : out sfixed
        );
    end component;

    component clk_div is
		port (
			clk         : in std_logic;
            rst         : in std_logic;
            clk_out     : out std_logic
		);
	end component;

begin

    clock 	: clk_div port map(clk => clk, rst => rst, clk_out => clk2);
    --DSI : neuron port map(Clk => Clk2, rst => rst, I_in => DSI_current, a => a, b => b, c => c, d => d, delay => delay, v => v_DSI, u => u_DSI, spike => DSI_spike);
    --C2 : neuron port map(Clk => Clk2, rst => rst, I_in => C2_current, a => a, b => b, c => c, d => d, delay => delay, v => v_C2, u => u_C2, spike => C2_spike);
    --VSI_B : neuron port map(Clk => Clk2, rst => rst, I_in => VSI_current, a => a, b => b, c => c, d => d, delay => delay, v => v_VSI, u => u_VSI, spike => VSI_spike);
    S_DSI   : s_cells port map(clk => clk2, rst => rst, ip_length => s_DSI_time,  I => ext_I);
    DSI     : neuron14 port map(Clk => Clk2, rst => rst, I_in => DSI_current, a => a, b => b, c => c, d => d, delay => delay, v => v_DSI, u => u_DSI, spike => DSI_spike1, spike2 => DSI_spike);
    DSI_C2  : synapse generic map (DEPTH => DEPTH10) port map (clk => clk2, rst => rst, pre_spike => DSI_spike1, delay_orig => delay10, post_spike => DSI_spike2);
   
    C2      : neuron14 port map(Clk => Clk2, rst => rst, I_in => C2_current, a => a, b => b, c => c, d => d, delay => delay, v => v_C2, u => u_C2, spike => C2_spike1, spike2 => C2_spike);
    C2_VSI  : synapse generic map (DEPTH => DEPTH30) port map (clk => clk2, rst => rst, pre_spike => C2_spike1, delay_orig => delay30, post_spike => C2_spike2);

    VSI_B   : neuron14 port map(Clk => Clk2, rst => rst, I_in => VSI_current, a => a, b => b, c => c, d => d, delay => delay, v => v_VSI, u => u_VSI, spike => VSI_spike1, spike2 => VSI_spike);
    VSI_DSI : synapse generic map (DEPTH => DEPTH20) port map (clk => clk2, rst => rst, pre_spike => VSI_spike1, delay_orig => delay20, post_spike => VSI_spike2);
    VSI_C2  : synapse generic map (DEPTH => DEPTH5) port map (clk => clk2, rst => rst, pre_spike => VSI_spike1, delay_orig => delay5, post_spike => VSI_spike3); 

    process(clk2, DSI_spike2)
    begin
        if (rising_edge(clk2)) then
            case DSI_spike2 is
                when '1' =>
                    w1 <= weight_DtoC;
                when others =>
                    w1 <= zero;
            end case;
        end if;
    end process;

    process(clk2, C2_spike2)
    begin
        if(rising_edge(clk2)) then
            case C2_spike2 is
                when '1' =>
                    w2 <= weight_CtoV;
                when others =>
                    w2 <= zero;
            end case;
        end if;
    end process;

    process(clk2, VSI_spike2)
    begin
        if(rising_edge(clk2)) then
            case VSI_spike2 is
                when '1' =>
                    w4 <= weight_VtoD;
                when others =>
                    w4 <= zero;
            end case;
        end if;
    end process;

    process(clk2, VSI_spike3)
    begin
        if(rising_edge(clk2)) then
            case VSI_spike3 is
                when '1' =>
                    w3 <= weight_VtoC;
                when others =>
                    w3 <= zero;
            end case;
        end if;
    end process;

    process(clk, w1, w2, w3, w2, w4, ext_I)
    begin   
        if (rising_edge(clk)) then
            C2_current1  <= w1 + w3;
            VSI_current <= w2;
            DSI_current1 <= w4 + ext_I;
            
            C2_current <= C2_current1(7 downto -10); 
            DSI_current <=  DSI_current1(7 downto -10);
        end if;
    end process;

    --process(clk_u)
    --begin
      --  if (rising_edge(clk_u)) then
            output1(0) <= DSI_spike;
            output1(1) <= VSI_spike;
            output1(2) <= C2_spike;
        --end if;
    --end process;


    spike_C2     <= C2_spike; 
    spike_VSI    <= VSI_spike;
    spike_DSI    <= DSI_spike;

    vC2         <= v_C2;
    vVSI        <= v_VSI;
    vDSI        <= v_DSI;

    uC2         <= u_C2;
    uVSI        <= u_VSI;
    uDSI        <= u_DSI;

    I_D          <= DSI_current;
    I_C          <= C2_current;
    I_V          <= VSI_current;


end RTL;