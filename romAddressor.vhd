----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:41:03 11/30/2013 
-- Design Name: 
-- Module Name:    romAddressor - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity romAddressor is
    Port ( 
			clk: in STD_LOGIC;
			  char_addr : in  std_logic_vector(6 downto 0);
           row_addr : in  std_logic_vector(3 downto 0);
           bit_addr : in  std_logic_vector(2 downto 0);
           font_bit : out  STD_LOGIC);
end romAddressor;

architecture Behavioral of romAddressor is
	signal font_word: std_logic_vector(7 downto 0);
	signal rom_addr: std_logic_vector(10 downto 0);
begin
	font_unit: entity work.font_rom
		port map(clk=>clk, addr=>rom_addr, data=>font_word);
		
   rom_addr <= char_addr & row_addr;
   font_bit <= font_word(to_integer(unsigned(not bit_addr)));
	
end Behavioral;

