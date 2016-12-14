----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:53:01 09/28/2015 
-- Design Name: 
-- Module Name:    ledmux - Behavioral 
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


entity ledmux is
	port(	clk:					in std_logic;
			led0,led1,led2:	in std_logic_vector(7 downto 0);
			ledout:				out std_logic_vector(7 downto 0);
			en:					out std_logic_vector(2 downto 0)
	);	
end ledmux;

architecture Behavioral of ledmux is
	constant N:		integer := 16;
	signal state: 	unsigned(N-1 downto 0); 
	signal sel:		std_logic_vector(1 downto 0);
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
--LED select
--********************
	with sel select
		ledout <= 	led0 when "00",
						led1 when "01",
						led2 when others;
						
--********************
--en decoder
--********************
	en <= "110" when (sel="00") else
			"101" when (sel="01") else
			"011" when (sel="10") else
			"111";
			
end Behavioral;

