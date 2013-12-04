----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:39:59 12/01/2013 
-- Design Name: 
-- Module Name:    game_screen - Behavioral 
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

entity game_screen is
	Port(
		clk, reset: in std_logic;
      pixel_x, pixel_y: in std_logic_vector(9 downto 0);
		sleft: in std_logic_vector(1 downto 0);
      sright: in std_logic_vector(1 downto 0);
		btn: in std_logic_vector(3 downto 0);
		gra_still: in std_logic;
		left_player, right_player: std_logic_vector(20 downto 0);
      hit_left, hit_right: out std_logic;
      rgb: out std_logic_vector(2 downto 0)
		);
end game_screen;

architecture Behavioral of game_screen is
	signal graph_on : std_logic;
	signal text_on : std_logic_vector(1 downto 0);
	signal graph_rgb, text_rgb: std_logic_vector(2 downto 0);
begin
	-- instantiate text module
	text_unit: entity work.pong_text
      port map(clk=>clk, reset=>reset,
               pixel_x=>pixel_x, pixel_y=>pixel_y,
               sleft=>sleft, sright=>sright,
					left_player=>left_player, right_player=>right_player,
               text_on=>text_on, text_rgb=>text_rgb);
   -- instantiate graph module
   graph_unit: entity work.pong_graph
      port map(clk=>clk, reset=>reset, btn=>btn,
              pixel_x=>pixel_x, pixel_y=>pixel_y,
              gra_still=>gra_still, hit_left=>hit_left, hit_right=>hit_right,
              graph_on=>graph_on,rgb=>graph_rgb);

	-- select which object goes on the foreground
	process(graph_on, text_on, text_rgb, graph_rgb)
	begin
		rgb <= GAME_BACKGROUND;
		if text_on(1)='1' then
			rgb <= text_rgb;
		elsif graph_on ='1' then
			rgb <= graph_rgb;
		elsif text_on(0)='1' then
			rgb <= text_rgb;
		end if;
	end process;
end Behavioral;

