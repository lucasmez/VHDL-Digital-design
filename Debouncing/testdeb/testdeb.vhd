-- Listing 5.7
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity debounce_test is
   port(
      clk: in std_logic;
      btn: in std_logic_vector(1 downto 0);
      en: out std_logic_vector(2 downto 0);
      ledout: out std_logic_vector(7 downto 0)
   );
end debounce_test;

architecture arch of debounce_test is
   signal q1_reg, q1_next: unsigned(7 downto 0);
   signal q0_reg, q0_next: unsigned(7 downto 0);
   signal b_count, d_count: std_logic_vector(7 downto 0);
   signal btn_reg, db_reg: std_logic;
   signal db_level, db_tick, btn_tick, clr: std_logic;
begin
   --=================================================
   -- component instantiation
   --=================================================
   -- instantiate hex display time-multiplexing circuit
   disp_unit: entity work.hexmux
      port map(
         clk=>clk, reset=>'0',
         hex2=>b_count(7 downto 4), hex1=>b_count(3 downto 0), hex0=>d_count(3 downto 0),
         dp_in=>"101", en=>en, ledout=>ledout);
   -- instantiate debouncing circuit
   db_unit: entity work.debouncing(pre)
      port map(
         clk=>clk, reset=>'0',
         sw=>not(btn(1)), db=>db_level);
	-- instantiate dual edge detector
	dual_edge: entity work.dualedge port map(clk, '0', not(btn(1)), btn_tick);
	dual_egde2:entity work.dualedge port map(clk, '0', db_level, db_tick);

   --=================================================
   -- edge detection circuits
   --=================================================
--   process(clk)
--   begin
--      if (clk'event and clk='1') then
--         btn_reg <= not(btn(1));
--         db_reg <= db_level;
--      end if;
--   end process;
--   btn_tick <= (not btn_reg) and not(btn(1));
--   db_tick <= (not db_reg) and db_level;

   --=================================================
   -- two counters
   --=================================================
   clr <= not(btn(0));
   process(clk)
   begin
      if (clk'event and clk='1') then
         q1_reg <= q1_next;
         q0_reg <= q0_next;
      end if;
   end process;
   -- next-state logic for the counter
   q1_next <= (others=>'0') when clr='1' else
              q1_reg + 1 when btn_tick='1' else
              q1_reg;
   q0_next <= (others=>'0') when clr='1' else
              q0_reg + 1 when db_tick='1' else
              q0_reg;
   --output
   b_count <= std_logic_vector(q1_reg);
   d_count <= std_logic_vector(q0_reg);
end arch;
