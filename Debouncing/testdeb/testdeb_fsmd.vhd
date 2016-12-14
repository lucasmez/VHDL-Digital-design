library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity testdeb_fsmd is
   port(
      clk, falledge: in std_logic;
      btn: in std_logic_vector(1 downto 0);
      en: out std_logic_vector(2 downto 0);
      ledout: out std_logic_vector(7 downto 0)
   );
end testdeb_fsmd;

architecture arch of testdeb_fsmd  is

   signal q0_reg, q0_next: unsigned(7 downto 0);
   signal d_count: std_logic_vector(7 downto 0);

   signal db_tick, clr: std_logic;
	signal dbedge: std_logic;
begin
	--=================================================
   -- component instantiation
   --=================================================
	--debouncing falledge
	deb: entity work.debouncing_fsmd
				port map(clk, '0', not(falledge), '0', dbedge, open);
						
	--deboucing and edge detector for btn
	deb_edge: entity work.debouncing_fsmd
					port map(clk, '0', not(btn(1)), dbedge, open ,db_tick);
				
	-- instantiate hex display time-multiplexing circuit
   disp_unit: entity work.hexmux
			port map(
			clk=>clk, reset=>'0',
         hex2=>"0000",hex1=>"0000", hex0=>d_count(3 downto 0),
         dp_in=>"000", en=>en, ledout=>ledout);
  

   --=================================================
   -- two counters
   --=================================================
   clr <= not(btn(0));
   process(clk)
   begin
      if (clk'event and clk='1') then
         q0_reg <= q0_next;
      end if;
   end process;
   -- next-state logic for the counter
  
   q0_next <= (others=>'0') when clr='1' else
              q0_reg + 1 when db_tick='1' else
              q0_reg;
   --output
   d_count <= std_logic_vector(q0_reg);
end arch;
