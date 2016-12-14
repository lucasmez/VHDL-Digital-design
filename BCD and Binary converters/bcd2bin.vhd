----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:28:05 10/25/2015 
-- Design Name: 
-- Module Name:    bcd2bin - Behavioral 
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

entity bcd2bin is
    Port ( start, reset, clk : in  STD_LOGIC;			--Converison starts when start='1'
           d0, d1 : in  STD_LOGIC_VECTOR (3 downto 0);--d1=MS BCD, d0=LS BCD
           ready, done_tick, error : out  STD_LOGIC;	--ready='1' when ready to convert. done_tick='1' when conv. is done. error='1' when input is not BCD
           outp : out  STD_LOGIC_VECTOR (6 downto 0));--Output value 7 bits
end bcd2bin;

architecture twodigits of bcd2bin is
	type states is (idle, op, done);
	signal curstate, nxstate: states;
	signal outtemp, nxouttemp, dataout: unsigned(6 downto 0); 
	signal nxerror, errortemp: std_logic;

begin
process(clk, reset)
begin
	if(reset='1') then
		curstate <= idle;
		outtemp <= (others=>'0');
		--nxerror <= '0';
	elsif(clk'event and clk='1') then
		curstate <= nxstate;
		outtemp <= nxouttemp;
		error <= nxerror;
	end if;
end process;

process(start, d0, d1, curstate, outtemp)
begin
	nxstate <= curstate;
	nxouttemp <= outtemp;
	ready <= '0';
	done_tick <= '0';
	nxerror <= '0';
	case curstate is
		when idle =>
			ready <= '1';
			if(errortemp='1') then
				nxerror <= '1';
			elsif(start='1') then
				nxstate <= op;
				nxouttemp <= (others => '0');
			end if;
		
		when op =>
			nxouttemp <= dataout;
			nxstate <= done;
		
		when done =>
			done_tick <= '1';
			nxstate <= idle;
			
	end case;
end process;

	--data function, calculate output
	dataout <= ((unsigned(d1)&"000") + ("00"&unsigned(d1)&'0')) + unsigned(d0); --dataout=10*d1 + d0
	--error detection
	errortemp <= '1' when ((unsigned(d0)>9) or (unsigned(d1)>9)) else
					'0';
	--output
	outp <= std_logic_vector(outtemp); 

end twodigits;

