----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:07:47 10/07/2015 
-- Design Name: 
-- Module Name:    stack - Behavioral 
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

entity stack is
	 Generic(W:	natural := 4;	--Number of address bits
				D: natural := 8);	--Number of data bits
				
    Port ( clk, reset : in  STD_LOGIC;
           push : in  STD_LOGIC;
           pop : in  STD_LOGIC;
           w_data : in  STD_LOGIC_VECTOR (D-1 downto 0);
           r_data : out  STD_LOGIC_VECTOR (D-1 downto 0);
           full : out  STD_LOGIC;
           empty : out  STD_LOGIC);
end stack;

architecture Behavioral of stack is
	type reg_type is array ((2**W)-1 downto 0) of std_logic_vector(D-1 downto 0);
	signal reg: 							reg_type;
	signal wr:								std_logic;		--write to register
	signal fll,epty:						std_logic;		--full, empty
	signal w_pointer, w_pointernx:	std_logic_vector(W-1 downto 0);	--Address to register
	signal ptp1:							unsigned(W-1 downto 0);	--w_pointer + 1
	
begin

--************************
--state for register holding pointer
--************************
process(clk,reset)
begin
	if(reset='1') then
		w_pointer <= (others => '0');
	elsif(clk'event and clk='1') then
		if(wr='1') then
			w_pointer <= w_pointernx;
		end if;
	end if;
end process;

------Next state logic
	ptp1 <= unsigned(w_pointer) + 1;
	fll <= 	'1' when (ptp1 > to_unsigned((2**W)-1, W)) else
				'0';
	epty <= 	'1' when (to_integer(unsigned(w_pointer)) = 0) else
				'0';
	wr <= '0' when (push='1' and pop='1') else
			'1' when ((push='1' and fll='0') or (pop='1' and epty='0')) else
			'0';
	w_pointernx <= std_logic_vector(ptp1) when (push='1') else
						std_logic_vector(ptp1-2) when (pop='1') else
						w_pointer;
						
						
--************************
--Register file control circuit
--************************
process(clk,reset)
begin
	if(reset='1') then
		reg <= (others => (others => '0'));
	elsif(clk'event and clk='1') then
		if(wr='1') then
			reg(to_integer(unsigned(w_pointer))) <= w_data;
		end if;
	end if;
end process;

------Outputs
	r_data <= reg(to_integer(unsigned(w_pointer)));
	full <= fll;
	empty <= epty;
	
end Behavioral;

