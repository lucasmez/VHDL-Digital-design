----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:30:12 11/01/2015 
-- Design Name: 
-- Module Name:    period_counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity period_counter is
	port(
      clk, reset: in std_logic;
      start, si: in std_logic;
      ready, done_tick, overflow: out std_logic; --Overflow set if period > 1000ms. f < 1Hz
      prd: out std_logic_vector(9 downto 0)
   );
end period_counter;

--Accuracy: 1Hz - 1MHz
architecture Behavorial of period_counter is
   constant CLK_US_COUNT: integer := 12000; -- 12000 for 1 ms tick /// 12 for 1 us tick
   type state_type is (idle, waite, count, done);
   signal state_reg, state_next: state_type;
   signal t_reg, t_next: unsigned(13 downto 0); -- up to 12000
   signal p_reg, p_next: unsigned(9 downto 0); -- up to 1,000 ms = 1 second
	signal overflow_next, overflow_cur: std_logic;
   signal delay_reg: std_logic;
   signal edge: std_logic;
begin
   -- state and data register
   process(clk,reset)
   begin
      if reset='1' then
         state_reg <= idle;
         t_reg <= (others=>'0');
         p_reg <= (others=>'0');
         delay_reg <= '0';
			overflow_cur <= '0';
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
         t_reg <= t_next;
         p_reg <= p_next;
         delay_reg <= si;
			overflow_cur <= overflow_next;
      end if;
   end process;

	--Edge detection
   edge <= (not delay_reg) and si;

   process(start,edge,state_reg,t_reg,t_next,p_reg)
   begin
      ready <= '0';
      done_tick <= '0';
      state_next <= state_reg;
      p_next <= p_reg;
      t_next <= t_reg;
		overflow_next <= overflow_cur;
      case state_reg is
         when idle =>
            ready <= '1';
            if (start='1') then
					overflow_next <= '0';
               state_next <= waite;
            end if;
         when waite => -- wait for the first edge
            if (edge='1') then
               state_next <= count;
               t_next <= (others=>'0');
               p_next <= (others=>'0');
            end if;
         when count =>
            if (edge='1') then   -- 2nd edge arrived
               state_next <= done;
            else -- otherwise count
               if t_reg = CLK_US_COUNT-1 then -- 1ms tick
                  t_next <= (others=>'0');
                  p_next <= p_reg + 1;
						if(p_reg = 1000) then
							overflow_next <= '1';
							state_next <= done;
						end if;
               else
                  t_next <= t_reg + 1;
               end if;
            end if;
         when done =>
            done_tick <= '1';
            state_next <= idle;
      end case;
   end process;
	
	overflow <= overflow_cur;
   prd <= std_logic_vector(p_reg);
	
	
end Behavorial;