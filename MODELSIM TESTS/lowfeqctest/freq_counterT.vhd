library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity freq_counterT is
--
end freq_counterT;

architecture behavorial of freq_counterT is

	signal clk, reset: std_logic;

begin

	uut: entity work.freq_counterS
		port map(clk, reset, start, si, ledout, en, ovfl);

process
begin
	clk <= 
begin
	
