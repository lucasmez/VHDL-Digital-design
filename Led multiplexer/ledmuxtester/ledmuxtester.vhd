----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:25:10 09/28/2015 
-- Design Name: 
-- Module Name:    ledmuxtester - Behavioral 
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


entity ledmuxtester is
	port(	clk:		in std_logic;
			led:		in std_logic_vector(7 downto 0);
			but:		in std_logic_vector(2 downto 0);
			ledout:	out std_logic_vector(7 downto 0);
			en:		out std_logic_vector(2 downto 0)
	);
end ledmuxtester;

architecture Behavioral of ledmuxtester is
	signal led0, led1, led2: std_logic_vector(7 downto 0);
begin
	--********************
	--instantiate
	--********************
	muxled: entity work.ledmux port map(clk,led0,led1,led2,ledout,en);
	
process(clk)
begin
	if(clk'EVENT and clk='1') then
		if(but(0)='0') then
			led0 <= led;
		end if;
		if(but(1)='0') then
			led1 <= led;
		end if;
		if(but(2)='0') then
			led2 <= led;
		end if;
	end if;
end process;
			
end Behavioral;

