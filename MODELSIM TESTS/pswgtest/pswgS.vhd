----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:13:59 10/02/2015 
-- Design Name: 
-- Module Name:    pswg - Behavioral 
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

entity pswgS is
	port(	clk:		in std_logic;	--12 MHz clock
			m1,n1:	in std_logic_vector(3 downto 0); --select duty cycle
			square:	out std_logic	--square wave output
	);
end pswgS;

architecture Behavioral of pswgS is
	signal cycle, cyclenx: 	unsigned(8 downto 0); --counter mod m+n
	signal m,n:					std_logic_vector(3 downto 0);
	signal mn:					unsigned(4 downto 0); --m+n, 1 bit extra to hold carry if necessary
	signal m_2, m_8, m_10:	unsigned(7 downto 0); --2*m, 8*m and 10*m
begin

process(clk)
begin
	if(clk'event and clk='1') then
		cycle <= cyclenx;
	end if;
end process;

	m <= "0001" when m1="0000" else
			m1;
	n <= "0001"  when n1="0000" else
			n1;

	mn <= ('0'&unsigned(m)) + ('0'&unsigned(n));

	cyclenx <= (others => '0') when (cycle = mn) else
					cycle + 1;

	--**************
	--m*10 implemented using 2 shifts and 1 adding operation
	--**************
	m_2 <= "000" & unsigned(m) & '0'; --2*m
	m_8 <= '0' & unsigned(m) & "000"; --8*m
	m_10 <= m_2 + m_8;  ---10*m
	
	--**************
	--compute output square wave
	--**************
	square <= 	'1' when (cycle < ('0' & m_10)) else
					'0';
					
end Behavioral;


