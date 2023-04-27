-- Title : Tritonia Top Level Entity for testbench
-- Author : Jonathan Jennycloss
-- Description: This file is in charge of connections between neurons and synapses according the properties of the seven neuron network being simulated.
--              The currents into post-synaptic neurons is determined by a multiplexer which chooses to send the appropriate weight or zero current to
--               each neuron depending on the output of the synapses.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity network is
    port (
        Clk 		: in std_logic;
        rst 		: in std_logic;

        v_TR1 		: out sfixed;
        u_TR1 		: out sfixed;
        spike_TR1 	: out std_logic;

        v_DRI 		: out sfixed;
        u_DRI 		: out sfixed;
        spike_DRI 	: out std_logic;

        v_DSI 		: out sfixed;
        u_DSI 		: out sfixed;
        spike_DSI 	: out std_logic;

        v_C2 		: out sfixed;
        u_C2 		: out sfixed;
        spike_C2 	: out std_logic;

        v_VSI 		: out sfixed;
        u_VSI 		: out sfixed;
        spike_VSI   	: out std_logic;

        v_VFN 		: out sfixed;
        u_VFN 		: out sfixed;
        spike_VFN 	: out std_logic;

        v_DFNB 		: out sfixed;
        u_DFNB 		: out sfixed;
        spike_DFNB 	: out std_logic;

        I_D 		: out sfixed;
        I_C 		: out sfixed;
        I_V 		: out sfixed;
        I_VFN 		: out sfixed;

        output1 	: out std_logic_vector(6 downto 0)

    );
end network;

