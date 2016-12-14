--Instructions of use for Automatic Baud-rate Detection Circuit:
--First send an ASCII character from some UART transmitter to the detector's receiver.
--The Detector assumes the transmitted bits is of the form (from start to stop bit): "0_dddd_ddd0_1"
--Use the following settings: 8 data bits, 1 stop bit, NO parity bit.
--Wait rateDetectDone tick before using UART or changing its configuration.
--If baud rate is changed, use this circuit again.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity bdRateDetect is
	port(	clk, reset: in std_logic;
			rx: in std_logic;
			rateDetectDone: out std_logic;
			bd_rate: out std_logic_vector(1 downto 0);
			overflow: out std_logic
		);
end bdRateDetect;

architecture Behavioral of bdRateDetect is

	constant RATE_MAX: integer := 12000000; --1 second using 12 MHz clock
	type stateT is (stop, start, one, done);
	signal state_cur, state_nx: stateT;
	signal rateCount_nx, rateCount_cur: unsigned(16 downto 0); --max 15000
	signal stopCount_nx, stopCount_cur: unsigned(23 downto 0); --max 1 seconds
	signal rateSaved_nx, rateSaved_cur: unsigned(16 downto 0); --max 15000
	signal ovflow_nx, ovflow_cur: std_logic;
	signal rT: integer; --rate Ticks

begin

process(clk, reset)
begin
	if(reset='1') then --Asynchronous reset
		state_cur <= stop;
		rateCount_cur <= (others => '0');
		rateSaved_cur <= (others => '0');
		stopCount_cur <= (others=>'0');
		ovflow_cur <= '0';
	elsif(clk'EVENT and clk='1') then
		state_cur <= state_nx;
		rateCount_cur <= rateCount_nx;
		rateSaved_cur <= rateSaved_nx;
		stopCount_cur <= stopCount_nx;
		ovflow_cur <= ovflow_nx;
	end if;
end process;

process(rx, state_cur)
begin
	state_nx <= state_cur;
	rateCount_nx <= rateCount_cur;
	rateSaved_nx <= rateSaved_cur;
	stopCount_nx <= stopCount_cur;
	rateDetectDone <= '0';
	ovflow_nx <= ovflow_cur;
	case state_cur is
	
		--Wait for start bit--
		when stop =>
			if(rx='0') then
				rateCount_nx <= (others=>'0');
				rateSaved_nx <= (others=>'0');
				state_nx <= start;
			end if;
			
		when start =>
			rateCount_nx <= rateCount_cur + 1;
			if(rateCount_cur >= to_unsigned(130000,14)) then
				ovflow_nx <= '1';
			end if;
			if(rx='1') then
				rateSaved_nx <= rateCount_cur;
				stopCount_nx <= (others=>'0');
				state_nx <= one;
			end if;
		
		when one =>
			rateCount_nx <= rateCount_cur + 1;
			stopCount_nx <= stopCount_cur + 1;

			if(stopCount_cur = to_unsigned(RATE_MAX, 24)) then
				state_nx <= done;
			elsif(rx = '0') then
				state_nx <= start;
			end if;
		
		when done =>
			rateDetectDone <= '1'; --done Tick
			rT <= to_integer(rateSaved_cur);
	end case;
end process;

process(rT)
begin
	--Determine Baud Rate Output
	if(rT > 5625) then -- rate <= 19,200
		if(rT > 11250) then --rate <= 9,600
			if(rT > 22500) then --rate <= 4,800
				if(rT > 45000) then --rate <= 2,400
					if(rT > 90000) then --rate <= 1,200
						bd_rate <= "00"; --1200
					else
						bd_rate <= "01"; --2400
					end if;
				else
					bd_rate <= "10"; --4800
				end if;
			else
				bd_rate <= "11"; --9600
			end if;
		else
			bd_rate <= "11"; --9600. 19200 when implemented!
		end if;
	else
		bd_rate <= "11"; --9600. 19200 whem implemented!
	end if;
end process;

overflow <= ovflow_cur;

end Behavioral;

