----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:39:58 10/03/2015 
-- Design Name: 
-- Module Name:    rotsquare - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rotsquare is
	port(	clk, cw, ena:	in std_logic;
			speed:			in std_logic_vector(1 downto 0);
			ledout:			out std_logic_vector(7 downto 0);
			en:				out std_logic_vector(2 downto 0)
	);
end rotsquare;

architecture Behavioral of rotsquare is
	constant clock:						natural := 12000000;
	constant clock_34:					natural := 9000000;
	constant clock_2:						natural := 6000000;
	constant clock_14:					natural := 3000000;
	constant siz:							integer := 24;
	
	signal curcounter, nxcounter: 	unsigned(siz-1 downto 0);
	signal val:								unsigned(siz-1 downto 0);
	signal eqval:							std_logic;
	
	type states is (a,b,c,d,e,f);
	signal curstate, nxstate:			states;
	
begin
--*******************************
--Speed select and mod counter
--*******************************
process(clk)
begin
	if(clk'event and clk='1') then
		curcounter <= nxcounter;
	end if;
end process;

	with speed select
		val <= 	to_unsigned(clock, siz) when "00",
					to_unsigned(clock_34, siz) when "01",
					to_unsigned(clock_2, siz) when "10",
					to_unsigned(clock_14, siz) when others;
					
	eqval <= '1' when (curcounter=val) else
				'0';
					
	nxcounter <= 	(others => '0') when (eqval='1') else
						curcounter + 1;

--*******************************
--FSM for en output
--*******************************
process(clk)
begin
	if(clk'event and clk='1') then
		if(ena='1' and (eqval='1')) then
			curstate <= nxstate;
		end if;
	end if;
end process;

--nxstate
process(cw, curstate)
begin
	case curstate is
		when a => if(cw='1') then nxstate <= b; else nxstate <= f; end if;
		when b => if(cw='1') then nxstate <= c; else nxstate <= a; end if;
		when c => if(cw='1') then nxstate <= d; else nxstate <= b; end if;
		when d => if(cw='1') then nxstate <= e; else nxstate <= c; end if;
		when e => if(cw='1') then nxstate <= f; else nxstate <= d; end if;
		when others => if(cw='1') then nxstate <= a; else nxstate <= e; end if;
	end case;
end process;

--output
	with curstate select
		en <=	"101" when b,
				"110" when c,
				"110" when d,
				"101" when e,
				"011" when others;

--*******************************
--SSD logic
--*******************************
process(cw, nxstate, curstate)
begin
	if(cw='1') then
		if(	(curstate=a and nxstate=b) or
				(curstate=b and nxstate=c) or
				(curstate=c and nxstate=d)) then
			ledout <= "10011100";
		else
			ledout <= "11100010";
		end if;
	else
		if(	(curstate=a and nxstate=f) or
				(curstate=b and nxstate=a) or
				(curstate=c and nxstate=b)) then
			ledout <= "10011100";
		else
			ledout <= "11100010";
		end if;
	end if;
end process;

end Behavioral;

