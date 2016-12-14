-- Listing 7.1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uartRx is
   port(
      clk, reset: in std_logic;
      rx: in std_logic;
      s_tick: in std_logic;
		d_num, s_num: in std_logic; --# of data bits and stop bits
		par: in std_logic_vector(1 downto 0); --"00" or "11" NO parity. "01" EVEN parity. "10" ODD parity
		isFull: in std_logic; --Signal from FIFO showing full status
		err: out std_logic_vector(2 downto 0); --MSB -> LSB. Parity, Frame, Buffer-Overrun errors
      rx_done_tick: out std_logic;
      dout: out std_logic_vector(7 downto 0)
   );
end uartRx ;

architecture arch of uartRx is
   type state_type is (idle, start, data, parity, stop);
   signal state_reg, state_next: state_type;
   signal s_reg, s_next: unsigned(3 downto 0);
   signal n_reg, n_next: unsigned(2 downto 0);
   signal b_reg, b_next: std_logic_vector(7 downto 0);
	signal DBIT, SB_TICK: integer; --Data bits
	signal errorsTemp_reg, errorsTemp_next: std_logic_vector(2 downto 0);
	signal xorInput: std_logic_vector(8 downto 0); --rx&b_reg 
	signal xorOut: std_logic; --Xor of rx&b_reg 
begin
	--Select number of data bits and stop bits ticks based on d_num and s_num inputs
	DBIT <= 7 when d_num='0' else 8;
	SB_TICK <= 0 when s_num='0' else 1;
	
	--Compute xorInput
	xorInput <= rx&b_reg;
process (xorInput) is
	variable tmp : std_logic;
begin
	tmp := '1';
	for I in 8 downto 0 loop
       tmp := tmp and xorInput(I);
	end loop;
	xorOut <= tmp;
end process;
	
   -- FSMD state & data registers
   process(clk,reset)
   begin
      if reset='1' then
         state_reg <= idle;
         s_reg <= (others=>'0');
         n_reg <= (others=>'0');
         b_reg <= (others=>'0');
			errorsTemp_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
         s_reg <= s_next;
         n_reg <= n_next;
         b_reg <= b_next;
			errorsTemp_reg <= errorsTemp_next;
      end if;
   end process;
   -- next-state logic & data path functional units/routing
   process(state_reg,s_reg,n_reg,b_reg,s_tick,rx, errorsTemp_reg, par, xorOut, isFull, DBIT, SB_TICK)
   begin
      state_next <= state_reg;
      s_next <= s_reg;
      n_next <= n_reg;
      b_next <= b_reg;
      rx_done_tick <='0';
		errorsTemp_next <= errorsTemp_reg;
      case state_reg is
         when idle =>
            if rx='0' then
               state_next <= start;
               s_next <= (others=>'0');
            end if;
         when start =>
            if (s_tick = '1') then
               if s_reg=7 then
                  state_next <= data;
                  s_next <= (others=>'0');
                  n_next <= (others=>'0');
               else
                  s_next <= s_reg + 1;
               end if;
            end if;
         when data =>
            if (s_tick = '1') then
               if s_reg=15 then
                  s_next <= (others=>'0');
                  b_next <= rx & b_reg(7 downto 1) ;
                  if n_reg=(DBIT-1) then
							if((par = "00") or (par = "11")) then --No parity
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
				if(s_tick = '1') then
					if s_reg=15 then
						state_next <= stop;
						s_next <= (others => '0');
						if(par = "01") then --Even parity
							if(xorOut='1') then --Not even, parity error
								errorsTemp_next(2) <= '1';
							end if;
						else --Odd parity
							if(xorOut='1') then  --Not odd, parity error
								errorsTemp_next(2) <= '1';
							end if;
						end if;
					else
						s_next <= s_reg + 1;
					end if;
				end if;
         when stop =>
            if (s_tick = '1') then
               if s_reg=15 then
						s_next <= (others=>'0');
						if rx='0' then errorsTemp_next(1) <= '1'; end if; --Check for Frame error
						if(n_reg=SB_TICK) then
							if(isFull='1') then --If FIFO is full, Buffer-overrun error occurs
								errorsTemp_next(0) <= '1';
							end if;
							state_next <= idle;
							rx_done_tick <='1';
						else
							n_next <= n_reg + 1;
						end if;
               else
                  s_next <= s_reg + 1;
               end if;
            end if;
      end case;
   end process;
	err <= errorsTemp_reg;
   dout <= b_reg;
end arch;