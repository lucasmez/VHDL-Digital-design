
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity uartBaudGen is
	port(
			clk, reset: in std_logic;
			bd_rate: in std_logic_vector(1 downto 0); --baud-rate. "00"=1200, "01"=2400, "10"=4800, "11"=9600
			tick: out std_logic
		);
end uartBaudGen;

architecture Behavioral of uartBaudGen is
	signal dvsr: integer;
	signal counter: unsigned(9 downto 0);
	
begin
	--Assume Clk=12MHz
	with bd_rate select
		dvsr <= 	625 when "00",
					313 when "01",
					157 when "10",
					79 when others;
					
process(clk, reset)	--dvsr-mod counter				
begin
	if(reset='1') then
		counter <= (others => '0');
	elsif(clk'EVENT and clk='1') then
		if(counter = to_unsigned(dvsr, 10)) then
			counter <= (others => '0');
			tick <= '1';
		else
			counter <= counter + 1;
			tick <= '0';
		end if;
	end if;
end process;

end Behavioral;

