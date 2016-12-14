LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
-----------------
ENTITY testclock IS
--empty
END testclock;


----------------
ARCHITECTURE behav OF testclock IS

	COMPONENT gen60Hz IS
		PORT(	clkIn:	IN STD_LOGIC;
				clkOut:	OUT STD_LOGIC	);
	END COMPONENT;
	
	SIGNAL clkIn, clkOut: STD_LOGIC;
	CONSTANT N: INTEGER := 8333330; --enough for 10 60hz periods
	
BEGIN

	gen1: gen60Hz PORT MAP(clkIn, clkOut);
	
PROCESS
BEGIN
	clkIn <= '0';
	wait for 10 ns;
	FOR i IN 0 TO N LOOP
		clkIn <= not(clkIn);
		wait for 10 ns;
	END LOOP;

	wait;
END PROCESS;

END behav;