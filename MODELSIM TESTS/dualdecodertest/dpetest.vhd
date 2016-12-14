library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity dpetest is
--empty
end dpetest;

architecture behavorial of dpetest is
	signal req: std_logic_vector(11 downto 0);
	signal first, second: std_logic_vector(3 downto 0);
begin
	uut: entity work.dpeS generic map (3) port map(req,first, second);

process
begin
	req <= (others => '0');
	wait for 1 ns;

	for i in 0 to 100 loop
		req <= std_logic_vector(unsigned(req) + 1);
		wait for 1 ns;
	end loop;
end process;

end behavorial;