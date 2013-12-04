----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:14:13 11/30/2013 
-- Design Name: 
-- Module Name:    pongConstants - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package pongConstants is
	constant MAX_SCORE : integer := 2;
	
	-- resolution
	constant MAX_X : integer := 640;
	constant MAX_Y : integer := 480;
	
	-- screen backgrounds
	constant HIGHSCORE_BACKGROUND : std_logic_vector(2 downto 0) := "110";
	constant GAMEOVER_BACKGROUND: std_logic_vector(2 downto 0) := "110";
	constant GAME_BACKGROUND: std_logic_vector(2 downto 0) := "110";
	constant PLAYER_NAMES_BACKGROUND: std_logic_vector(2 downto 0) := "110";
	constant WELCOME_BACKGROUND: std_logic_vector(2 downto 0) := "110";
	
	-- colors
	constant TEXT_RGB: std_logic_vector(2 downto 0) := "000";
	constant HIGHSCORE_DIVIDER_RGB : std_logic_vector(2 downto 0) := "001";
	constant SCORE_RGB: std_logic_vector(2 downto 0) := "001";
	constant LOGO_RGB: std_logic_vector(2 downto 0) := "011";
--	constant _RGB: std_logic_vector(2 downto 0) := "000";
--	constant _RGB: std_logic_vector(2 downto 0) := "000";
--	constant _RGB: std_logic_vector(2 downto 0) := "000";
--	constant _RGB: std_logic_vector(2 downto 0) := "000";
	
	
	-- controls
	constant LEFT_UP: std_logic_vector(7 downto 0) := x"51";
	constant LEFT_DOWN: std_logic_vector(7 downto 0) := x"41";
	constant RIGHT_UP: std_logic_vector(7 downto 0) := x"50";
	constant RIGHT_DOWN: std_logic_vector(7 downto 0) := x"4C";
	
	-- helpers
	function getRowAddr(pixel_y: unsigned(9 downto 0); starting_pixel: integer; scale:integer) return std_logic_vector;
	function getBitAddr(pixel_x: unsigned(9 downto 0); starting_pixel: integer; scale:integer) return std_logic_vector;
	function getOffset(pixel_x: unsigned(9 downto 0); starting_pixel: integer; width: integer) return integer;

end pongConstants;

package body pongConstants is

	function getOffset(pixel_x: unsigned(9 downto 0); starting_pixel: integer; width: integer) return integer is
	begin
		return (to_integer(pixel_x) - starting_pixel) / width;
	end getOffset;

	function getRowAddr(pixel_y: unsigned(9 downto 0); starting_pixel: integer; scale:integer)
			return std_logic_vector is
		variable row: integer;
	begin
		row := (to_integer(pixel_y) - starting_pixel) / scale;
		return std_logic_vector(to_unsigned(row, 4));
	end getRowAddr;	
	
	function getBitAddr(pixel_x: unsigned(9 downto 0); starting_pixel: integer; scale:integer) return std_logic_vector is
	begin
		return getRowAddr(pixel_x, starting_pixel, scale)( 2 downto 0);
	end getBitAddr;
	
end package body;


