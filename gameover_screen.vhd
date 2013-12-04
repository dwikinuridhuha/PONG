----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:26:06 11/30/2013 
-- Design Name: 
-- Module Name:    gameOverScreen - Behavioral 
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
use ieee.numeric_std.all;
use pongConstants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gameOverScreen is
	Port (
		clk: in std_logic;	
		pixel_x : in  unsigned(9 downto 0);
		pixel_y : in  unsigned(9 downto 0);
		rgb : out  STD_LOGIC_VECTOR(2 downto 0)
	);
end gameOverScreen;

architecture Behavioral of gameOverScreen is
	constant PIXEL_TOP: integer := 176;
	constant PIXEL_BOTTOM: integer := 304; 
	
	signal over_on : std_logic;
	-- rom addressor
	signal char_addr: std_logic_vector(6 downto 0);
	signal row_addr: std_logic_vector(3 downto 0);
	signal bit_addr: std_logic_vector(2 downto 0);
	signal font_bit: std_logic;
begin
	romAddressor: entity work.romAddressor
		port map(clk=>clk, char_addr=>char_addr, row_addr=>row_addr, bit_addr=>bit_addr, font_bit=>font_bit);
	
	over_on <=
	'1' when pixel_y >= PIXEL_TOP and pixel_y < PIXEL_BOTTOM else
	'0';
	

   with pixel_x(9 downto 6) select
     char_addr <=
        "1000111" when x"1", -- G x47
        "1100001" when x"2", -- a x61
        "1101101" when x"3", -- m x6d
        "1100101" when x"4", -- e x65
        "0000000" when x"5", --
        "1001111" when x"6", -- O x4f
        "1110110" when x"7", -- v x76
        "1100101" when x"8", -- e x65
        "1110010" when x"9", -- r x72
		  "0000000" when others;
  
  process(over_on)
  begin
		rgb <= GAMEOVER_BACKGROUND;
		-- Scale 64 by 128
		row_addr <= std_logic_vector(pixel_y(6 downto 3));
		bit_addr <= std_logic_vector(pixel_x(5 downto 3)); 
		if over_on='1' then
			row_addr <= getRowAddr(pixel_y, PIXEL_TOP, 8);
			if font_bit='1' then
				rgb <= TEXT_RGB;
			end if;
		end if;
  end process;
		  
end Behavioral;

