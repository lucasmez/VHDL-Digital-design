----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:17:32 10/22/2015 
-- Design Name: 
-- Module Name:    carcount - Behavioral 
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

entity carcount is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           ledo : out  STD_LOGIC);
end carcount;

architecture Behavioral of carcount is
begin
	ledo <= a or b;

end Behavioral;

