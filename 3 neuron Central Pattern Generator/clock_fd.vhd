-- Title : Clock Frequency Divider
-- Author : Jonathan Jennycloss
-- Description: Takes in 200 MHz clock and outputs a 8000 Hz clock with clock period 0.125 ms.This clock is required for the values of v and u to update every 1ms.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity clk_div is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        clk_out     : out std_logic
    );
end clk_div;

architecture RTL of clk_div is

    signal cnt      : integer   := 1;
    signal clock    : std_logic := '0';

begin

    process(clk, rst)
    begin
        if (rst = '1') then
            cnt     <= 1;
            clock   <= '0';
        elsif (rising_edge(clk)) then
            cnt     <= cnt + 1;
            if (cnt = 12500) then
                clock <= not clock;
                cnt   <= 1;
            end if;
        end if;
    end process;

    clk_out <= clock;

end RTL;
