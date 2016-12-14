LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
---Generate 60 Hz clock from 50 MHz clock input
---Divide clock by 833,333
ENTITY gen60Hz IS
	PORT(	clkIn:	IN STD_LOGIC;
			clkOut:	OUT STD_LOGIC	);
END gen60Hz;

------------------------
ARCHITECTURE behav OF gen60Hz IS
BEGIN

PROCESS(clkIn)
	VARIABLE count1, count2: INTEGER := 0;
BEGIN
	IF(clkIn'EVENT AND clkIn='1') THEN
		count1 := count1 + 1;
		
		IF(count1 <= 416667) THEN
			clkOut <= '1';
		ELSE
			clkOut <= '0';
		END IF;
		
		IF(count1 > 833333) THEN
			count1 := 0;
		END IF;
		
	END IF;
END PROCESS;

END behav;
		
			