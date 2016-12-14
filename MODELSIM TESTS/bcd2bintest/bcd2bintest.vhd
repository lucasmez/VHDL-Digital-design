LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity bcd2bintest is
end bcd2bintest;

architecture behav of bcd2bintest is

	signal start,rst, clk, ready, done, error: std_logic;
	signal d0,d1: std_logic_vector(3 downto 0);
	signal outp: std_logic_vector(6 downto 0);

begin
	
	uut: entity work.bcd2binS port map(start, rst, clk, d0, d1, ready, done, error, outp);

process
begin
	clk <= '0';
	wait for 1 ns;
	clk <= '1';
	wait for 1 ns;
end process;


process
begin
	rst <= '1';
	wait for 2 ns;
	rst <= '0'; 
	wait for 1 ns;
	d1 <= "0010";
	d0 <= "1000";
	start <= '1';
	wait for 3 ns;
	start <= '0';
	wait for 5 ns;
	wait;
end process;

end behav;