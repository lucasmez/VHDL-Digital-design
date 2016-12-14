library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity reactionTimer is
	port(			clk:				in std_logic;
					st, cl:			in std_logic;
					sto:				in std_logic;
					randIn:			in std_logic_vector(7 downto 0);	--rand value from MCU
					failIn:			in std_logic_vector(9 downto 0); --fail value from MCU
					update:			in std_logic;	--Update Counter stats based on imput from MCU
					en:				out std_logic_vector(2 downto 0);
					ledout:			out std_logic_vector(7 downto 0);
					stimulusLed:	out std_logic
				);
end reactionTimer;

architecture Behavioral of reactionTimer is
	
	--Signals to fix negative logic switch
	signal start, clear, stop: std_logic;
	
	--FSM states registers
	type states is (clears, updateS, waitRand, counting, early, failed, display);
	signal stateCur, stateNx:	states;
	
	--Data path registers (counters, etc)
	signal randWait: 		unsigned(20 downto 0); --100ms (1,200,000) mod counter
	signal hMsCount:		unsigned(7 downto 0); --100ms counter
	signal timeCount:		unsigned(16 downto 0);	--10ms (120000) mod counter
	signal tenMsCount: 	unsigned(9 downto 0); --10 ms counter
	signal randCur, randNx:	unsigned(7 downto 0);--Setting time in 100ms units (value randWait counts up to). MAX = 256, ~25 seconds.
	signal failCur, failNx:	unsigned(9 downto 0); --Time to fail in 10ms units (value timeCount counts up to). MAX = 1024, ~10seconds.
	
	--Data Path signals
	--constant rand:			integer := 30;--Setting time in 100ms units (value randWait counts up to). MAX = 256, ~25 seconds.
	--constant fail:			integer := 100; --Time to fail in 10ms units (value timeCount counts up to). MAX = 1024, ~10seconds. Default = 1s
	signal startWait: 	std_logic;	--starts counting up to random number
	signal startCount:	std_logic;	--starts counting until stop is pressed
	signal hexSel:			std_logic_vector(1 downto 0); 
	signal hex0In, hex1In, hex2In:	std_logic_vector(3 downto 0); --Input to hexMux after its selected with hexSel
	signal dpIn:			std_logic_vector(2 downto 0) := "011"; --decimal point input to hexMux (default: 1.23)
	
	--Components signals
	signal bcd2, bcd1, bcd0: std_logic_vector(3 downto 0); --Output signal from bin2bcd
	signal tenMsCountIn: std_logic_vector(12 downto 0);	--Input for bin2bcd
	constant one: std_logic := '1';
	constant zero: std_logic := '0';
	signal binbcdstart: std_logic; --Start bin2bcd convertion
	
begin
	
	start <= not(st);
	clear <= not(cl);
	stop <= not(sto);
--******Components instantiations*********
	hex: entity work.hexmux
			port map(clk, zero, hex2In, hex1In, hex0In, dpIn, en, ledout);
		
	bcd: entity work.bin2bcd
			port map(clk, clear, binbcdstart, tenMsCountIn, open, open, open, bcd2, bcd1, bcd0);

	tenMsCountIn <= "000"&std_logic_vector(tenMsCount);
--****************************************

--******FSMD registers (states and counters****
process(clk, clear)
begin
	if(clear='1') then
		stateCur <= clears;
		randWait <= (others => '0');
		timeCount <= (others => '0');
		tenMsCount <= (others => '0');
		hMsCount <= (others => '0');
	elsif(clk'EVENT and clk='1') then
		stateCur <= stateNx;
		randCur <= randNx;
		failCur <= failNx;
		if(startWait='1') then --startWait counter 100ms (1,200,000)
			if(randWait="100100100111110000000") then --reset 100ms mod counter. Increment 100ms counter
				randWait <= (others=>'0');
				hMsCount <= hMsCount + 1;
			else
				randWait <= randWait + 1;
			end if;
		end if;
		if(startCount='1') then --startCount 10ms (120,000) mod counter
			if(timeCount="11101010011000000") then --reset 10ms mod counter. Increment 10ms counter
				timeCount <= (others => '0');
				tenMsCount <= tenMsCount + 1;
			else
				tenMsCount <= tenMsCount;
				timeCount <= timeCount + 1;
			end if;
		end if;
	end if;
end process;
--***********************
		
--**Data Path hexSel logic**
	with hexSel select
		hex2In <= 	"0000" when "00",
						bcd2 when "01",
						"0001" when "10",
						"1001" when others;
						
	with hexSel select
		hex1In <= 	bcd1 when "01",
						"1001" when "11",
						"0000" when others;
						
	with hexSel select
		hex0In <= 	bcd0 when "01",
						"1001" when "11",
						"0000" when others;
--*************************
		
--*****FSMD next state logic, output logic, data path logic***		
process(stateCur, hMsCount, tenMsCount, start, stop, update, randCur, failCur)
begin
	stateNx <= stateCur;
	randNx <= randCur;
	failNx <= failCur;
	startWait <= '0';
	startCount <= '0';
	hexSel <= "00";
	stimulusLed <= '0';
	binbcdstart <= '1';
	
	case stateCur is
		when clears =>
			if(start='1') then
				startWait <= '1';
				stateNx <= waitRand;
			elsif(update='1') then
				stateNx <= updateS;
			end if;
		when updateS =>
			randNx <= randIn;
			failNx <= failIn;
			stateNx <=clears;
		when waitRand =>
			startWait <= '1';
			if(hMsCount >= randCur) then --Check if setting time has elapsed
				startCount <= '1';
				stateNx <= counting;
				stimulusLed <= '1';
				hexSel <= "01";
			elsif(stop='1') then
				hexSel <= "11";
				stateNx <= early;
			end if;
		when early =>
			hexSel <= "11";
		when counting =>
			if(tenMsCount >= failCur) then
				hexSel <= "10";
				stateNx <= failed;
			elsif(stop='1') then
				hexSel <= "01";
				stateNx <= display;
			else
				stimulusLed <= '1';
				startCount <= '1';
				hexSel <= "01";
			end if;
		when failed =>
			hexSel <= "10";
		when display =>
			binbcdstart <= '0';
			hexSel <= "01";
	end case;
end process;
--****************************************************				
		
end Behavioral;

