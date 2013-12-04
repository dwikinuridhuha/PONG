----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:26:06 11/30/2013 
-- Design Name: 
-- Module Name:    welcome_screen - Behavioral 
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

entity welcome_screen is
	Port (
		clk: in std_logic;	
		pixel_x : in  unsigned(9 downto 0);
		pixel_y : in  unsigned(9 downto 0);
		rgb : out  STD_LOGIC_VECTOR(2 downto 0)
	);
end welcome_screen;

architecture Behavioral of welcome_screen is
	constant PIXEL_TOP: integer := 176;
	constant PIXEL_BOTTOM: integer := 304;
	constant PIXEL_LEFT: integer := 192;
	constant PIXEL_RIGHT: integer := 448;
	
	signal logo_on, press_on : std_logic;
	-- rom addressor
	signal char_addr: std_logic_vector(6 downto 0);
	signal row_addr: std_logic_vector(3 downto 0);
	signal bit_addr: std_logic_vector(2 downto 0);
	signal font_bit: std_logic;
	
	-- Pong logo rom
	type pong_rom_type is array (0 to 3) of
       std_logic_vector (6 downto 0);
   constant PONG_ROM: pong_rom_type :=
   (
		"1010000", -- Pong
		"1001111", 
		"1001110",
		"1000111"
   );
	
	-- Press A key ROM
	type press_rom_type is array (0 to 10) of
       std_logic_vector (6 downto 0);
   constant PRESS_ROM: press_rom_type :=
   (
		"1010000",
		"1010010",
		"1000101",
		"1010011",
		"1010011",
		"0000000",
		"1000001",
		"0000000",
		"1001011",
		"1000101",
		"1011001"
   );
	
begin
	romAddressor: entity work.romAddressor
		port map(clk=>clk, char_addr=>char_addr, row_addr=>row_addr, bit_addr=>bit_addr, font_bit=>font_bit);
	
	logo_on <=
	'1' when pixel_y >= PIXEL_TOP and pixel_y < PIXEL_BOTTOM
				and pixel_x >= PIXEL_LEFT and pixel_x < PIXEL_RIGHT else
	'0';
	
	press_on <=
		'1' when pixel_y >= 320 and pixel_y < 336
				and pixel_x >=276 and pixel_x < 364 else
		'0';
	
	
  process(logo_on)
	variable offset: integer;
  begin
		rgb <= WELCOME_BACKGROUND;
		-- Scale 64 by 128
		row_addr <= std_logic_vector(pixel_y(6 downto 3));
		bit_addr <= std_logic_vector(pixel_x(5 downto 3));
		char_addr <= (others=>'0');
		if logo_on='1' then
			row_addr <= getRowAddr(pixel_y, PIXEL_TOP, 8);
			char_addr <= PONG_ROM(getOffset(pixel_x, PIXEL_LEFT, 64));
			if font_bit='1' then
				rgb <= TEXT_RGB;
			end if;
		elsif press_on='1' then
			row_addr <= getRowAddr(pixel_y, 320, 1);
			char_addr <= PRESS_ROM(getOffset(pixel_x, 276, 8));
			bit_addr <= getBitAddr(pixel_x, 276, 1);
			if font_bit='1' then
				rgb <= TEXT_RGB;
			end if;
		end if;
  end process;
		  
end Behavioral;

