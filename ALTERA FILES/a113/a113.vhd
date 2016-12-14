LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	
----------------------
ENTITY a113 IS
	GENERIC(	n: INTEGER RANGE 1 TO 31 := 4);
	PORT(	a:		IN STD_LOGIC_VECTOR(n DOWNTO 0);
			shif:	IN NATURAL RANGE 0 TO n;
			b:		OUT STD_LOGIC_VECTOR(n DOWNTO 0)	);
END a113;


---------------------
ARCHITECTURE behavorial OF a113 IS 

	-------Function shift
	FUNCTION "sla" (inp: STD_LOGIC_VECTOR; by: NATURAL) RETURN STD_LOGIC_VECTOR IS
		CONSTANT size: 	INTEGER := inp'LENGTH;
		VARIABLE input: 	STD_LOGIC_VECTOR(size - 1 DOWNTO 0) := inp;
		VARIABLE temp: 	STD_LOGIC_VECTOR(size-1 DOWNTO 0) := (OTHERS => inp(inp'RIGHT));
		VARIABLE result:	STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		
	BEGIN
		--ASSERT a'LENGTH > b
		--REPORT "Error cannot shift this much";
		IF(by >= size-1) THEN result := temp;
		ELSE
			result:= input(size-1-by DOWNTO 1) & temp(by DOWNTO 0);		
		END IF;
		RETURN temp;
	END "sla";
	-------
	
BEGIN
	b <= a sla shif;
END behavorial;