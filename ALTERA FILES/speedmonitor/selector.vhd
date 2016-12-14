LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
	USE work.utils.all;
	
	
-----------------
--Decodes button and outputs velocity selected (in systemClks counts)
ENTITY selector IS
	PORT(	clk, button	:	IN STD_LOGIC;
			selected		:	OUT INTEGER		);
END selector;


------------------
ARCHITECTURE behavorial OF selector IS

	CONSTANT counts1Sec: INTEGER := clkFq;--Number of clock periods for 1 second
	TYPE states IS (ti5State, fo5State, fi5State, siState, si5State, seState);
	SIGNAL curState, nxState: states;

BEGIN

PROCESS(clk, button)
	VARIABLE count: INTEGER := 0;
BEGIN
	IF(clk'EVENT AND clk='1') THEN
		IF(button ='1') THEN
			count := count + 1;
		ELSE
			count := 0;
		END IF;
		
		IF(count = 1 OR count = counts1Sec) THEN
			curState <= nxState;
		END IF;
		
		IF(count > (counts1Sec + 5)) THEN
			count := 2;
		END IF;
		
		
	END IF;
END PROCESS;

PROCESS(curState)
BEGIN
	CASE curState IS
		WHEN ti5State => 
			nxState <= fo5State;
			selected <= ti5;
		WHEN fo5State =>
			nxState <= fi5State;
			selected <= fo5;
		WHEN fi5State =>
			nxState <= siState;
			selected <= fi5;
		WHEN siState =>
			nxState <=si5State;
			selected <= six;
		WHEN si5State =>
			nxState <= seState;
			selected <= si5;
		WHEN seState =>
			nxState <= ti5State;
			selected <= se;
	END CASE;
END PROCESS;

end behavorial;
			