----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:54:13 10/05/2015 
-- Design Name: 
-- Module Name:    rotbanner - Behavioral 
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

entity rotbanner is
    Port ( clk : in  STD_LOGIC;
           ena : in  STD_LOGIC;
           dir : in  STD_LOGIC;
           ledout : out  STD_LOGIC_VECTOR (7 downto 0);
           en : out  STD_LOGIC_VECTOR (2 downto 0));
end rotbanner;

architecture Behavioral of rotbanner is
	component ledmux is
		port(	clk:					in std_logic;
				led0,led1,led2:	in std_logic_vector(7 downto 0);
				ledout:				out std_logic_vector(7 downto 0);
				en:					out std_logic_vector(2 downto 0)
		);
	end component;
	
	signal led0, led1, led2: 	std_logic_vector(7 downto 0);
	signal ledsel:					std_logic_vector(23 downto 0); 
	signal sel:						unsigned(3 downto 0); --if Implementation 1, sel=3 downto 0
	signal count:					std_logic;
	signal counter:				unsigned(23 downto 0);
	
--	type constrom is array(7 downto 0) of std_logic_vector(23 downto 0);
--	constant signals: constrom := (
--		"100000011100111110010010", --012
--		"110011111001001010000110", --123
--		"100100101000011011001100", --234
--		"100001101100110010100100", --345
--		"110011001010010011100000", --456
--		"101001001110000010001111", --567
--		"111000001000111110000000", --678
--		"100011111000000010001100" --789
--	);
		
	-----------Implementation 2----------------
	type constrom is array(9 downto 0) of std_logic_vector(7 downto 0);
	constant signals: constrom := (
		"10000001", --0
		"11001111", --1
		"10010010", --2
		"10000110", --3
		"11001100", --4
		"10100100", --5
		"11100000", --6
		"10001111", --7
		"10000000", --8
		"10001100" --9
	);
	-------------------------------------------
	
begin

	muxled: ledmux port map(clk,led0,led1,led2,ledout,en);
	
process(clk)
begin
		if(clk'event and clk='1') then
			if(to_integer(counter) = 12000000) then
				counter <= (others => '0');
			else
				counter <= counter + 1;
			end if;
		end if;
end process;

	count <= '1' when to_integer(counter)=12000000 else
				'0';
	
process(clk)
begin
	if(clk'event and clk='1') then
		if(ena='1' and count='1') then
			if(to_integer(sel)=9) then --Only with implementation 2
				sel <= (others => '0');
			elsif(dir='1') then
				sel <= sel + 1;
			else
				sel <= sel - 1;
			end if;
		else
			sel <= sel;
		end if;
	end if;
end process;

	--ledsel <= signals(to_integer(sel)); --Only with implementation 1
	led0 <= ledsel(23 downto 16);
	led1 <= ledsel(15 downto 8);
	led2 <= ledsel(7 downto 0);

	with sel select	--only with implementation 2
		ledsel <= 	signals(0)&signals(1)&signals(2) when "0000",
						signals(1)&signals(2)&signals(3) when "0001",
						signals(2)&signals(3)&signals(4) when "0010",
						signals(3)&signals(4)&signals(5) when "0011",
						signals(4)&signals(5)&signals(6) when "0100",
						signals(5)&signals(6)&signals(7) when "0101",
						signals(6)&signals(7)&signals(8) when "0110",
						signals(7)&signals(8)&signals(9) when others;
						
end Behavioral;

