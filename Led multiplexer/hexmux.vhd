----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:29:19 10/09/2015 
-- Design Name: 
-- Module Name:    hexmux - Behavioral 
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


entity hexmux is
    Port ( clk, reset : in  STD_LOGIC;
           hex2, hex1, hex0 : in  STD_LOGIC_VECTOR (3 downto 0);
           dp_in : in  STD_LOGIC_VECTOR (2 downto 0);
           en : out  STD_LOGIC_VECTOR (2 downto 0);
           ledout : out  STD_LOGIC_VECTOR (7 downto 0));
end hexmux;

architecture Behavioral of hexmux is
	constant N:		integer := 16;
	signal state: 	unsigned(N-1 downto 0); 
	signal sel:		std_logic_vector(1 downto 0);
	signal hexout:	std_logic_vector(3 downto 0);
	signal dp:		std_logic;
begin

--********************
--49,152 mod counter
--********************
process(clk)
begin
	if(clk'EVENT and clk='1') then
		if(state = "1011111111111111") then		--state = 49151
			state <= (others => '0');
		else
			state <= state + 1;
		end if;
	end if;
end process;

	sel <= std_logic_vector(state(N-1 downto N-2));
	
--********************
--LED and dp select
--********************
	with sel select
		hexout <= 	hex0 when "00",
						hex1 when "01",
						hex2 when others;
						
	with sel select
		dp <= dp_in(0) when "00",
				dp_in(1) when "01",
				dp_in(2) when others;
						
--********************
--en decoder
--********************
	en <= "110" when (sel="00") else
			"101" when (sel="01") else
			"011" when (sel="10") else
			"111";
			
--********************
--Hex to SSD decoder
--********************
	with hexout select
		ledout(6 downto 0) <= 
			"0000001" when "0000",	--0
			"1001111" when "0001",	--1
			"0010010" when "0010",	--2
			"0000110" when "0011",	--3
			"1001100" when "0100",	--4
			"0100100" when "0101",	--5
			"1100000" when "0110",	--6
			"0001111" when "0111",	--7
			"0000000" when "1000",  --8
			"0001100" when "1001",	--9
			"0001000" when "1010",	--A
			"0000000" when "1011",	--B
			"0110001" when "1100",	--C
			"0000001" when "1101",	--D
			"0110000" when "1110",	--E
			"0111000" when others;	--F

	ledout(7) <= dp;
	
end Behavioral;

