LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
-----------------
ENTITY ledfsm IS
	PORT(	clk, reverse:	IN STD_LOGIC;
			led:				OUT STD_LOGIC_VECTOR(5 DOWNTO 0)	);
END ledfsm;


----------------
ARCHITECTURE behav OF ledfsm IS

	-----Types and functions
	TYPE states IS (none, L0, L1, L2, L3, L4, L5);
	SIGNAL nxState, curState: states;
	
	FUNCTION incr(SIGNAL a: states) RETURN states IS
		VARIABLE result: states;
	BEGIN	
		CASE a IS
			WHEN none 	=> result := L0;
			WHEN L0		=> result := L1;
			WHEN L1		=> result := L2;
			WHEN L2		=> result := L3;
			WHEN L3		=> result := L4;
			WHEN L4		=> result := L5;
			WHEN L5		=> result := none;
			WHEN OTHERS =>	result := none;
		END CASE;
		RETURN result;
	END incr;
	
	FUNCTION decr(SIGNAL a: states) RETURN states IS
		VARIABLE result: states;
	BEGIN	
		CASE a IS
			WHEN none 	=> result := L5;
			WHEN L0		=> result := none;
			WHEN L1		=> result := L0;
			WHEN L2		=> result := L1;
			WHEN L3		=> result := L2;
			WHEN L4		=> result := L3;
			WHEN L5		=> result := L4;
			WHEN OTHERS => result := none;
		END CASE;
		RETURN result;
	END decr;
	--------------
BEGIN

sequential: PROCESS(clk)
BEGIN
	IF(clk'EVENT AND clk='1') THEN
		curState <= nxState;
	END IF;
END PROCESS;

comb: PROCESS(curState)
BEGIN
	--Next state
	IF(reverse ='0') THEN
		nxState <= incr(curState);
	ELSE
		nxState <= decr(curState);
	END IF;
	
	--Output
	CASE curState IS
		WHEN none 	=> led <= (OTHERS => '0');
		WHEN L0		=> led <= "000001";
		WHEN L1		=> led <= "000010";
		WHEN L2		=> led <= "000100";
		WHEN L3		=> led <= "001000";
		WHEN L4		=> led <= "010000";
		WHEN L5		=> led <= "100000";
	END CASE;
END PROCESS;

END behav;
			