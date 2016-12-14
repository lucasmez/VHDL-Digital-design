LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
-------------------------------------------------------
PACKAGE utils IS
	-------CONSTANTS
	--clkFq/HzPerSp should be greater than 1000
	CONSTANT HzPerSp: INTEGER := 100000;--100; --Hertz per Km/h from speedometer
	CONSTANT clkFq:	INTEGER := 1000000000;--50000000; --Frequency of system clock
	--Do not change. For use in selector
	CONSTANT ti5:		INTEGER := clkFq/(35*HzPerSp); --Number of system clock counts for speed of 35km/h
	CONSTANT fo5:		INTEGER := clkFq/(45*HzPerSp); -- ...45km/h
	CONSTANT fi5:		INTEGER := clkFq/(55*HzPerSp); -- ...55km/h
	CONSTANT six:		INTEGER := clkFq/(60*HzPerSp); -- ...60km/h
	CONSTANT si5:		INTEGER := clkFq/(65*HzPerSp); -- ...65km/h
	CONSTANT se:		INTEGER := clkFq/(70*HzPerSp); -- ...70km/h	
	
	-------FUNCTIONS
	FUNCTION ssdOut(v: INTEGER) RETURN STD_LOGIC_VECTOR; --Convert from 2 digit integer to SSD 
	FUNCTION ledLogic(SIGNAL countSel: INTEGER) RETURN STD_LOGIC_VECTOR; --Take in selected speed and change led outputs
	
	
	-------COMPONENTS
	COMPONENT selector IS --Component for button decoder
		PORT(	clk, button	:	IN STD_LOGIC;
				selected		:	OUT INTEGER		);
	END COMPONENT;
	
	
	COMPONENT buzzer IS --Component for Buzzer
		PORT( clk:	IN STD_LOGIC;
				code:	IN STD_LOGIC_VECTOR(1 DOWNTO 0); --00: no sound		01: 2Hz sound		10: Alarm
				sound:OUT STD_LOGIC							);
	END COMPONENT;
	
END utils;



---------------------------------------------------------
PACKAGE BODY utils IS
	
	FUNCTION ssdOut(v: INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE result: STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
		CASE v IS 
			WHEN 0 => result := (OTHERS => '0');
			WHEN 1 => result := "10000000";
			WHEN 2 => result := "01000000";
			WHEN 3 => result := "00100000";
			WHEN 4 => result := "00010000";
			WHEN 5 => result := "00001000";
			WHEN 6 => result := "00000100";
			WHEN 7 => result := "00000010";
			WHEN 8 => result := "00000001";
			WHEN 9 => result := "10000001";
			WHEN OTHERS => result := (OTHERS => '0'); --Make an 'X' symbol or something else
		END CASE;
		RETURN result;
	END ssdOut;
	
	
	FUNCTION ledLogic(SIGNAL countSel: INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE result: STD_LOGIC_VECTOR(5 DOWNTO 0);
	BEGIN
		CASE countSel IS
			WHEN ti5 => result := "100000";
			WHEN fo5 => result := "010000";
			WHEN fi5 => result := "001000";
			WHEN six => result := "000100";
			WHEN si5 => result := "000010";
			WHEN se =>  result := "000001";
			WHEN OTHERS => result := (OTHERS => '0');
		END CASE;
		
		RETURN result;
	END ledLogic;
		
	
END utils;
