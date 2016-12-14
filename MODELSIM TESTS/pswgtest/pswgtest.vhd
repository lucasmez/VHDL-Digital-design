
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

entity pswgtest is
end entity;


architecture behav of pswgtest is
	signal clk:	 std_logic;	--12 MHz clock
	signal	m1,n1:	 std_logic_vector(3 downto 0); --select duty cycle
	signal	square:	 std_logic;	--square wave output
begin

	uut: entity work.pswgS port map(clk, m1, n1, square);

clock: process
begin
	--period = 4 ns
	clk <= '1';
	wait for 416 ns;
	clk <= '0';
	wait for 416 ns;
end process;

vectors: process
begin
	m1 <= "0000";
	n1 <= "0000";
	wait for 100000 ns;

	m1 <= "0010";
	n1 <= "0001";
	wait for 10000 ns;

	assert false
		report "Simulation completed"
	severity failure;
end process;

end behav;	