architecture RTL of network is

    -- Dimensionless parameters for the Izhilevich neuron.
    constant a 		: sfixed(0 downto -10) 	:= to_sfixed(0.01953125, 0, -10); -- ~0.02
    constant b 		: sfixed(0 downto -10) 	:= to_sfixed(0.2, 0, -10); 
    constant c          : sfixed(7 downto -10)  := to_sfixed(-65, 7, -10);
    constant d		: sfixed(3 downto -10) 	:= to_sfixed(8, 3, -10);
    
    -- Delay in neuron when spiking. This delay allows the neuron to spike for 1 ms.
    constant delay  	: integer 		:= 5;
	
    -- The current into the Tr1 and DRI neurons ends at 1015 ms. 
    constant s_Tr1_time : integer    		:= 8120; 
    constant s_DRI_time : integer 		:= 8120;     

    -- Delays between the time of the spike of the pre-synaptic neuron and the time the current is sent to the post-synaptic neuron.
    constant delay0  	: integer	:= 0;
    constant delay1  	: integer	:= 8;
    constant delay5  	: integer	:= 40;
    constant delay10  	: integer	:= 80;
    constant delay20  	: integer	:= 160;
    constant delay30  	: integer	:= 240;
    constant delay35  	: integer	:= 280;
    constant delay60  	: integer	:= 480;

    -- The number of memory locations within the ring buffer within the synapse.
    constant DEPTH10    : natural   	:= 10;
    constant DEPTH35    : natural   	:= 35;
    constant DEPTH60    : natural   	:= 60;
    constant DEPTH30    : natural   	:= 30;
    constant DEPTH20    : natural   	:= 20;
    constant DEPTH5     : natural   	:= 5;
    constant DEPTH1     : natural   	:= 1;
	
   -- The different magnitudes of the inhibitory and excitatory synaptic currents.
    constant zero        : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    constant weight30    : sfixed(7 downto -10) := to_sfixed(30, 7, -10);
    constant weight60n   : sfixed(7 downto -10) := to_sfixed(-60, 7, -10);
    constant weight90n   : sfixed(7 downto -10) := to_sfixed(-90, 7, -10);
    constant weight120n  : sfixed(7 downto -10) := to_sfixed(-120, 7, -10);
    
    signal weight_StoDRI : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_TtoDr  : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_DrtoD  : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal weight_DtoC  : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_DtoVf : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_DtoDf : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal weight_CtoDr : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_CtoV  : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_CtoDf : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal weight_VtoD  : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_VtoC  : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_VtoVf : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal weight_VtoDf : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal TR1_current  : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal DRI_current  : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal DRI_current1 : sfixed(8 downto -10) := to_sfixed(0, 8, -10);
    signal DRI_current2 : sfixed(9 downto -10) := to_sfixed(0, 9, -10);

    signal C2_current     : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal C2_current1    : sfixed(8 downto -10) := to_sfixed(0, 8, -10);

    signal VSI_current    : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal DSI_current    : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal DSI_current1   : sfixed(8 downto -10) := to_sfixed(0, 8, -10);

    signal VFN_current    : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal VFN_current1   : sfixed(8 downto -10) := to_sfixed(0, 8, -10);

    signal DFNB_current   : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
    signal DFNB_current1  : sfixed(8 downto -10) := to_sfixed(0, 8, -10);
    signal DFNB_current2  : sfixed(9 downto -10) := to_sfixed(0, 9, -10);

    signal C2_spike          : std_logic := '0';
    signal VSI_spike         : std_logic := '0';
    signal DSI_spike         : std_logic := '0';

    signal TR1_spike      : std_logic := '0';
    signal DRI_spike      : std_logic := '0';

    signal TR1_spike1      : std_logic := '0';
    signal DRI_spike1      : std_logic := '0';
    signal TR1_spike2      : std_logic := '0';
    signal DRI_spike2      : std_logic := '0';

    signal C2_spike1       : std_logic := '0';
    signal C2_spike2       : std_logic := '0';
    signal C2_spike3       : std_logic := '0';
    signal C2_spike4       : std_logic := '0';

    signal VSI_spike1      : std_logic := '0';
    signal VSI_spike2      : std_logic := '0';
    signal VSI_spike3      : std_logic := '0';
    signal VSI_spike4      : std_logic := '0';

    signal DSI_spike1      : std_logic := '0';
    signal DSI_spike2      : std_logic := '0';
    signal DSI_spike3      : std_logic := '0';
    signal DSI_spike4      : std_logic := '0';

    signal VFN_spike      : std_logic := '0';
    signal DFNB_spike     : std_logic := '0';
    signal VFN_spike1     : std_logic := '0';
    signal DFNB_spike1    : std_logic := '0';

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

    component synapse0 is
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            pre_spike   : in std_logic;
            post_spike  : out std_logic
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

