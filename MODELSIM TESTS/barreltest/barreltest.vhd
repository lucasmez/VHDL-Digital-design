library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity barreltest is
--empty
end barreltest;

architecture behavorial of barreltest is

	signal inp,outp: 	std_logic_vector(7 downto 0);
	signal amt: 		std_logic_vector(2 downto 0);
	signal sel:		std_logic_vector(5 downto 0);
begin
	uut: entity work.barrel
		port map(inp,amt,sel,outp);

process
begin
	--value 1
	inp <= "00101101";
	amt <= "000";		--by 1
	sel <= "000000";	--inp
	wait for 1 ns;

	sel <= "000001";	--ror
	wait for 1 ns;

	--see all operations
	for i in 0 to 3 loop
		sel <= std_logic_vector(unsigned(sel) sll 1);
		wait for 1 ns;
	end loop;

	--value 4
	amt <= "100";		--by 1
	sel <= "000000";	--inp
	wait for 1 ns;

	sel <= "000001";	--ror
	wait for 1 ns;

	--see all operations
	for i in 0 to 3 loop
		sel <= std_logic_vector(unsigned(sel) sll 1);
		wait for 1 ns;
	end loop;

	wait;
end process;
end behavorial;