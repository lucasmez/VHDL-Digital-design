----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:47:00 09/22/2015 
-- Design Name: 
-- Module Name:    lestest - Behavioral 
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


entity lestest is
    Port ( dipsw : in  STD_LOGIC_VECTOR (2 downto 0);
           ledout : out  STD_LOGIC_VECTOR (7 downto 0);
           en : out  STD_LOGIC_VECTOR(2 downto 0));
end lestest;

architecture Behavioral of lestest is
--ledout:dp abcdefg
begin
	with dipsw select
		ledout(6 downto 0) <= 
			"0000001" when "000",	--0
			"1001111" when "001",	--1
			"0010010" when "010",	--2
			"0000110" when "011",	--3
			"1001100" when "100",	--4
			"0100100" when "101",	--5
			"1100000" when "110",	--6
			"0001111" when "111",	--7
			"0000000" when others;
			
	ledout(7) <= '1';

	en <= "110";

end Behavioral;

