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

entity highscore_screen is
	Port (
		clk: in std_logic;	
		pixel_x : in  unsigned(9 downto 0);
		pixel_y : in  unsigned(9 downto 0);
		names: in std_logic_vector(41 downto 0);
		addr: out std_logic_vector(2 downto 0);
		rgb : out  STD_LOGIC_VECTOR(2 downto 0)
	);
end highscore_screen;

architecture Behavioral of highscore_screen is
	constant DIVIDER_WIDTH : integer := 4;
	constant DIVIDER_X_L : integer := (MAX_X/2 - DIVIDER_WIDTH/2);
	constant DIVIDER_X_R : integer := DIVIDER_X_L + DIVIDER_WIDTH;
	signal banner_on, divider_on : STD_LOGIC;
	signal names_on: std_logic_vector(4 downto 0);
	
	-- rom addressor
	signal char_addr, char_addr_b, char_addr_names: std_logic_vector(6 downto 0);
	signal row_addr: std_logic_vector(3 downto 0);
	signal bit_addr: std_logic_vector(2 downto 0);
	signal font_bit: std_logic;
	

begin

	romAddressor: entity work.romAddressor
		port map(clk=>clk, char_addr=>char_addr, row_addr=>row_addr, bit_addr=>bit_addr, font_bit=>font_bit);
	
	-- divider	
	divider_on <= 
		'1' when pixel_x>= DIVIDER_X_L and pixel_x <= DIVIDER_X_R else
		'0';
	
	-- banner
	banner_on <= 
		'1' when pixel_y(9 downto 6)=0 and
               pixel_x<640 else
      '0';

	with pixel_x(9 downto 5) select
		char_addr_b <= 
			"1010111" when "00010", -- Winner
			"1001001" when "00011",
			"1001110" when "00100",
			"1001110" when "00101",
			"1000101" when "00110",
			"1010010" when "00111",
			"1000100" when "01011", -- Defeated
			"1000101" when "01100",
			"1000110" when "01101",
			"1000101" when "01110",
			"1000001" when "01111",
			"1010100" when "10000",
			"1000101" when "10001",
			"1000100" when "10010",
			"0000000" when others;
	
	-- names
	with pixel_x(9 downto 5) select
		char_addr_names <= 
			names(41 downto 35) when "00100", -- Winner
			names(34 downto 28) when "00101",
			names(27 downto 21) when "00110",
			names(20 downto 14) when "01110", -- Defeated
			names(13 downto 7) when "01111",
			names(6 downto 0) when "10000",
			"0000000" when others;
		
	names_on(0) <= 
		'1' when pixel_y >= 74 and pixel_y < 138 else
		'0';
	
	names_on(1) <= 
		'1' when pixel_y >= 148 and pixel_y < 212 else
		'0';
		
	names_on(2) <= 
		'1' when pixel_y >= 222 and pixel_y < 286 else
		'0';

	names_on(3) <= 
		'1' when pixel_y >= 296 and pixel_y < 360 else
		'0';		
	names_on(4) <= 
		'1' when pixel_y >= 370 and pixel_y < 434 else
		'0';
		
	process(banner_on, divider_on, names_on)
	begin
		-- Scale of 32 by 64 by default
		row_addr <= std_logic_vector(pixel_y(5 downto 2));
		bit_addr <= std_logic_vector(pixel_x(4 downto 2));
		rgb <= HIGHSCORE_BACKGROUND;
		addr <= (others=>'0');
		if divider_on='1' then
			rgb <= HIGHSCORE_DIVIDER_RGB;
		elsif banner_on='1' then
			char_addr <= char_addr_b;
		elsif names_on(0)='1' then
			addr <= "000";
			row_addr <= getRowAddr(pixel_y, 74, 4);
		elsif names_on(1)='1' then
			addr <= "001";
			row_addr <= getRowAddr(pixel_y, 148, 4);
		elsif names_on(2)='1' then
			addr <= "010";
			row_addr <= getRowAddr(pixel_y, 222, 4);
		elsif names_on(3)='1' then
			addr <= "011";
			row_addr <= getRowAddr(pixel_y, 296, 4);
		elsif names_on(4)='1' then
			addr <= "100";
			row_addr <= getRowAddr(pixel_y, 370, 4);
		end if;
		
		if names_on /="00000" then
			char_addr <= char_addr_names;
		end if;
		
		if banner_on='1' or names_on /="00000" then
			if font_bit='1' then
				rgb <= TEXT_RGB;
			end if;
		end if;
	end process;
end Behavioral;

