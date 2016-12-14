----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:50:32 10/14/2015 
-- Design Name: 
-- Module Name:    dualedge - Behavioral 
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


entity dualedge is
    Port ( clk, reset, inp : in  STD_LOGIC;
           outp : out  STD_LOGIC);
end dualedge;

architecture moorefsm of dualedge is
	type states is (rst, rise, holdr, fall, holdf);
	signal curstate, nxstate: states;
begin
	
process(clk)
begin
	if(reset='1') then
		curstate <= rst;
	elsif(clk'event and clk='1') then
		curstate <= nxstate;
	end if;
end process;

--Next state and output logic
process(inp, curstate)
begin
	nxstate <= curstate;
	outp <= '0';
	case curstate is
		when rst =>
			if(inp='1') then nxstate <= rise; end if;
		when rise =>
			if(inp='1') then nxstate <= holdr;
			else nxstate <= fall;
			end if;
			outp <= '1';
		when holdr =>
			if(inp='0') then nxstate <= fall; end if;
		when fall =>
			if(inp='1') then nxstate <= rise;
			else nxstate <= holdf;
			end if;
			outp <= '1';
		when holdf =>
			if(inp='1') then nxstate <= rise; end if;
		when others =>
			nxstate <= curstate;
			outp <= '0';
		end case;
end process;


end moorefsm;

