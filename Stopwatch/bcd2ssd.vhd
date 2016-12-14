--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package bcd2ssd is

  function tossd (signal bcd : in std_logic_vector; constant dip: std_logic) return std_logic_vector;

end bcd2ssd;


package body bcd2ssd is

  function tossd (signal bcd : in std_logic_vector; constant dip: in std_logic) return std_logic_vector is
	variable ledout: std_logic_vector(7 downto 0);
  begin
   case bcd(3 downto 0) is
		when "0000" => ledout(6 downto 0) := "0000001"; --0
		when "0001" => ledout(6 downto 0) := "1001111"; --1
		when "0010" => ledout(6 downto 0) := "0010010"; --2
		when "0011" => ledout(6 downto 0) := "0000110"; --3
		when "0100" => ledout(6 downto 0) := "1001100"; --4
		when "0101" => ledout(6 downto 0) := "0100100"; --5
		when "0110" => ledout(6 downto 0) := "1100000"; --6
		when "0111" => ledout(6 downto 0) := "0001111"; --7
		when "1000" => ledout(6 downto 0) := "0000000"; --8
		when "1001" => ledout(6 downto 0) := "0001100"; --9
		when others => ledout(6 downto 0) := "1111111";
	end case;
	
	ledout(7) := dip;
	return ledout;
  end tossd;

end bcd2ssd;
