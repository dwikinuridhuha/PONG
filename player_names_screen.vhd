----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:45:31 12/02/2013 
-- Design Name: 
-- Module Name:    player_names_screen - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use pongConstants.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity player_names_screen is
	Port(
		clk: in std_logic;	
		pixel_x : in  unsigned(9 downto 0);
		pixel_y : in  unsigned(9 downto 0);
		left_player, right_player: std_logic_vector(20 downto 0);
		rgb : out  STD_LOGIC_VECTOR(2 downto 0)
	);
end player_names_screen;

architecture Behavioral of player_names_screen is
	constant PLAYER_LEFT: integer := 128;
	constant PLAYER_RIGHT: integer := 512;
	constant PLAYER1_TOP: integer := 128;
	constant PLAYER2_TOP: integer := 256;
	constant PLAYER_HEIGHT: integer := 64;
	
	-- rom addressor
	signal temp_char_addr: std_logic_vector(7 downto 0);
	signal char_addr: std_logic_vector(6 downto 0);
	signal row_addr: std_logic_vector(3 downto 0);
	signal bit_addr: std_logic_vector(2 downto 0);
	signal font_bit: std_logic;
	
	signal banner_on, player1_on, player2_on: std_logic;
begin
	romAddressor: entity work.romAddressor
		port map(clk=>clk, char_addr=>char_addr, row_addr=>row_addr, bit_addr=>bit_addr, font_bit=>font_bit);
		
	banner_on <=
		'1' when pixel_y < 64 else
		'0';
--	with getOffset(pixel_x, 0, 4) select
--		char_addr
	player1_on <=
		'1' when pixel_x>=PLAYER_LEFT and pixel_x < PLAYER_RIGHT and
				pixel_y >= PLAYER1_TOP and pixel_y < PLAYER1_TOP + PLAYER_HEIGHT else
		'0';
		
	player2_on <=
		'1' when pixel_x>=PLAYER_LEFT and pixel_x < PLAYER_RIGHT and
				pixel_y >= PLAYER2_TOP and pixel_y < PLAYER2_TOP + PLAYER_HEIGHT else
		'0';
	
	process(banner_on)
		variable offset: integer;
	begin
		
		temp_char_addr <= (others=>'0');
		char_addr <= (others=>'0');
		
		rgb <= PLAYER_NAMES_BACKGROUND;
		
		-- Scale of 32 by 64 by default
		offset := getOffset(pixel_x, 0, 32);
		row_addr <= std_logic_vector(pixel_y(5 downto 2));
		bit_addr <= std_logic_vector(pixel_x(4 downto 2));
		
		if banner_on='1' then
			case offset is
				when 0 => temp_char_addr <= x"53";
				when 1 => temp_char_addr <= x"45";
				when 2 => temp_char_addr <= x"4C";
				when 3 => temp_char_addr <= x"45";
				when 4 => temp_char_addr <= x"43";
				when 5 => temp_char_addr <= x"54";
				when 6 => temp_char_addr <= x"00";
				when 7 => temp_char_addr <= x"50";
				when 8 => temp_char_addr <= x"4C";
				when 9 => temp_char_addr <= x"41";
				when 10 => temp_char_addr <= x"59";
				when 11 => temp_char_addr <= x"45";
				when 12 => temp_char_addr <= x"52";
				when 13 => temp_char_addr <= x"00";
				when 14 => temp_char_addr <= x"4E";
				when 15 => temp_char_addr <= x"41";
				when 16 => temp_char_addr <= x"4D";
				when 17 => temp_char_addr <= x"45";
				when 18 => temp_char_addr <= x"53";
				when 19 => temp_char_addr <= x"00";
				when others => temp_char_addr <= x"00";
			end case;
			
		elsif player1_on='1' then
			offset := getOffset(pixel_x, PLAYER_LEFT, 32);
			case offset is
				when 0 => temp_char_addr <= x"50";
				when 1 => temp_char_addr <= x"4C";
				when 2 => temp_char_addr <= x"41";
				when 3 => temp_char_addr <= x"59";
				when 4 => temp_char_addr <= x"45";
				when 5 => temp_char_addr <= x"52";
				when 6 => temp_char_addr <= x"31";
				when 7 => temp_char_addr <= x"3A";
				when 8 => temp_char_addr <= x"00";
				when 9 => temp_char_addr <= '0' & left_player(20 downto 14);
				when 10 => temp_char_addr <= '0' & left_player(13 downto 7);
				when 11 => temp_char_addr <= '0' & left_player(6 downto 0);
				when others => temp_char_addr <= x"00";
			end case;
			
		elsif player2_on='1' then
			offset := getOffset(pixel_x, PLAYER_LEFT, 32);
			case offset is
				when 0 => temp_char_addr <= x"50";
				when 1 => temp_char_addr <= x"4C";
				when 2 => temp_char_addr <= x"41";
				when 3 => temp_char_addr <= x"59";
				when 4 => temp_char_addr <= x"45";
				when 5 => temp_char_addr <= x"52";
				when 6 => temp_char_addr <= x"32";
				when 7 => temp_char_addr <= x"3A";
				when 8 => temp_char_addr <= x"00";
				when 9 => temp_char_addr <= '0' & right_player(20 downto 14);
				when 10 => temp_char_addr <= '0' & right_player(13 downto 7);
				when 11 => temp_char_addr <= '0' & right_player(6 downto 0);
				when others => temp_char_addr <= x"00";
			end case;
		end if;
		
		if banner_on='1' or player1_on='1' or player2_on='1' then
			char_addr <= temp_char_addr(6 downto 0);
			if font_bit='1' then 
				rgb <= TEXT_RGB;
			end if;
		end if;
		
		
	end process;

end Behavioral;

