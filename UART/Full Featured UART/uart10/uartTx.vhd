-- Listing 7.3
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uartTx is
   port(
      clk, reset: in std_logic;
      tx_start: in std_logic;
      s_tick: in std_logic;
      din: in std_logic_vector(7 downto 0);
		d_num, s_num: in std_logic; --# of data bits and stop bits
		par: in std_logic_vector(1 downto 0); --"00" or "11" NO parity. "01" EVEN parity. "10" ODD parity
      tx_done_tick: out std_logic;
      tx: out std_logic
   );
end uartTx ;

architecture arch of uartTx is
   type state_type is (idle, start, data, parity, stop);
   signal state_reg, state_next: state_type;
   signal s_reg, s_next: unsigned(3 downto 0);
   signal n_reg, n_next: unsigned(2 downto 0);
   signal b_reg, b_next: std_logic_vector(7 downto 0);
   signal tx_reg, tx_next: std_logic;
	signal DBIT, SB_TICK: integer; --# of data bits to transmit
	signal isOdd: std_logic; --'1' if din is odd
	
begin
	--Select number of data bits and stop bits ticks based on d_num and s_num inputs.
	DBIT <= 7 when d_num='0' else 8;
	SB_TICK <= 16 when s_num='0' else 32;
	
	--Compute isOdd
	process (din) is
	variable tmp : std_logic;
begin
	tmp := '1';
	for I in 7 downto 0 loop
       tmp := tmp and din(I);
	end loop;
	isOdd <= tmp;
end process;

   -- FSMD state & data registers
   process(clk,reset)
   begin
      if reset='1' then
         state_reg <= idle;
         s_reg <= (others=>'0');
         n_reg <= (others=>'0');
         b_reg <= (others=>'0');
         tx_reg <= '1';
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
         s_reg <= s_next;
         n_reg <= n_next;
         b_reg <= b_next;
         tx_reg <= tx_next;
      end if;
   end process;
   -- next-state logic & data path functional units/routing
   process(state_reg,s_reg,n_reg,b_reg,s_tick,
           tx_reg,tx_start,din, par, isOdd)
   begin
      state_next <= state_reg;
      s_next <= s_reg;
      n_next <= n_reg;
      b_next <= b_reg;
      tx_next <= tx_reg ;
      tx_done_tick <= '0';
      case state_reg is
         when idle =>
            tx_next <= '1';
            if tx_start='1' then
               state_next <= start;
               s_next <= (others=>'0');
               b_next <= din;
            end if;
         when start =>
            tx_next <= '0';
            if (s_tick = '1') then
               if s_reg=15 then
                  state_next <= data;
                  s_next <= (others=>'0');
                  n_next <= (others=>'0');
               else
                  s_next <= s_reg + 1;
               end if;
            end if;
         when data =>
            tx_next <= b_reg(0);
            if (s_tick = '1') then
               if s_reg=15 then
                  s_next <= (others=>'0');
                  b_next <= '0' & b_reg(7 downto 1) ;
                  if n_reg=(DBIT-1) then
							if((par="00") or (par="11")) then --NO parity
								state_next <= stop ;
							else
								state_next <= parity;
							end if;
                  else
                     n_next <= n_reg + 1;
                  end if;
               else
                  s_next <= s_reg + 1;
               end if;
            end if;
			when parity =>
				state_next <= stop;
				if(par="01") then --Even parity
					if(isOdd='1') then --If data is odd, parity bit='1'
						tx_next <= '1';
					else tx_next <= '0';
					end if;
				else --Odd parity
					if(isOdd='1') then --If data is odd, parity bit='0'
						tx_next <= '0';
					else tx_next <= '1';
					end if;
				end if;
         when stop =>
            tx_next <= '1';
            if (s_tick = '1') then
               if s_reg=(SB_TICK-1) then
                  state_next <= idle;
                  tx_done_tick <= '1';
               else
                  s_next <= s_reg + 1;
               end if;
            end if;
      end case;
   end process;
   tx <= tx_reg;
end arch;
