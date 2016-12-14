----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:08:29 09/26/2015 
-- Design Name: 
-- Module Name:    bcd - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity bcd is
	port(	inc:					in std_logic;
			dig1,dig2,dig3:	out std_logic_vector(3 downto 0)
		);
end bcd;

architecture Behavioral of bcd is
begin

process(inc)
	variable dig1t, dig2t, dig3t: unsigned(3 downto 0);
begin
	if (inc='1') then
		if (dig1t="1001") then
			dig1t := "0000";
			if (dig2t="1001") then
				dig2t := "0000";
				if (dig3t="1001") then
					dig3t := "0000";
				else
					dig3t := dig3t + 1;
				end if;
			else
				dig2t := dig2t + 1;
			end if;
		else
			dig1t := dig1t + 1;
		end if;
	end if;
	
	dig1 <= std_logic_vector(dig1t);
	dig2 <= std_logic_vector(dig2t);
	dig3 <= std_logic_vector(dig3t);
end process;

end Behavioral;

