--tooLow Signal not working. 
	--Instead of output showing 999, it shows 25.0
	--ovfl LED doesn't light up

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity freq_counter is
	port(	clk, rest: in std_logic;
			sta, si:	in std_logic;
			ledout:		out std_logic_vector(7 downto 0);
			en:			out std_logic_vector(2 downto 0);
			ovfl:			out std_logic
	);
end freq_counter;

architecture Behavioral of freq_counter is
	type states is (idle, period, div, bcd);
	signal state_cur, state_next: states;
	
	signal start, reset: std_logic; --sta, rest negative logic
	
	signal start_count, done_count:	std_logic;	--Period Counter sub-module status
	signal period_out:				std_logic_vector(9 downto 0);	--Period	
	signal tooLow:						std_logic; --For decimal placement and dividend determination circuit
	signal start_div, done_div:	std_logic;	--period division sub-module status
	signal dividend:					integer; --dividend to divider based on period_out 18 BITS
	signal div_out:					std_logic_vector(16 downto 0); --division result (frequency)
	signal result_final:				std_logic_vector(12 downto 0); --frequency after being truncated (max. 999 Hz because of SSD constraints)
	signal start_bin, done_bin:	std_logic; --bin2bcd sub-module signal
	signal bcd2, bcd1, bcd0:		std_logic_vector(3 downto 0);	--bin2bcd and hexmux sub-modules output and input
	signal dp:							std_logic_vector(2 downto 0); --hexmux sub-module input
	
	signal dvdntemp:					std_logic_vector(17 downto 0); --Helper signals for div instantiation
	signal dvsrtemp:					std_logic_vector(17 downto 0);
	signal quotemp:					std_logic_vector(17 downto 0);
	signal per_uns:					integer;
	
begin

	start <= not(sta);
	reset <= not(rest);
	dvdntemp <= std_logic_vector(to_unsigned(dividend, 18));
	dvsrtemp <= "00000000"&period_out;
	div_out <= quotemp(16 downto 0);
	per_uns <= to_integer(unsigned(period_out));

	--******Components instantiations**********
	period_c: entity work.period_counter
				port map(clk, reset, start_count, si, open, done_count, tooLow, period_out);
				
	divi: entity work.div
			generic map(18, 5)
			port map(clk, reset, start_div, dvsrtemp, dvdntemp, open, done_div, quotemp, open);

	bin: entity work.bin2bcd
		port map(clk, reset, start_bin, result_final, open, done_bin, open, bcd2, bcd1, bcd0);
		
	ssd: entity work.hexmux
			port map(clk, reset, bcd2, bcd1, bcd0, dp, en, ledout);
	--********************************************


--Data path circuit to determine decimal point placement (also determine dividend)
process(per_uns)
begin
	if (per_uns > 999) then --frequency < 1 Hz
		dp <= "000";
		--tooLow <= '1';
		dividend <= 0;
	elsif (per_uns > 100) then --Frequency 1-10Hz, ex: 6.41 Hz
		dp <= "011";
		--tooLow <= '0';
		dividend <= 100000;
	elsif (per_uns > 10) then --Frequency 10-100 Hz, ex: 17.8 Hz
		dp <= "101";
		--tooLow <= '0';
		dividend <= 10000;
	else --Frequency>100 Hz, Ex: 945 Hz
		dp <= "111";
		--tooLow <= '0';
		dividend <= 1000;
	end if;
end process;

--FSM registers
process(clk, reset)
begin
	if(reset='1') then
		state_cur <= idle;
	elsif(clk'EVENT and clk='1') then
		state_cur <= state_next;
	end if;
end process;

--FSM next-state and data path logic
process(state_cur, start, done_count, tooLow, done_div, done_bin)
begin
	state_next <= state_cur;
	start_count <= '0';
	result_final <= "000"&div_out(9 downto 0);
	start_div <= '0';
	start_bin <= '0';
	case state_cur is
		when idle =>
			if(start='1') then
				start_count <= '1';
				state_next <= period;
			end if;
		when period =>
			if(done_count='1') then
				if(tooLow='1') then
					result_final <= std_logic_vector(to_unsigned(999, 13));
					start_bin <= '1';
					state_next <= bcd;
				else
					start_div <= '1';
					state_next <= div;
				end if;
			end if;
		when div =>
			if(done_div='1') then
				start_bin <= '1';
				state_next <= bcd;
			end if;
		when bcd =>
			if(done_bin='1') then
				state_next <= idle;
			end if;
	end case;
end process;

ovfl <= tooLow;

end Behavioral;

