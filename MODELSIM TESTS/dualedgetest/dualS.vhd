library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity dualS is
end dualS;

architecture behav of dualS is
	component dualtest is
		Port ( clk, reset, inp : in  STD_LOGIC;
         		  outp : out  STD_LOGIC);
	end component;

	signal clk, reset, inp, outp: std_logic;

begin
	uut: dualtest port map(clk,reset,inp,outp);

clock:process
begin
	clk <= '0';
	wait for 1 ns;
	clk <= '1';
	wait for 1 ns;
end process;


--test vectors
process
begin
	reset <= '1';
	inp <= '0';
	wait for 2 ns;
	reset <= '0';
	inp <= '1';
	wait for 8 ns;
	inp <= '0';
	wait for 8 ns;
	inp <= '1';
	wait for 2 ns;
	inp <= '0';
	wait for 2 ns;
	inp <= '1';
	wait for 100 ns;
	inp <= '0';
	wait for 50 ns;
	inp <= '1';
	wait for 50 ns;
	wait;
end process;
end behav;  