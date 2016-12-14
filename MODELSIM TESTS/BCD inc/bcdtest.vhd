library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity bcdtest is
--empty
end bcdtest;


architecture behavorial of bcdtest is
	signal inc: std_logic;
	signal dig1,dig2,dig3: std_logic_vector(3 downto 0);

begin

	uut: entity work.bcdS port map(inc, dig1,dig2,dig3);

process
begin
	inc <= '0';
	wait for 1 ns;
	for i in 0 to 300 loop
		inc <= not(inc);
		wait for 1 ns;
	end loop;

	wait;
end process;
end behavorial;