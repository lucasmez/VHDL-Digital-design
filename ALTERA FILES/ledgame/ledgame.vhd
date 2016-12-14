LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
---------------------
ENTITY ledgame IS
	PORT(	clkinput, reverse, s0, s1:	IN STD_LOGIC;
			ledar:							OUT STD_LOGIC_VECTOR(5 DOWNTO 0)	);
END ledgame;


--------------------
ARCHITECTURE behav OF ledgame IS

	COMPONENT control IS
		PORT(	clk, s0, s1:	IN STD_LOGIC;
				sigout:				OUT STD_LOGIC	);
	END COMPONENT;
	
	COMPONENT clkgen IS 
		PORT(	clkIn:	IN STD_LOGIC;
				clkOut:	OUT STD_LOGIC	);
	END COMPONENT;
	
	COMPONENT ledfsm IS
		PORT(	clk, reverse:	IN STD_LOGIC;
				led:				OUT STD_LOGIC_VECTOR(5 DOWNTO 0)	);
	END COMPONENT;
	
	SIGNAL clkinter, fsmclk: STD_LOGIC;

BEGIN
	clkgene: clkgen PORT MAP(clkinput,clkinter);
	c1: 		control PORT MAP(clkinter,s0,s1,fsmclk);
	fsm: 		ledfsm PORT MAP(fsmclk, reverse, ledar);

END behav;