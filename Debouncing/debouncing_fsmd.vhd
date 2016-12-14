----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:04:10 10/23/2015 
-- Design Name: 
-- Module Name:    debouncing_fsmd - Behavioral 
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

entity debouncing_fsmd is
    Port ( clk, reset : 		in  STD_LOGIC;
           button, fall_edg : in  STD_LOGIC;
           db_level, db_tick : out  STD_LOGIC);
end debouncing_fsmd;

architecture Behavioral of debouncing_fsmd is
	type states is (zero, wait_0, one, wait_1);
	constant count_init: 		unsigned(17 downto 0) := to_unsigned(240000, 18);	--20 ms to count down to 0 with clk= 12 MHz
	signal curstate, nxstate:	states;	--states register
	signal counter, nxcounter: unsigned(17 downto 0); --counter register
begin

--===========================
process(clk,reset)
begin
	if(reset='1') then
		curstate <= zero;
		counter <= (others=>'0');
	elsif(clk'event and clk='1') then
		curstate <= nxstate;
		counter <= nxcounter;
	end if;
end process;

--==========================
process(curstate, counter, button, fall_edg)
begin
	nxstate <= curstate;
	nxcounter <= counter;
	db_level <= '0';
	db_tick <= '0';
	
	case curstate is
		when zero =>
			if(button='1') then
				nxstate <= wait_0;
				db_tick <= '1';
				nxcounter <= count_init;
			end if;
		
		when wait_0 =>
			db_level <= '1';
			nxcounter <= counter - 1;
			if(counter=0) then
				nxstate <= one;
			end if;
			
		when one =>
			db_level <= '1';
			if(button='0') then
				if(fall_edg='1') then --falling edge tick enable?
					db_tick <= '1';
				end if;
				nxcounter <= count_init;
				nxstate <= wait_1;
			end if;

		when wait_1 =>
			nxcounter <= counter -1;
			if(counter=0) then
				nxstate <= zero;
			end if;
	end case;
end process;
		
end Behavioral;

