library ieee;
use ieee.std_logic_1164.all;

entity ffuartT is
end ffuartT;

architecture behav of ffuartT is
	signal clk, rst, rx, tx: std_logic;
	signal bt, en: std_logic_vector(2 downto 0);
	signal configu: std_logic_vector(5 downto 0);
	signal led, ledout: std_logic_vector(7 downto 0);

begin

	dut: entity work.uart10_test
		port map(clk, rst, bt, rx, tx, configu, led, ledout, en);

--Period 83 ns
clock: process
begin
	clk <= '0';
	wait for 42 ns;
	clk <= '1';
	wait for 42 ns;
end process;


--switches are negative logic
signals:process
begin
	rst<='0';
	bt <= "100";
	wait for 200 ns;
	--bd_rate State
	rst <= '1';
	configu <= "111111";
	wait for 200 ns;
	bt(2) <= '0'; --change state
	wait for 100000000 ns; --for debouncing and tick
	bt(2) <= '1';
	--dNum state
	wait for 200 ns;
	bt(2) <= '0'; --change state
	wait for 10000000 ns; --for debouncing and tick
	bt(2) <= '1';
	--sNum state
	wait for 200 ns;
	bt(2) <= '0'; --change state
	wait for 10000000 ns; --for debouncing and tick
	bt(2) <= '1';
	--par stat
	wait for 200 ns;
	bt(2) <= '0'; --change state
	wait for 10000000 ns; --for debouncing and tick
	bt(2) <= '1';
	--exec state
	wait;
end process;
end behav;