LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
-------------------------------------------------------
PACKAGE tools IS
	-------CONSTANTS
	--clkFq/HzPerSp should be greater than 1000
	CONSTANT HzPerSp: INTEGER := 1;--100; --Hertz per Km/h from speedometer
	CONSTANT clkFq:	INTEGER := 50000000;--50000000; --Frequency of system clock
	
	-------FUNCTIONS
	FUNCTION ssdOut(v: INTEGER) RETURN STD_LOGIC_VECTOR; --Convert from 2 digit integer to SSD 

END tools;


---------------------------------------------------------
PACKAGE BODY tools IS
	
	FUNCTION ssdOut(v: INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE result: STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
		CASE v IS 
									 --abcdefg
			WHEN 0 => result := (OTHERS => '0');
			WHEN 1 => result := "01100000";
			WHEN 2 => result := "11011010";
			WHEN 3 => result := "11110010";
			WHEN 4 => result := "01100110";
			WHEN 5 => result := "10110110";
			WHEN 6 => result := "00111110";
			WHEN 7 => result := "11100000";
			WHEN 8 => result := "11111111";
			WHEN 9 => result := "11100110";
			WHEN OTHERS => result := (OTHERS => '0'); --Make an 'X' symbol or something else
		END CASE;
		RETURN result;
	END ssdOut;
	
END tools;