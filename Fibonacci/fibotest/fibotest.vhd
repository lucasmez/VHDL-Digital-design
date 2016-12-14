----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:43:35 10/25/2015 
-- Design Name: 
-- Module Name:    fibotest - Behavioral 
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

entity fibotest is
	port(	clk, st, rst:	in std_logic;
			d1i,d0i:					in std_logic_vector(3 downto 0);
			en:						out std_logic_vector(2 downto 0);
			ledout:					out std_logic_vector(7 downto 0);
			error:					out std_logic
	);
end fibotest;

architecture Behavioral of fibotest is

	type states is (idle, bcd, fib, bin);
	signal curstate, nxstate: states;
	signal nxbcd_st, nxfib_st, nxbin_st:	std_logic;
	signal bcd_st, fib_st, bin_st:			std_logic;
	signal bcd_done, fib_done, bin_done:	std_logic;
	signal bcd_out:								std_logic_vector(6 downto 0);
	signal fib_out:								std_logic_vector(19 downto 0);
	signal bcd_trunc:								std_logic_vector(4 downto 0);
	signal fib_trunc:								std_logic_vector(12 downto 0);
	signal d2, d1, d0:							std_logic_vector(3 downto 0);
	signal errortemp:								std_logic;
	
	signal start:									std_logic;
	signal edge, start_db, start_edge:		std_logic;
	signal reset:									std_logic;
begin

	start <= not(st);
	reset <= not(rst);

--==========================
--Modules instantiations
--==========================
	bcd1: entity work.bcd2bin port map(bcd_st, reset, clk, d0i, d1i, open, bcd_done, errortemp, bcd_out);
	fib1: entity work.fibo port map(clk, reset, fib_st, bcd_trunc, open, fib_done, open, fib_out);
	bin1: entity work.bin2bcd port map(clk, reset, bin_st, fib_trunc, open, bin_done, open, d2, d1, d0);
	mux1: entity work.hexmux port map(clk, reset, d2, d1, d0, "000", en, ledout);
	deb1: entity work.debouncing(pre) port map(clk, reset, start, start_db);
	
	bcd_trunc <= bcd_out(4 downto 0);
	fib_trunc <= fib_out(12 downto 0);
	
--==========================
--Main FSMD	
--==========================
	
--next state
process(clk, reset)
begin
	if(reset='1') then
		curstate <= idle;
		bcd_st <= '0';
		fib_st <= '0';
		bin_st <= '0';
		edge <= '0';
	elsif(clk'event and clk='1') then
		curstate <= nxstate;
		bcd_st <= nxbcd_st;
		fib_st <= nxfib_st;
		bin_st <= nxbin_st;
		edge <= start_db;
	end if;
end process;

--edge detection for start
	start_edge <= (not edge) and start_db;
	
--next state and data logic
process(start_edge, d1, d0, curstate, bcd_st, fib_st, bin_st)
begin
	nxstate <= curstate;
	nxbcd_st <= '0';
	nxfib_st <= '0';
	nxbin_st <= '0';
	case curstate is
		when idle =>
			if(start_edge='1') then
				nxstate <= bcd;
				nxbcd_st <= '1';
			end if;
		
		when bcd =>
			if(errortemp='1') then
				nxstate <= idle;
			elsif(bcd_done='1') then
				nxstate <= fib;
				nxfib_st <= '1';
			end if;
		
		when fib =>
			if(fib_done='1') then
				nxstate <= bin;
				nxbin_st <= '1';
			end if;
		
		when bin =>
			if(bin_done='1') then
				nxstate <= idle;
			end if;
	end case;
end process;
	
	error <= errortemp;
	
end Behavioral;

