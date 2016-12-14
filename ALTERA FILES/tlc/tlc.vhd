-------------------------------------------------
LIBRARY ieee;
	USE ieee.std_logic_1164.all;
-------------------------------------------------
ENTITY tlc IS
	PORT ( 	clk60, stby, test: IN STD_LOGIC;
				r1, r2, y1, y2, g1, g2: OUT STD_LOGIC);
	END tlc;
-------------------------------------------------
ARCHITECTURE behavior OF tlc IS
	----------clock component
	COMPONENT gen60Hz IS
		PORT(	clkIn:	IN STD_LOGIC;
				clkOut:	OUT STD_LOGIC	);
	END COMPONENT;
	-----------
	SIGNAL clk: STD_LOGIC;
				
	CONSTANT timeMAX : INTEGER := 270;
	CONSTANT timeRG : INTEGER := 180;
	CONSTANT timeRY : INTEGER := 30;
	CONSTANT timeGR : INTEGER := 270;
	CONSTANT timeYR : INTEGER := 30;
	CONSTANT timeTEST : INTEGER := 60;
	TYPE state IS (RG, RY, GR, YR, YY);
	SIGNAL pr_state, nx_state: state;
	SIGNAL time : INTEGER RANGE 0 TO timeMAX;
	
	
BEGIN

	cl1: gen60Hz PORT MAP(clk60, clk);
	
-------- Lower section of state machine: ----
	PROCESS (clk, stby)
	VARIABLE count : INTEGER RANGE 0 TO timeMAX;
BEGIN
	IF (stby='1') THEN
		pr_state <= YY;
		count := 0;
	ELSIF (clk'EVENT AND clk='1') THEN
		count := count + 1;
		IF (count = time) THEN
			pr_state <= nx_state;
			count := 0;
		END IF;
	END IF;
END PROCESS;

-------- Upper section of state machine: ----
PROCESS (pr_state, test)
BEGIN
	CASE pr_state IS
		WHEN RG =>
			r1<='1'; r2<='0'; y1<='0'; y2<='0'; g1<='0'; g2<='1';
			nx_state <= RY;
			IF (test='0') THEN time <= timeRG;
			ELSE time <= timeTEST;
			END IF;
		WHEN RY =>
			r1<='1'; r2<='0'; y1<='0'; y2<='1'; g1<='0'; g2<='0';
			nx_state <= GR;
			IF (test='0') THEN time <= timeRY;
			ELSE time <= timeTEST;
			END IF;
		WHEN GR =>
			r1<='0'; r2<='1'; y1<='0'; y2<='0'; g1<='1'; g2<='0';
			nx_state <= YR;
			IF (test='0') THEN time <= timeGR;
			ELSE time <= timeTEST;
			END IF;
		WHEN YR =>
			r1<='0'; r2<='1'; y1<='1'; y2<='0'; g1<='0'; g2<='0';
			nx_state <= RG;
			IF (test='0') THEN time <= timeYR;
			ELSE time <= timeTEST;
			END IF;
		WHEN YY =>
			r1<='0'; r2<='0'; y1<='1'; y2<='1'; g1<='0'; g2<='0';
			nx_state <= RY;
		END CASE;
END PROCESS;
END behavior;
----------------------------------------------------