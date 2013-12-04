library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use pongConstants.all;
entity pong_text is
   port(
      clk, reset: in std_logic;
      pixel_x, pixel_y: in std_logic_vector(9 downto 0);
		sleft, sright: in std_logic_vector(1 downto 0);
		left_player, right_player: std_logic_vector(20 downto 0);
      text_on: out std_logic_vector(1 downto 0);
      text_rgb: out std_logic_vector(2 downto 0)
   );
end pong_text;

architecture arch of pong_text is
   signal pix_x, pix_y: unsigned(9 downto 0);
   signal rom_addr: std_logic_vector(10 downto 0);
   signal char_addr, char_addr_sl, char_addr_sr, char_addr_l
         : std_logic_vector(6 downto 0);
   signal row_addr, row_addr_sl, row_addr_sr, row_addr_l
			: std_logic_vector(3 downto 0);
   signal bit_addr, bit_addr_sl, bit_addr_sr, bit_addr_l
			: std_logic_vector(2 downto 0);
			
   signal font_bit: std_logic;
   signal score_left_on, score_right_on, logo_on: std_logic;
begin
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);

	-- instantiate addressor
	romAddressor: entity work.romAddressor
		port map(clk=>clk, char_addr=>char_addr, row_addr=>row_addr, bit_addr=>bit_addr, font_bit=>font_bit);

   ---------------------------------------------
   -- score left region
   --  - display two-digit score, ball on top left
   --  - scale to 16-by-32 font
   --  - line 1, 16 chars: "III Score:D"
   ---------------------------------------------
   score_left_on <=
      '1' when pix_y(9 downto 5)=0 and
               pix_x<176 else
      '0';
   row_addr_sl <= std_logic_vector(pix_y(4 downto 1));
   bit_addr_sl <= std_logic_vector(pix_x(3 downto 1));
   with pix_x(7 downto 4) select
     char_addr_sl <=
		  left_player(20 downto 14) when "0000", -- I x53
        left_player(13 downto 7) when "0001", -- I x63
        left_player(6 downto 0) when "0010", -- I x6f
        "0000000" when "0011", -- SPACE x3a
        "1010011" when "0100", -- S x53
        "1100011" when "0101", -- c x63
        "1101111" when "0110", -- o x6f
        "1110010" when "0111", -- r x72
        "1100101" when "1000", -- e x65
        "0111010" when "1001", -- : x3a
        "01100" & sleft when "1010",
        "0000000" when others;
		  
	---------------------------------------------
	-- score right region
	---------------------------------------------
	score_right_on <=
		'1' when pix_y(9 downto 5)=0 and
			pix_x>=464 and pix_x<MAX_X else
		'0';
	row_addr_sr <= std_logic_vector(pix_y(4 downto 1));
   bit_addr_sr <= std_logic_vector(pix_x(3 downto 1));
	with pix_x(7 downto 4) select
	 char_addr_sr <=
		  right_player(20 downto 14) when x"D", -- I x53
        right_player(13 downto 7) when x"E", -- I x63
        right_player(6 downto 0) when x"F", -- I x6f
        "0000000" when x"0", -- SPACE x3a
        "1010011" when x"1", -- S x53
        "1100011" when x"2", -- c x63
        "1101111" when x"3", -- o x6f
        "1110010" when x"4", -- r x72
        "1100101" when x"5", -- e x65
        "0111010" when x"6", -- : x3a
        "01100" & sright when x"7",
        "1010100" when others;
   ---------------------------------------------
   -- logo region:
   --   - display logo "PONG" on top center
   --   - used as background
   --   - scale to 64-by-128 font
   ---------------------------------------------
   logo_on <=
      '1' when pix_y(9 downto 7)=2 and
         (3<= pix_x(9 downto 6) and pix_x(9 downto 6)<=6) else
      '0';
   row_addr_l <= std_logic_vector(pix_y(6 downto 3));
   bit_addr_l <= std_logic_vector(pix_x(5 downto 3));
   with pix_x(8 downto 6) select
     char_addr_l <=
        "1010000" when "011", -- P x50
        "1001111" when "100", -- O x4f
        "1001110" when "101", -- N x4e
        "1000111" when others; --G x47
   ---------------------------------------------
   -- mux for font ROM addresses and rgb
   ---------------------------------------------
   process(pix_x,pix_y,font_bit, score_left_on, score_right_on, logo_on,
           char_addr_sl,char_addr_sr,char_addr_l,
           row_addr_sl, row_addr_sr, row_addr_l,
           bit_addr_sl, bit_addr_sr, bit_addr_l)
   begin
      text_rgb <= GAME_BACKGROUND;
      if score_left_on='1' then
         char_addr <= char_addr_sl;
         row_addr <= row_addr_sl;
         bit_addr <= bit_addr_sl;
         if font_bit='1' then
            text_rgb <= SCORE_RGB;
         end if;
		elsif score_right_on='1' then
			char_addr <= char_addr_sr;
			row_addr <= row_addr_sr;
			bit_addr <= bit_addr_sr;
			if font_bit='1' then
				text_rgb <= SCORE_RGB;
			end if;
      elsif logo_on='1' then
         char_addr <= char_addr_l;
         row_addr <= row_addr_l;
         bit_addr <= bit_addr_l;
         if font_bit='1' then
            text_rgb <= LOGO_RGB;
         end if;
      end if;
   end process;
	
	text_on <= (score_left_on or score_right_on) & logo_on;
end arch;