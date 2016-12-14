----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:53:32 09/24/2015 
-- Design Name: 
-- Module Name:    dpe - Behavioral 
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
use IEEE.NUMERIC_STD.all;

entity dpe is
	--Generic( N: integer := 3);
    Port ( req : in  STD_LOGIC_VECTOR (7 downto 0);
           first : out  STD_LOGIC_VECTOR (2 downto 0);
           second : out  STD_LOGIC_VECTOR (2 downto 0));
end dpe;

architecture Behavioral of dpe is

begin

process(req)
	variable firsttemp, sectemp: natural range 0 to 7;
begin
	firsttemp := 0;
	sectemp := 0;
	
	for i in req'RANGE loop
		if (req(i) = '1') then
			firsttemp := i+1;
			exit;
		end if;
	end loop;
	
	for j in firsttemp-2 downto 0 loop
		if (req(j)='1') then
			sectemp := j+1;
			exit;
		end if;
	end loop;
	
	first <= std_logic_vector(to_unsigned(firsttemp, 3));
	second <= std_logic_vector(to_unsigned(sectemp, 3));
end process;

end Behavioral;


