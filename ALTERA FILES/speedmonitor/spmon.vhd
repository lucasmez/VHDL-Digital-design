LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
	USE work.utils.all;
	--CHECK LINE 55
------------------------------------------------
ENTITY spmon IS
	GENERIC(	N: INTEGER := 8); --N = number of bits for 1 SSD display
	PORT(	clk, feqIn, button:	IN STD_LOGIC;	--system clock, speed input clock, speed select button
			buz					:	OUT STD_LOGIC;	--sound frequency output for buzzer circuit
			ssdu, ssdt			:	OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0); --SSD showing input speed (ssd Units, ssd Tens)
			led					:	OUT STD_LOGIC_VECTOR(5 DOWNTO 0)			); --LEDs showing selected speed
END spmon;


---------------------------------------------------
ARCHITECTURE behavorial OF spmon IS

	SIGNAL countSel:		INTEGER; --(Component)velocity (in clock feq counts) currently selected
	SIGNAL buzzerCode:	STD_LOGIC_VECTOR(1 DOWNTO 0); --(Component)00: no sound	01:2Hz sound	10:Alarm
	
	CONSTANT maxCount:INTEGER := clkFq/HzPerSp; --Max counter value
	CONSTANT buzatt:	INTEGER := clkFq/(3*HzPerSp); --3 is the speed below speed selected on which low freq. alarm will sound
	SIGNAL countIn: 	INTEGER RANGE 0 TO maxCount; --Input velocity in systemClk counts
	SIGNAL countSave:	INTEGER RANGE 0 TO maxCount; --countIn is saved here for use in the outputs process
	SIGNAL velol: 		INTEGER RANGE 0 TO 99 := 0; --input speed computed from CountIn, goes to SSD function
	SIGNAL reset: 		STD_LOGIC; --To assist systemClk and feqClk processes
	
BEGIN

	butLogic: selector PORT MAP(clk, button, countSel);
	sound: buzzer PORT MAP(clk, buzzerCode, buz);

--Compute CountIn, and save it in countSave
PROCESS(clk,feqIn)
	VARIABLE countTemp: INTEGER RANGE 0 TO maxCount := 0;
	VARIABLE tempC: INTEGER := 0;
BEGIN
	IF(clk'EVENT AND clk='1') THEN
		IF(feqIn = '1') THEN
			tempC := tempC + 1;
		ELSE
			tempC := 0;
		END IF;
		
		END IF;
		IF(tempC = 2) THEN
			countTemp := 0;
		ELSE
			countTemp := countTemp + 1;
	END IF;
	
	countSave <= countTemp;
END PROCESS;
--systemClk: PROCESS(clk,reset)
--BEGIN
--	IF(reset='1') THEN
--		countIn <= 0;
--	ELSIF(clk'EVENT AND clk='1') THEN
--		countIn <= countIn + 1;
--	END IF;
--END PROCESS;
--	
--feqClk: PROCESS(feqIn)
--BEGIN
--	IF(feqIn'EVENT AND feqIn='1') THEN
--		countSave <= countIn;
--		reset <= '1';
--	END IF;
--END PROCESS;

-------------

--Compute outputs. Should be computed only after a feqIn period is completed
	--SSD output
	velol <= clkFq / (countSave*HzPerSp); --MULTIPLY BY 100 FOR SYNTHESIS
	ssdu <= ssdOut(velol mod 10);
	ssdt <= ssdOut(velol / 10);
	
outputs: PROCESS(feqIn, countSave, countSel)
BEGIN
		--Sound output
		IF((countSel - countSave) <= buzatt ) THEN
			IF(countSave >= countSel) THEN
				buzzerCode <= "10"; --alarm
			ELSE
				buzzerCode <= "01"; --low freq. sound
			END IF;
		ELSE
			buzzerCode <= "00"; --silence
		END IF;	
		
		--LED output
		led <= ledLogic(countSel);
		
END PROCESS;

END behavorial;





	