-- Listing 7.5
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity autoUart is
   port(
      clk, rst: in std_logic;
      bt: in std_logic_vector(2 downto 0); --Advance Config, DISCONNECTED , read/transmit
      rx: in std_logic;
      tx: out std_logic;
      led: out std_logic_vector(7 downto 0);
      ledout: out std_logic_vector(7 downto 0);
      en: out std_logic_vector(2 downto 0)
   );
end autoUart;

architecture arch of autoUart is
	type states is (bdDetect, showRate, uartState);

   signal tx_full, rx_empty: std_logic;
   signal rec_data,rec_data1: std_logic_vector(7 downto 0);
   signal btn_tick: std_logic;
	signal btn: std_logic_vector(2 downto 0);
	signal reset: std_logic;
	signal err: std_logic_vector(2 downto 0);
	
	signal state_cur, state_next: states;
	signal rateCur, parCur, rateNx, parNx: std_logic_vector(1 downto 0);
	signal dataNumCur, stopNumCur, dataNumNx, stopNumNx: std_logic; 
	
	signal hex2, hex1, hex0: std_logic_vector(3 downto 0); --Input for hexMux
	signal hexOut: std_logic_vector(7 downto 0); --hexMux output
	signal enOut, dp: std_logic_vector(2 downto 0); --hexMux output and dp_in input
	signal SSDSelect: std_logic; --Select SSD(ledout) output from hexMux or not
	
	signal rxDetect, rxUart: std_logic; --bdDetector in. Uart In
	signal detectionDone: std_logic;--bdDetector out
	signal bdDetected: std_logic_vector(1 downto 0);--bdDetector out
	signal rateOverflow: std_logic; --bdDetector out
	
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
               wr_uart=>btn_tick, rx=>rxUart, w_data=>rec_data1, bd_rate=>rateCur,
					d_num=>dataNumCur, s_num=>stopNumCur, par=>parCur, err=>err,
               tx_full=>tx_full, rx_empty=>rx_empty,
               r_data=>rec_data, tx=>tx);
					
	--instantiante hexMux
	hex_mux_unit: entity work.hexmux
		port map(clk=>clk, reset=>reset, hex2=>hex2, hex1=>hex1, hex0=>hex0,
					dp_in=>dp, en=>enOut, ledout=>hexOut);
					
	--instantiate Baud-rate Detector
	bdDetectionUnit: entity work.bdRateDetect
				port map(clk=>clk, reset=>reset, rx=>rxDetect, rateDetectDone=>detectionDone, bd_rate=>bdDetected, overflow=>rateOverflow);
				
   -- instantiate debounce circuit
   btn_db_unit: entity work.debounce(fsmd_arch)
      port map(clk=>clk, reset=>reset, sw=>btn(0),
               db_level=>open, db_tick=>btn_tick);
					
					
statesReg: process(clk, reset)
begin
	if(reset='1') then
		state_cur <= bdDetect;
		rateCur <= "00";
		parCur <= "00";
		dataNumCur <= '1';
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
process(State_cur, rateCur, parCur, dataNumCur, stopNumCur, rec_data, detectionDone, bdDetected, rx, btn_tick, rateOverflow)
begin
	state_next <= state_cur;
	rateNx <= rateCur;
	parNx <= "00";--NO parity default
	dataNumNx <= '1'; --8 data bits default
	stopNumNx <= '0'; --1 stop bit default
	hex1<=(others=>'0');
	hex0<=(others=>'0');
	led<=(others=>'0');
	SSDSelect <= '0';
	dp<="100";
	rxDetect <= '1';
	rxUart <= '1';

	case state_cur is
		--=========Detect Baud-rate========--
		-------------------------------------
		when bdDetect =>
			rxDetect <= rx;
			led<="00000001";
			SSDSelect <= '1';
			if(detectionDone='1') then
				rateNx <= bdDetected;
				state_next <= showRate;
			end if;
			
		--========Display Baud-rate (for debugging purposes)=====--
		-----------------------------------------------------------
		when showRate =>
			led <= rateOverflow&"0000010";
			SSDSelect <= '1';
			hex0 <= "000"&rateCur(0);
			hex1 <= "000"&rateCur(1);
			if(btn_tick='1') then
				state_next <= uartState;
			end if;

		--========Start UART operation=======--
		---------------------------------------
		when uartState =>
			led <= rec_data;
			SSDSelect <= '0';
			dp<="000";
			rxUart <= rx;
	end case;
end process;
		
   -- incremented data loop back
   rec_data1 <= std_logic_vector(unsigned(rec_data)+1);
end arch;
