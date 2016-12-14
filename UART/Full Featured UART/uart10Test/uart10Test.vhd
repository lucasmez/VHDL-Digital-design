-- Listing 7.5
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uart10Test is
   port(
      clk, rst: in std_logic;
      bt: in std_logic_vector(2 downto 0); --Advance Config, DISCONNECTED , read/transmit
      rx: in std_logic;
      tx: out std_logic;
		configu: in std_logic_vector(5 downto 0); --bd_rate(2), d_num(1), s_num(1), par(2)
      led: out std_logic_vector(7 downto 0);
      ledout: out std_logic_vector(7 downto 0);
      en: out std_logic_vector(2 downto 0)
   );
end uart10Test;

architecture arch of uart10Test is
	type states is (bdRate, dNum, sNum, par, exec);

   signal tx_full, rx_empty: std_logic;
   signal rec_data,rec_data1: std_logic_vector(7 downto 0);
   signal btn_tick: std_logic;
	signal btn: std_logic_vector(2 downto 0);
	signal reset: std_logic;
	signal err: std_logic_vector(2 downto 0);
	
	signal state_cur, state_next: states;
	signal rateCur, parCur, rateNx, parNx: std_logic_vector(1 downto 0);
	signal dataNumCur, stopNumCur, dataNumNx, stopNumNx: std_logic; 
	
	signal bt2Edge: std_logic; --edge detected bt(2)
	signal hex2, hex1, hex0: std_logic_vector(3 downto 0); --Input for hexMux
	signal hexOut: std_logic_vector(7 downto 0); --hexMux output
	signal enOut, dp: std_logic_vector(2 downto 0); --hexMux output and dp_in input
	signal SSDSelect: std_logic; --Select SSD(ledout) output from hexMux or not
	
begin
	btn(2) <= not bt(2);
	btn(1) <= not bt(1);
	btn(0) <= not bt(0);
	reset <= not rst;
	hex2 <= (others=>'0');
	--Output for SSD(ledout and en)
	ledout <= '1' & (not tx_full) & (not rx_empty) & "11" & not(err(2)) & not(err(1)) & not(err(0)) when SSDSelect='0' else
					hexOut;
					
	en <= "110" when SSDSelect='0' else
			enOut;
   -- instantiate uart
   uart_unit: entity work.uart10
      port map(clk=>clk, reset=>reset, rd_uart=>btn_tick,
               wr_uart=>btn_tick, rx=>rx, w_data=>rec_data1, bd_rate=>rateCur,
					d_num=>dataNumCur, s_num=>stopNumCur, par=>parCur, err=>err,
               tx_full=>tx_full, rx_empty=>rx_empty,
               r_data=>rec_data, tx=>tx);
					
	--instantiante hexMux
	hex_mux_unit: entity work.hexmux
		port map(clk=>clk, reset=>reset, hex2=>hex2, hex1=>hex1, hex0=>hex0,
					dp_in=>dp, en=>enOut, ledout=>hexOut);
					
   -- instantiate debounce circuit
   btn_db_unit: entity work.debounce(fsmd_arch)
      port map(clk=>clk, reset=>reset, sw=>btn(0),
               db_level=>open, db_tick=>btn_tick);
					
	bt2_db_unit: entity work.debounce(fsmd_arch)
		port map(clk=>clk, reset=>reset, sw=>btn(1),
					db_level=>open, db_tick=>bt2Edge);
					
statesReg: process(clk, reset)
begin
	if(reset='1') then
		state_cur <= bdRate;
		rateCur <= "00";
		parCur <= "00";
		dataNumCur <= '0';
		stopNumCur <= '0';
	elsif(clk'EVENT and clk='1') then
		state_cur <= state_next;
		rateCur <= rateNx;
		parCur <= parNx;
		dataNumCur <= dataNumNx;
		stopNumCur <= stopNumNx;
	end if;
end process;

--Next State Logic
process(State_cur, rateCur, parCur, dataNumCur, stopNumCur, configu, bt2Edge, rec_data)
begin
	state_next <= state_cur;
	rateNx <= rateCur;
	parNx <= parCur;
	dataNumNx <= dataNumCur;
	stopNumNx <= stopNumCur;
	hex1<=(others=>'0');
	hex0<=(others=>'0');
	led<=(others=>'0');
	SSDSelect <= '0';
	dp<="100";

	case state_cur is
		when bdRate =>
			led<="00000001";
			rateNx <= configu(5 downto 4);
			SSDSelect <= '1';
			hex1 <= "000"&configu(5);
			hex0 <= "000"&configu(4);
			if(bt2Edge = '1') then
				state_next <= dNum;
			end if;
		when dNum =>
			led<="00000010";
			dataNumNx <= configu(3);
			SSDSelect <= '1';
			hex1 <= (others=>'0');
			hex0 <= "000"&configu(3);
			if(bt2Edge = '1') then
				state_next <= sNum;
			end if;
		when sNum =>
			led<="00000100";
			stopNumNx <= configu(2);
			SSDSelect <= '1';
			hex1 <= (others=>'0');
			hex0 <= "000"&configu(2);
			if(bt2Edge = '1') then
				state_next <= par;
			end if;
		when par =>
			led<="00001000";
			parNx <= configu(1 downto 0);
			SSDSelect <= '1';
			hex1 <= "000"&configu(1);
			hex0 <= "000"&configu(0);
			if(bt2Edge = '1') then
				state_next <= exec;
			end if;
		when exec =>
			led <= rec_data;
			SSDSelect <= '0';
			dp<="000";
	end case;
end process;
		
   -- incremented data loop back
   rec_data1 <= std_logic_vector(unsigned(rec_data)+1);
end arch;
