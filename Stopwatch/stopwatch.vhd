----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:54:11 09/30/2015 
-- Design Name: 
-- Module Name:    stopwatch - Behavioral 
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
use work.bcd2ssd.all;

entity stopwatch is
	port(	clk, clear, go:	in std_logic;
			ledout:				out std_logic_vector(7 downto 0);
			en:					out std_logic_vector(2 downto 0)
		);
end stopwatch;

architecture Behavioral of stopwatch is
	constant N:									integer := 1200000;
	signal led0,led1,led2: 					std_logic_vector(7 downto 0);
	signal tick, ticknx:						unsigned(20 downto 0);
	signal tickdec,tickunit,ticktens:	unsigned(3 downto 0);
	signal tickdecnx,tickunitnx,ticktensnx:	unsigned(3 downto 0);
begin
	--*****************
	--Instantiate
	--*****************
	muxled: entity work.ledmux port map(clk,led0,led1,led2,ledout,en);

process(clk)
begin
	if(clk'event and clk='1') then
		tick <= ticknx;
		tickdec <= tickdecnx;
		tickunit <= tickunitnx;
		ticktens <= ticktensnx;
	end if;
end process;

	--*****************
	--Compute next states
	--*****************
	ticknx <= 	(others => '0') when (clear='0' or (go='1' and to_integer(tick)=N)) else
					tick + 1 when go='1' else
					tick;
					
	tickdecnx <= 	(others => '0') when (clear='0' or (go='1' and tickdec="1010")) else
						tickdec + 1 when to_integer(tick)=N else
						tickdec;
					
	tickunitnx <= 	(others => '0') when (clear='0' or (go='1' and tickunit="1010")) else
						tickunit + 1 when tickdec="1010" else
						tickunit;
					
	ticktensnx <= 	(others => '0') when (clear='0' or (go='1' and ticktens="1010")) else
						ticktens + 1 when tickunit="1010" else
						ticktens;
						
	--*****************
	--Output SSD's
	--*****************
--	led0 <= tossd(std_logic_vector(tickdec),'1'); --dip off
--	led1 <= tossd(std_logic_vector(tickunit),'0'); --dip on
--	led2 <= tossd(std_logic_vector(ticktens),'1'); --dip off
process(tickdec,tickunit,ticktens)
begin
	case tickdec is
			when "0000" => led0(6 downto 0) <= "0000001"; --0
			when "0001" => led0(6 downto 0) <= "1001111"; --1
			when "0010" => led0(6 downto 0) <= "0010010"; --2
			when "0011" => led0(6 downto 0) <= "0000110"; --3
			when "0100" => led0(6 downto 0) <= "1001100"; --4
			when "0101" => led0(6 downto 0) <= "0100100"; --5
			when "0110" => led0(6 downto 0) <= "1100000"; --6
			when "0111" => led0(6 downto 0) <= "0001111"; --7
			when "1000" => led0(6 downto 0) <= "0000000"; --8
			when "1001" => led0(6 downto 0) <= "0001100"; --9
			when others => led0(6 downto 0) <= "1111111";
		end case;
	led0(7) <= '1';
	
	case tickunit is
			when "0000" => led1(6 downto 0) <= "0000001"; --0
			when "0001" => led1(6 downto 0) <= "1001111"; --1
			when "0010" => led1(6 downto 0) <= "0010010"; --2
			when "0011" => led1(6 downto 0) <= "0000110"; --3
			when "0100" => led1(6 downto 0) <= "1001100"; --4
			when "0101" => led1(6 downto 0) <= "0100100"; --5
			when "0110" => led1(6 downto 0) <= "1100000"; --6
			when "0111" => led1(6 downto 0) <= "0001111"; --7
			when "1000" => led1(6 downto 0) <= "0000000"; --8
			when "1001" => led1(6 downto 0) <= "0001100"; --9
			when others => led1(6 downto 0) <= "1111111";
		end case;
	led1(7) <= '0';
	
	case ticktens is
			when "0000" => led2(6 downto 0) <= "0000001"; --0
			when "0001" => led2(6 downto 0) <= "1001111"; --1
			when "0010" => led2(6 downto 0) <= "0010010"; --2
			when "0011" => led2(6 downto 0) <= "0000110"; --3
			when "0100" => led2(6 downto 0) <= "1001100"; --4
			when "0101" => led2(6 downto 0) <= "0100100"; --5
			when "0110" => led2(6 downto 0) <= "1100000"; --6
			when "0111" => led2(6 downto 0) <= "0001111"; --7
			when "1000" => led2(6 downto 0) <= "0000000"; --8
			when "1001" => led2(6 downto 0) <= "0001100"; --9
			when others => led2(6 downto 0) <= "1111111";
		end case;
	led2(7) <= '1';
end process;


end Behavioral;