begin

    clock 	: clk_div port map(clk => clk, rst => rst, clk_out => clk2);
    -- sensory neurons
    S_TR1 : s_cells port map(clk => clk2, rst => rst, ip_length => s_Tr1_time,  I => Tr1_current);
    S_DRI : s_cells port map(clk => clk2, rst => rst, ip_length => s_DRI_time, I => weight_StoDRI);

    -- Command interneurons
    Tr1     : neuron14 port map(Clk => Clk2, rst => rst, I_in => TR1_current, a => a, b => b, c => c, d => d, delay => delay, v => v_TR1, u => u_TR1, spike => TR1_spike1, spike2 => TR1_spike);
    Tr1_DRI : synapse0 port map (clk => clk2, rst => rst, pre_spike => TR1_spike1, post_spike => TR1_spike2);
    DRI     : neuron14 port map(Clk => Clk2, rst => rst, I_in => DRI_current, a => a, b => b, c => c, d => d, delay => delay, v => v_DRI, u => u_DRI, spike => DRI_spike1, spike2 => DRI_spike);
    DRI_DSI : synapse0 port map (clk => clk2, rst => rst, pre_spike => DRI_spike1, post_spike => DRI_spike2);
 
    -- CPG network
    DSI     : neuron14 port map(Clk => Clk2, rst => rst, I_in => DSI_current, a => a, b => b, c => c, d => d, delay => delay, v => v_DSI, u => u_DSI, spike => DSI_spike1, spike2 => DSI_spike);
    DSI_C2  : synapse generic map (DEPTH => DEPTH10) port map (clk => clk2, rst => rst, pre_spike => DSI_spike1, delay_orig => delay10, post_spike => DSI_spike2);
    DSI_VFN : synapse generic map (DEPTH => DEPTH35) port map (clk => clk2, rst => rst, pre_spike => DSI_spike1, delay_orig => delay35, post_spike => DSI_spike3);
    DSI_DFN : synapse0 port map (clk => clk2, rst => rst, pre_spike => DSI_spike1, post_spike => DSI_spike4);

    C2      : neuron14 port map(Clk => Clk2, rst => rst, I_in => C2_current, a => a, b => b, c => c, d => d, delay => delay, v => v_C2, u => u_C2, spike => C2_spike1, spike2 => C2_spike);
    C2_DRI  : synapse generic map (DEPTH => DEPTH60) port map (clk => clk2, rst => rst, pre_spike => C2_spike1, delay_orig => delay60, post_spike => C2_spike2);
    C2_VSI  : synapse generic map (DEPTH => DEPTH30) port map (clk => clk2, rst => rst, pre_spike => C2_spike1, delay_orig => delay30, post_spike => C2_spike3);
    C2_DFN  : synapse0 port map (clk => clk2, rst => rst, pre_spike => C2_spike1, post_spike => C2_spike4);

    VSI_B   : neuron14 port map(Clk => Clk2, rst => rst, I_in => VSI_current, a => a, b => b, c => c, d => d, delay => delay, v => v_VSI, u => u_VSI, spike => VSI_spike1, spike2 => VSI_spike);
    VSI_DSI : synapse generic map (DEPTH => DEPTH20) port map (clk => clk2, rst => rst, pre_spike => VSI_spike1, delay_orig => delay20, post_spike => VSI_spike2);
    VSI_C2vfn  : synapse generic map (DEPTH => DEPTH5) port map (clk => clk2, rst => rst, pre_spike => VSI_spike1, delay_orig => delay5, post_spike => VSI_spike3); --for c2 and vfn
    VSI_DFN : synapse generic map (DEPTH => DEPTH1) port map (clk => clk2, rst => rst, pre_spike => VSI_spike1, delay_orig => delay1, post_spike => VSI_spike4);

    -- Motor neurons
    VFN : neuron14 port map(Clk => Clk2, rst => rst, I_in => VFN_current, a => a, b => b, c => c, d => d, delay => delay, v => v_VFN, u => u_VFN, spike => VFN_spike1, spike2 => VFN_spike);
    DFN_B : neuron14 port map(Clk => Clk2, rst => rst, I_in => DFNB_current, a => a, b => b, c => c, d => d, delay => delay, v => v_DFNB, u => u_DFNB, spike => DFNB_spike1, spike2 => DFNB_spike);
    

    process(clk2, TR1_spike2)
    begin
        if (rising_edge(clk2)) then
            case TR1_spike2 is
                when '1' =>
                    weight_TtoDr <= weight30;
                when others =>
                    weight_TtoDr <= zero;
            end case;
        end if;
    end process;

    process(clk2, DRI_spike2)
    begin
        if (rising_edge(clk2)) then
            case DRI_spike2 is
                when '1' =>
                    weight_DrtoD <= weight30;
                when others =>
                    weight_DrtoD <= zero;
            end case;
        end if;
    end process;

    process(clk2, DSI_spike2)
    begin
        if (rising_edge(clk2)) then
            case DSI_spike2 is
                when '1' =>
                    weight_DtoC <= weight30;
                when others =>
                    weight_DtoC <= zero;
            end case;
        end if;
    end process;

    process(clk2, DSI_spike3)
    begin
        if (rising_edge(clk2)) then
            case DSI_spike3 is
                when '1' =>
                    weight_DtoVf <= weight60n;
                when others =>
                    weight_DtoVf <= zero;
            end case;
        end if;
    end process;
    
    process(clk2, DSI_spike4)
    begin
        if (rising_edge(clk2)) then
            case DSI_spike4 is
                when '1' =>
                    weight_DtoDf <= weight30;
                when others =>
                    weight_DtoDf <= zero;
            end case;
        end if;
    end process;

    process(clk2, C2_spike2)
    begin
        if (rising_edge(clk2)) then
            case C2_spike2 is
                when '1' =>
                    weight_CtoDr <= weight30;
                when others =>
                    weight_CtoDr <= zero;
            end case;
        end if;
    end process;

    process(clk2, C2_spike3)
    begin
        if (rising_edge(clk2)) then
            case C2_spike3 is
                when '1' =>
                    weight_CtoV  <= weight30;
                when others =>
                    weight_CtoV  <= zero;
            end case;
        end if;
    end process;

    process(clk2, C2_spike4)
    begin
        if (rising_edge(clk2)) then
            case C2_spike4 is
                when '1' =>
                    weight_CtoDf <= weight30;
                when others =>
                    weight_CtoDf <= zero;
            end case;
        end if;
    end process;

    process(clk2, VSI_spike2)
    begin
        if (rising_edge(clk2)) then
            case VSI_spike2 is
                when '1' =>
                    weight_VtoD <= weight120n;
                when others =>
                    weight_VtoD <= zero;
            end case;
        end if;
    end process;

    process(clk2, VSI_spike3)
    begin
        if (rising_edge(clk2)) then
            case VSI_spike3 is
                when '1' =>
                    weight_VtoC <= weight90n;
                    weight_VtoVf <= weight30;
                when others =>
                    weight_VtoC <= zero;
                    weight_VtoVf <= zero;
            end case;
        end if;
    end process;

    process(clk2, VSI_spike4)
    begin
        if (rising_edge(clk2)) then
            case VSI_spike4 is
                when '1' =>
                    weight_VtoDf <= weight90n;
                when others =>
                    weight_VtoDf <= zero;
            end case;
        end if;
    end process;

    process(clk) -- updates quicker than the neuron calculations by using the 5 ns clock
    begin
        if (rising_edge(clk)) then
            DRI_current1 <= weight_StoDRI + weight_TtoDr;
            DRI_current2 <= DRI_current1 + weight_CtoDr; 

            DSI_current1 <= weight_DrtoD + weight_VtoD;
            C2_current1 <= weight_DtoC + weight_VtoC;
            VFN_current1 <= weight_DtoVf + weight_VtoVf;
            DFNB_current1 <= weight_DtoDf + weight_VtoDf;
            DFNB_current2 <= DFNB_current1 + weight_CtoDf;

            VSI_current <= weight_CtoV;

            DRI_current  <=  DRI_current2(7 downto -10);
            DSI_current  <= DSI_current1(7 downto -10);
            C2_current   <= C2_current1(7 downto -10);
            VFN_current  <= VFN_current1(7 downto -10);
            DFNB_current <= DFNB_current2(7 downto -10);
        end if;
    end process;

   output1(0) <= TR1_spike;
   output1(1) <= DRI_spike;

   output1(2) <= DSI_spike;
   output1(3) <= VSI_spike;
   output1(4) <= C2_spike;

   output1(5) <= VFN_spike;
   output1(6) <= DFNB_spike;


    spike_TR1 <= TR1_spike;
    spike_DRI <= DRI_spike;

    spike_DSI <= DSI_spike;
    spike_VSI <= VSI_spike;
    spike_C2  <= C2_spike;

    spike_VFN  <= VFN_spike;
    spike_DFNB <= DFNB_spike;

    I_D <= DSI_current;
    I_c <= C2_current;
    I_v <= VSI_current;
    I_VFN <= VFN_current;


end RTL;
