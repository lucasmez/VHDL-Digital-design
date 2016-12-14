LIBRARY ieee;
	USE ieee.std_logic_1164.all;



ENTITY controlTest IS
END controlTest;




ARCHITECTURE behav OF controlTest IS

	COMPONENT ledgame IS
		PORT(	clkinput, s0, s1:	IN STD_LOGIC;
			outpsig:				OUT STD_LOGIC	);
	END COMPONENT;

	SIGNAL clkinput, s0, s1, outpsig: STD_LOGIC;

BEGIN

	UUT: ledgame PORT MAP(clkinput, s0, s1, outpsig);

clock: PROCESS
BEGIN
	clkinput <='1';
	wait for 1 ns; --For a clock of 500Hz
	clkinput <= '0';
	wait for 1 ns;
END PROCESS;

signals: PROCESS
BEGIN
	wait for 1 ns;
	s0 <= '1';
	s1 <= '1';
	
	wait for 40000000 ns;
	s0 <= '0';
	s0 <= '0';
	wait for 20000000 ns;

	s0 <= '1';
	s1 <= '0';	
	
	wait for 40000000 ns;
	s0 <= '0';
	s0 <= '0';
	wait for 40000000 ns;

	wait;
END PROCESS;
END behav;