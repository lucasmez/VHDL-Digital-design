----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:31:39 09/24/2015 
-- Design Name: 
-- Module Name:    testdpe - Behavioral 
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

entity testdpe is
	port(	inp:	in std_logic_vector(7 downto 0);	--dip switches
			sel:	in std_logic;							--switches. Select first or second from dpe
			ledout:	out std_logic_vector(7 downto 0);	--SSD's showing first or second
			led:	out std_logic_vector(7 downto 0);		--LED showing inp
			en:	out std_logic_vector(2 downto 0) --LED enable
		);
end testdpe;

architecture Behavioral of testdpe is

	signal firstled, secled:	std_logic_vector(7 downto 0);
	signal first, sec: std_logic_vector(2 downto 0);	--outputs of dpe component
	
begin

	dpecomp: entity work.dpe 
				port map(req=>inp,first=>first,second=>sec);
 
	--enable only SSD 1. output of LED's
	en <= "110";
	led <= inp;
	--select output
	ledout <= firstled when (sel='0') else secled;
	
	--compute led outputs
	with first select
		firstled(6 downto 0) <= 
				"0000001" when "000",	--0
				"1001111" when "001",	--1
				"0010010" when "010",	--2
				"0000110" when "011",	--3
				"1001100" when "100",	--4
				"0100100" when "101",	--5
				"1100000" when "110",	--6
				"0001111" when "111",	--7
				"0000000" when others;
				
		firstled(7) <= '1';
		
	with sec select
		secled(6 downto 0) <= 
				"0000001" when "000",	--0
				"1001111" when "001",	--1
				"0010010" when "010",	--2
				"0000110" when "011",	--3
				"1001100" when "100",	--4
				"0100100" when "101",	--5
				"1100000" when "110",	--6
				"0001111" when "111",	--7
				"0000000" when others;
				
		secled(7) <= '1';

end Behavioral;

