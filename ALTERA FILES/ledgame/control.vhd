LIBRARY ieee;
LIBRARY ieee;	
	USE ieee.std_logic_1164.all;
	
--Control part of the LED Game	
-----------------------
ENTITY control IS
	PORT(	clk, s0, s1:	IN STD_LOGIC; 
			sigout:				OUT STD_LOGIC	);
END control;


-----------------------
ARCHITECTURE behavorial OF control IS

	SIGNAL compV: NATURAL; --Second inpunt to upper comparator
	CONSTANT buttonT: NATURAL := 180; --buttonT/60 = time button has to be pressed --CHANGE TO 180
	CONSTANT slowest: NATURAL := 60;
	CONSTANT med:		NATURAL := 30;
	CONSTANT fastest:	NATURAL := 8;
	
BEGIN
	
bottomCounter: PROCESS(clk, s0,s1)
	VARIABLE count1: NATURAL RANGE 0 TO 190 :=0;
	--VARIABLE count2: NATURAL RANGE 0 TO 62 := 0;
	VARIABLE compValue: NATURAL := slowest;
BEGIN
	IF(clk'EVENT AND clk='1') THEN
		--Bottom counter
		IF(s0='1' OR s1='1') THEN --If both s0 and s1 are not zero
			count1 := count1 + 1;
			IF(count1 = buttonT) THEN
				IF(s0='1' AND s1='0') THEN --time=60
					compValue := slowest;
				ELSIF(s0='0' AND s1='1') THEN --time=30
					compValue := med;
				ELSIF(s0='1' AND s1='1') THEN
					compValue := fastest;
				ELSE
					compValue := compValue;
				END IF;
			ELSIF(count1 > buttonT) THEN --reset counter
				count1 := 0;
			END IF;
		ELSE
			count1 := 0;
			compValue := compValue;
		END IF;
		
		
		--Top counter
--		count2 := count2 + 1;
--		IF (count2 <= (compValue/2)) THEN
--			sigout <= '1';
--		ELSIF(count2 > (compValue/2)) THEN
--			sigout <= '0';
--		ELSIF(count2 >= compValue) THEN
--			count2 := 0;
--			sigout <= 'X';
--		ELSE
--			sigout <= 'X';
--		END IF;
		---------
		
		
	END IF;
	compV <= compValue;
END PROCESS;


topCounter: PROCESS(clk)
	VARIABLE count2 : NATURAL RANGE 0 TO 62 := 0;
	VARIABLE outTemp: STD_LOGIC := '0';
BEGIN
	--count2 := 0;
	IF(clk'EVENT AND clk='1') THEN
		count2 := count2 + 1;
		IF (count2 <= (compV/2)) THEN
			outTemp := '1';
		ELSIF(count2 > (compV/2)) THEN
			outTemp := '0';
		END IF;
		IF(count2 > compV) THEN
			count2 := 0;
		ELSE
			outTemp := 'X';
		END IF;
	END IF;
	sigout <= outTemp;
END PROCESS;


END behavorial;
		
			