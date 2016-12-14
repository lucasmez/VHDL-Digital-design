LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
	USE work.utils.all;
	
--Decodes buzzer, output decoded frequency for buzzer circuit
ENTITY buzzer IS
	PORT( clk:	IN STD_LOGIC;
			code:	IN STD_LOGIC_VECTOR(1 DOWNTO 0); --00: no sound		01: 2Hz sound		10: Alarm
			sound:OUT STD_LOGIC							);
END buzzer;


------------------------
ARCHITECTURE behavorial OF buzzer IS

	CONSTANT lowFeq: 	INTEGER := 50000;--2; --Frequency of attention sound
	CONSTANT alFeq:	INTEGER := 100000;--1000; --Frequency of alarm sound
	
BEGIN

PROCESS (clk, code)
	VARIABLE count: INTEGER := 0;
	VARIABLE max : INTEGER;
BEGIN
	IF(code = "00" OR code = "11") THEN
		sound <= '0';
	ELSIF(clk'EVENT AND clk='1') THEN
		IF(code = "01") THEN max := clkFq/lowFeq;
		ELSE max := clkFq/alFeq;
		END IF;
		
		count := count + 1;
		IF(count > max) THEN 
			count := 1;
		END IF;
		IF(count <= (max/2)) THEN
			sound <= '1';
		ELSIF(count <= max) THEN
			sound <= '0';
		END IF;
	END IF;
END PROCESS;

END behavorial;