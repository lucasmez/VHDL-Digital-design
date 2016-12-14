LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
---Generate 800 Hz clock from 50 MHz clock input
---Divide clock by 62500
ENTITY gen60 IS
	PORT(	clkIn:	IN STD_LOGIC;
			clkOut:	OUT STD_LOGIC	);
END gen60;

------------------------
ARCHITECTURE behav OF gen60 IS
BEGIN

PROCESS(clkIn)
	VARIABLE count1: INTEGER :=0;
BEGIN
	IF(clkIn'EVENT AND clkIn='1') THEN
		count1 := count1 + 1;
		
		IF(count1 <= 31250) THEN --416667
			clkOut <= '1';
		ELSE
			clkOut <= '0';
		END IF;
		
		IF(count1 > 62500) THEN --833333
			count1 := 0;
		END IF;
		
	END IF;
END PROCESS;

END behav;
		