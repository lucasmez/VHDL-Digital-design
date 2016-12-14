library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mcuinput is
    Port ( clk, reset : in  STD_LOGIC;
           bt : in  STD_LOGIC;
			  outp: out std_logic_vector(1 downto 0);	--snot="00", sand="01", sxor="10", sor="11"
			  ledout: out std_logic_vector(1 downto 0) );
end mcuinput;

architecture Behavioral of mcuinput is

	type states is (snot, sand, sxor, sor);
	signal curState, nxState: states;
	signal dbButton: std_logic;

begin

	debouncer: entity work.debouncing_fsmd
					port map(clk, reset, not(bt), '0', open, dbButton);

				
process(clk, reset)
begin
	if(reset='0') then
		curState <= snot;
	elsif(clk'EVENT and clk='1') then
		curState <= nxState;
	end if;
end process;

process(curState, dbButton)
begin
	nxState <= curState;
	outp <= "00";
	ledout <= "00";
	case curState is 
		when snot => 
			if(dbButton='1') then
				nxState <= sand;
			end if;
		when sand =>
			outp <= "01";
			ledout <= "01";
			if (dbButton='1') then
				nxState <= sxor;
			end if;
		when sxor =>
			outp <= "10";
			ledout <= "10";
			if (dbButton='1') then
				nxState <= sor;
			end if;
		when others =>
			outp <= "11";
			ledout <= "11";
			if (dbButton='1') then
				nxState <= snot;
			end if;
	end case;
end process;
		
		
end Behavioral;

