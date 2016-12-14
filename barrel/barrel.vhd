----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:02:12 09/23/2015 
-- Design Name: 
-- Module Name:    barrel - Behavioral 
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

entity barrel is
	port(	inpi:	in std_logic_vector(4 downto 0); --!!!make it 7 downto 0 for synthesis. rename to inp. remove all references to inpi. erase ln. 40
			amt:	in std_logic_vector(2 downto 0);	--amount to shift or rotate, 1 to 8
			sel:	in std_logic_vector(5 downto 0);	--0:show inpt, 1:ror, 2:rol, 3:sll, 4:srl, 5:sra !!!srl by 8 showing wierd behavior
			outp:	out std_logic_vector(7 downto 0)
	);
end barrel;

architecture Behavioral of barrel is
	type inter is array (2 downto 0) of std_logic_vector(7 downto 0); --holds value for intermediate steps of barrel shifters
	
	signal rot,shll, shrl: inter;
	signal rotf: std_logic_vector(7 downto 0);
	signal srtemp: std_logic;	--shift right MSB. '0' for srl. inp(7) for sra
	signal inpt: std_logic_vector(7 downto 0);	--holds regular inp or inverse inp for left rotation
	signal inp: std_logic_vector(7 downto 0);
begin
	inp <= "111" & inpi;
	--barrel shift left
	shll(0) <= inp(6 downto 0) & '0' when (amt(0)='1') else
					inp;
	shll(1) <= shll(0)(5 downto 0) & "00" when (amt(1)='1') else
					shll(0);
	shll(2) <= shll(1)(3 downto 0) & "0000" when (amt(2)='1') else
					shll(1);
					
	--barrel shift right logical/arithmetic
	srtemp <= '0' when (sel="110111") else inp(7); --'0' when srl. inp(7) for sra and all others(does not matter)
	shrl(0) <= srtemp & inp(7 downto 1) when (amt(0)='1') else
					inp;
	shrl(1) <= srtemp & srtemp & shrl(0)(7 downto 2) when (amt(1)='1') else
					shrl(0);
	shrl(2) <= srtemp & srtemp & srtemp & srtemp & shrl(1)(7 downto 4) when (amt(2)='1') else
					shrl(1);
					
	--barrel rotate right/left
	inpt(7 downto 0) <= inp(0)&inp(1)&inp(2)&inp(3)&inp(4)&inp(5)&inp(6)&inp(7) when (sel="111101") else 
								inp;
	rot(0) <= inpt(0) & inpt(7 downto 1) when (amt(0)='1') else
					inpt;
	rot(1) <= rot(0)(1) & rot(0)(0) & rot(0)(7 downto 2) when (amt(1)='1') else
					rot(0);
	rot(2) <= rot(1)(3) & rot(1)(2) & rot(1)(1) & rot(1)(0) & rot(1)(7 downto 4) when (amt(2)='1') else
					rot(1);
	rotf(7 downto 0) <= rot(2)(0)&rot(2)(1)&rot(2)(2)&rot(2)(3)&rot(2)(4)&rot(2)(5)&rot(2)(6)&rot(2)(7) when (sel="111101") else
								rot(2);
					
	--Select output
	with sel select
		outp <= 	rotf		when "111101" | "111110",
					shll(2) 	when "111011",
					shrl(2)	when "110111" | "101111",
					inp when others;
						
end Behavioral;

