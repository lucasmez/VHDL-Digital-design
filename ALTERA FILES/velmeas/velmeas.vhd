LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
------------------------------------------------
ENTITY velmeas IS
	GENERIC(	N: INTEGER := 8); --N = number of bits for 1 SSD display
	PORT(	clk, feqIn:	IN STD_LOGIC;	--system clock, speed input clock, speed select button
			ssdu, ssdt			:	OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)			); --SSD showing input speed (ssd Units, ssd Tens)
			
END velmeas;


---------------------------------------------------
ARCHITECTURE behavorial OF velmeas IS
	
	CONSTANT HzPerSp: INTEGER := 100;--100; --Hertz per Km/h from speedometer
	CONSTANT clkFq:	INTEGER := 800;--50000000; --Frequency of system clock
	CONSTANT maxCount:INTEGER := clkFq/HzPerSp; --Max counter value
	SIGNAL countSave:	INTEGER RANGE 0 TO maxCount; --countIn is saved here for use in the outputs process
	
	COMPONENT gen60 IS
		PORT(	clkIn:	IN STD_LOGIC;
				clkOut:	OUT STD_LOGIC	);
	END COMPONENT;
	
	SIGNAL clk60: STD_LOGIC;
	
BEGIN

	clkGen: gen60 PORT MAP(clk, clk60);

--Compute CountIn, and save it in countSave
PROCESS(clk60,feqIn)
	VARIABLE countTemp: INTEGER RANGE 0 TO maxCount := 0;
	VARIABLE tempC: INTEGER RANGE 0 TO maxCount := 0;
BEGIN
	IF(clk'EVENT AND clk='1') THEN
		IF(feqIn = '1') THEN
			tempC := tempC + 1;
		ELSE
			tempC := 0;
		END IF;
		
		IF (tempC = 1) THEN
			countSave <= countTemp;
		ELSIF(tempC = 2) THEN
			countTemp := 0;
		ELSE
			countTemp := countTemp + 1;
		END IF;
	END IF;
END PROCESS;
	

-------------

--Compute outputs. Should be computed only after a feqIn period is completed
	--SSD output
PROCESS(countSave)
	VARIABLE velol: INTEGER RANGE 0 TO 99;
	VARIABLE unit,ten: INTEGER RANGE 0 TO 99;
	VARIABLE resultu,  resultt:	STD_LOGIC_VECTOR(N-1 DOWNTO 0);
BEGIN
	velol := clkFq / countSave;
	unit := velol mod 10;
	ten := velol / 10;
	CASE unit IS 							 --abcdefg
			WHEN 0 => resultu := (OTHERS => '0');
			WHEN 1 => resultu := "01100000";
			WHEN 2 => resultu := "11011010";
			WHEN 3 => resultu := "11110010";
			WHEN 4 => resultu := "01100110";
			WHEN 5 => resultu := "10110110";
			WHEN 6 => resultu := "00111110";
			WHEN 7 => resultu := "11100000";
			WHEN 8 => resultu := "11111111";
			WHEN 9 => resultu := "11100110";
			WHEN OTHERS => resultu := (OTHERS => '0'); --Make an 'X' symbol or something else
	END CASE;
	
	CASE ten IS 							 --abcdefg
			WHEN 0 => resultt := (OTHERS => '0');
			WHEN 1 => resultt := "01100000";
			WHEN 2 => resultt := "11011010";
			WHEN 3 => resultt := "11110010";
			WHEN 4 => resultt := "01100110";
			WHEN 5 => resultt := "10110110";
			WHEN 6 => resultt := "00111110";
			WHEN 7 => resultt := "11100000";
			WHEN 8 => resultt := "11111111";
			WHEN 9 => resultt := "11100110";
			WHEN OTHERS => resultt := (OTHERS => '0'); --Make an 'X' symbol or something else
	END CASE;
	
	ssdu <= resultu;
	ssdt <= resultt;
END PROCESS;
	
END behavorial;

