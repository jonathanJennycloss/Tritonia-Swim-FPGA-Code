-- Title : Sensory Cells
-- Author : Jonathan Jennycloss
-- Description: Initially sends a current of 60 mA to network for 1s and then is silent for the rest of the swim program.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity s_cells is
    port (
        clk 		: in std_logic;
        rst 		: in std_logic;
		ip_length	: in integer;

        I : out sfixed
    );
end s_cells;

architecture RTL of s_cells is

    constant zero       : sfixed(7 downto -10) := to_sfixed(0, 7, -10);
	--constant weight30   : sfixed(7 downto -10) := to_sfixed(30, 7, -10);
    constant weight30   : sfixed(7 downto -10) := to_sfixed(60, 7, -10);
    
    signal ext_I        : sfixed(7 downto -10) := to_sfixed(0, 7, -10);

    signal j 			: integer       := 1; 
    signal cnt          : integer       := 0;

    type FSM_States is (reset, in_I1, in_I2, no_I1, no_I2, no_I_final);
	signal current_state : FSM_States;

begin

    process(clk, rst)
    begin
        if (rst = '1') then
            current_state <= reset;
        elsif (rising_edge(clk)) then
			case current_state is
				when reset =>
					j <= 1;
					cnt <= 1;
					current_state <= no_I1;
					
				when no_I1 =>
					ext_I	<= zero;
					if (cnt = 120) then
						current_state <= in_I1;
					else 
						cnt 	<= cnt + 1;
						current_state <= no_I2;
					end if;
					
				when no_I2 =>
					ext_I	<= zero;
					if (cnt = 120) then
						current_state <= in_I1;
					else 
						cnt 	<= cnt + 1;
						current_state <= no_I1;
					end if;

				when in_I1 =>
					ext_I	<= weight30;
					if (j = ip_length) then
						current_state <= no_I_final;
					else 
						j 	<= j + 1;
						current_state <= in_I2;
					end if;

				when in_I2 =>
					ext_I	<= weight30;
					if (j = ip_length) then
						current_state <= no_I_final;
					else 
						j 	<= j + 1;
						current_state <= in_I1;
					end if;

				when no_I_final =>
					ext_I	<= zero;
					current_state <= no_I_final;
				
				when others =>
					current_state <= reset;
			end case;
		end if;
	end process;
	I   <= ext_I;
	
end RTL;