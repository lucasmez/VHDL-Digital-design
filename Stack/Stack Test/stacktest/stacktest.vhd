----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:51:04 10/07/2015 
-- Design Name: 
-- Module Name:    stacktest - Behavioral 
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


entity stacktest is
	port(	clk,reset:	in std_logic;
			btn: 			in std_logic_vector(1 downto 0);
			sw: 			in std_logic_vector(3 downto 0);
			led:			out std_logic_vector(7 downto 0)
	);
end stacktest;

architecture Behavioral of stacktest is
	-- Instantiate stack
	component stack is
		 Generic(W:	natural;	--Number of address bits
				D: natural);	--Number of data bits
				
			Port ( clk, reset : in  STD_LOGIC;
						push : in  STD_LOGIC;
					  pop : in  STD_LOGIC;
					  w_data : in  STD_LOGIC_VECTOR (D-1 downto 0);
					  r_data : out  STD_LOGIC_VECTOR (D-1 downto 0);
					  full : out  STD_LOGIC;
					  empty : out  STD_LOGIC);
	end component;

	-- Instantiate debouncing circuit
	component debouncing is
		port(clk, reset: in std_logic;
				sw: in std_logic;
				db: out std_logic
		);
	end component;
	
	--Instantiate edge detector
	component riseedge is 
		port(clk, reset: in std_logic;
				level: in std_logic;
				tick: out std_logic
		);
	end component;

	signal rstdeb, rstedge: std_logic;
	signal btndeb, btnedge: std_logic_vector(1 downto 0);


begin

	debreset: debouncing port map(clk, '0', not(reset), rstdeb);
	debbtn0: debouncing port map(clk, '0', not(btn(0)), btndeb(0));
	debbtn1: debouncing port map(clk, '0', not(btn(1)), btndeb(1));
	
	edgerst: riseedge port map(clk, '0', rstdeb, rstedge);
	edgebtn0: riseedge port map(clk, '0', btndeb(0), btnedge(0));
	edgebtn1: riseedge port map(clk, '0', btndeb(1), btnedge(1));
	
	stack_unit: stack generic map(W=>3, D=>4) port map(clk,rstedge,btnedge(0),btnedge(1), sw, led(3 downto 0) , led(5), led(6));

	led(4) <= '0';
	led(7) <= '0';

end Behavioral;

