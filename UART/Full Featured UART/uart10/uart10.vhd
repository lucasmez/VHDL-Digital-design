-- Listing 7.4
--PROBLEM WHEN USING 2 STOP BITS!!!!!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uart10 is
   generic(
     -- Default setting:
     -- 19,200 baud, 8 data bis, 1 stop its, 2^2 FIFO
     DBIT: integer:=8;     -- # data bits. Used for FIFO.
     FIFO_W: integer:=4    -- # addr bits of FIFO
                            -- # words in FIFO=2^FIFO_W
   );
   port(
      clk, reset: in std_logic;
      rd_uart, wr_uart: in std_logic;
      rx: in std_logic;
      w_data: in std_logic_vector(7 downto 0);
		bd_rate: in std_logic_vector(1 downto 0); --baud-rate. "00"=1200, "01"=2400, "10"=4800, "11"=9600
		d_num, s_num: in std_logic; --# of data bits, and stop bits
		par: in std_logic_vector(1 downto 0); --"00" or "11" NO parity. "01" EVEN parity. "10" ODD parity
		err: out std_logic_vector(2 downto 0); --MSB -> LSB. Parity, Frame, Buffer-Overrun errors
      tx_full, rx_empty: out std_logic;
      r_data: out std_logic_vector(7 downto 0);
      tx: out std_logic
   );
end uart10;

architecture str_arch of uart10 is
   signal tick: std_logic;
   signal rx_done_tick: std_logic;
   signal tx_fifo_out: std_logic_vector(7 downto 0);
   signal rx_data_out: std_logic_vector(7 downto 0);
   signal tx_empty, tx_fifo_not_empty: std_logic;
   signal tx_done_tick: std_logic;
	signal fullFIFO: std_logic;
	
begin
   baud_gen_unit: entity work.uartBaudGen
      port map(clk=>clk, reset=>reset,
               bd_rate=>bd_rate, tick=>tick);
					
   uart_rx_unit: entity work.uartRx
      port map(clk=>clk, reset=>reset, rx=>rx,
               s_tick=>tick, d_num=>d_num, s_num=>s_num,
					par=>par, isFull=>fullFIFO, err=> err, rx_done_tick=>rx_done_tick,
               dout=>rx_data_out);
					
   fifo_rx_unit: entity work.fifo(arch)
      generic map(B=>DBIT, W=>FIFO_W)
      port map(clk=>clk, reset=>reset, rd=>rd_uart,
               wr=>rx_done_tick, w_data=>rx_data_out,
               empty=>rx_empty, full=>fullFIFO, r_data=>r_data);
					
   fifo_tx_unit: entity work.fifo(arch)
      generic map(B=>DBIT, W=>FIFO_W)
      port map(clk=>clk, reset=>reset, rd=>tx_done_tick,
               wr=>wr_uart, w_data=>w_data, empty=>tx_empty,
               full=>tx_full, r_data=>tx_fifo_out);
					
   uart_tx_unit: entity work.uartTx
      port map(clk=>clk, reset=>reset,
               tx_start=>tx_fifo_not_empty,
               s_tick=>tick, din=>tx_fifo_out,
					d_num=>d_num, s_num=>s_num, par=>par,
               tx_done_tick=> tx_done_tick, tx=>tx);
					
   tx_fifo_not_empty <= not tx_empty;
	
end str_arch;