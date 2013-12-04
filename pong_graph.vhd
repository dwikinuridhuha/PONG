library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use pongConstants.all;

entity pong_graph is
   port(
      clk, reset: std_logic;
      btn: std_logic_vector(3 downto 0);
      pixel_x,pixel_y: in std_logic_vector(9 downto 0);
      gra_still: in std_logic;
      graph_on, hit_left, hit_right: out std_logic;
      rgb: out std_logic_vector(2 downto 0)
   );
end pong_graph;

architecture arch of pong_graph is
   signal pix_x, pix_y: unsigned(9 downto 0);
	constant TOP: integer :=32;

-- Bar constants
	constant BAR_Y_SIZE: integer:=72;
	constant BAR_V: integer:=4;
	constant BAR_WIDTH: integer := 3;
	constant BAR_RGB: std_logic_vector(2 downto 0) := "010";

--	left bar
	constant BAR_LEFT_X_L: integer:= 10;
	constant BAR_LEFT_X_R: integer:= BAR_LEFT_X_L + BAR_WIDTH;
   signal bar_left_y_t, bar_left_y_b: unsigned(9 downto 0);
   signal bar_left_y_reg, bar_left_y_next: unsigned(9 downto 0);

-- Right bar
   constant BAR_RIGHT_X_L: integer:=600;
   constant BAR_RIGHT_X_R: integer:=BAR_RIGHT_X_L + BAR_WIDTH;
   signal bar_right_y_t, bar_right_y_b: unsigned(9 downto 0);
   signal bar_right_y_reg, bar_right_y_next: unsigned(9 downto 0);
   
--	Ball
   constant BALL_SIZE: integer:=8; -- 8
	constant BALL_RGB: std_logic_vector(2 downto 0) := "100";
   signal ball_x_l, ball_x_r: unsigned(9 downto 0);
   signal ball_y_t, ball_y_b: unsigned(9 downto 0);
   signal ball_x_reg, ball_x_next: unsigned(9 downto 0);
   signal ball_y_reg, ball_y_next: unsigned(9 downto 0);
   signal ball_vx_reg, ball_vx_next: unsigned(9 downto 0);
   signal ball_vy_reg, ball_vy_next: unsigned(9 downto 0);
   constant BALL_V_P: unsigned(9 downto 0)
            :=to_unsigned(2,10);
   constant BALL_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-2,10));
   type rom_type is array (0 to 7) of
        std_logic_vector (7 downto 0);
   constant BALL_ROM: rom_type :=
   (
      "00111100", --   ****
      "01111110", --  ******
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "01111110", --  ******
      "00111100"  --   ****
   );
   signal rom_addr, rom_col: unsigned(2 downto 0);
   signal rom_data: std_logic_vector(7 downto 0);
   signal rom_bit: std_logic;
   signal bar_left_on, bar_right_on, sq_ball_on, rd_ball_on: std_logic;

   signal refr_tick: std_logic;
begin
   -- registers
   process (clk,reset)
   begin
      if reset='1' then
         bar_right_y_reg <= (OTHERS=>'0');
         ball_x_reg <= (OTHERS=>'0');
         ball_y_reg <= (OTHERS=>'0');
         ball_vx_reg <= ("0000000100");
         ball_vy_reg <= ("0000000100");
--			hit_left <= '0';
--			hit_right <= '0';
      elsif (clk'event and clk='1') then
			bar_left_y_reg <= bar_left_y_next;
         bar_right_y_reg <= bar_right_y_next;
         ball_x_reg <= ball_x_next;
         ball_y_reg <= ball_y_next;
         ball_vx_reg <= ball_vx_next;
         ball_vy_reg <= ball_vy_next;
      end if;
   end process;
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
	-- Refresh tick
   refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';
   -- paddles
	-- left paddle
   bar_left_y_t <= bar_left_y_reg;
   bar_left_y_b <= bar_left_y_t + BAR_Y_SIZE - 1;
   bar_left_on <=
      '1' when (BAR_LEFT_X_L<=pix_x) and (pix_x<=BAR_LEFT_X_R) and
               (bar_left_y_t<=pix_y) and (pix_y<=bar_left_y_b) else
      '0';
	
	-- Right paddle
   bar_right_y_t <= bar_right_y_reg;
   bar_right_y_b <= bar_right_y_t + BAR_Y_SIZE - 1;
   bar_right_on <=
      '1' when (BAR_RIGHT_X_L<=pix_x) and (pix_x<=BAR_RIGHT_X_R) and
               (bar_right_y_t<=pix_y) and (pix_y<=bar_right_y_b) else
      '0';

	
	-- left bar y-position
   process(bar_left_y_reg,bar_left_y_b,bar_left_y_t,refr_tick,btn,gra_still)
   begin
      bar_left_y_next <= bar_left_y_reg; -- no move
      if gra_still='1' then  --initial position of paddle
         bar_left_y_next <= to_unsigned((MAX_Y-BAR_Y_SIZE)/2,10);
      elsif refr_tick='1' then
         if btn(2)='1' and bar_left_y_b<(MAX_Y-1-BAR_V) then
            bar_left_y_next <= bar_left_y_reg + BAR_V; -- move down
         elsif btn(3)='1' and TOP < (bar_left_y_t-BAR_V) then
            bar_left_y_next <= bar_left_y_reg - BAR_V; -- move up
         end if;
      end if;
   end process;
	
   -- right bar y-position
   process(bar_right_y_reg,bar_right_y_b,bar_right_y_t,refr_tick,btn,gra_still)
   begin
      bar_right_y_next <= bar_right_y_reg; -- no move
      if gra_still='1' then  --initial position of paddle
         bar_right_y_next <= to_unsigned((MAX_Y-BAR_Y_SIZE)/2,10);
      elsif refr_tick='1' then
         if btn(1)='1' and bar_right_y_b<(MAX_Y-1-BAR_V) then
            bar_right_y_next <= bar_right_y_reg + BAR_V; -- move down
         elsif btn(0)='1' and (TOP < (bar_right_y_t-BAR_V)) then
            bar_right_y_next <= bar_right_y_reg - BAR_V; -- move up
         end if;
      end if;
   end process;
	
	-- Ball state
   -- square ball
   ball_x_l <= ball_x_reg;
   ball_y_t <= ball_y_reg;
   ball_x_r <= ball_x_l + BALL_SIZE - 1;
   ball_y_b <= ball_y_t + BALL_SIZE - 1;
   sq_ball_on <=
      '1' when (ball_x_l<=pix_x) and (pix_x<=ball_x_r) and
               (ball_y_t<=pix_y) and (pix_y<=ball_y_b) else
      '0';
   -- round ball
   rom_addr <= pix_y(2 downto 0) - ball_y_t(2 downto 0);
   rom_col <= pix_x(2 downto 0) - ball_x_l(2 downto 0);
   rom_data <= BALL_ROM(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(not rom_col));
   rd_ball_on <=
      '1' when (sq_ball_on='1') and (rom_bit='1') else
      '0';

   -- new ball position
   ball_x_next <=
      to_unsigned((MAX_X)/2,10) when gra_still='1' else
      ball_x_reg + ball_vx_reg when refr_tick='1' else
      ball_x_reg ;
   ball_y_next <=
      to_unsigned((MAX_Y)/2,10) when gra_still='1' else
      ball_y_reg + ball_vy_reg when refr_tick='1' else
      ball_y_reg ;
   -- new ball velocity and collisions
   process(ball_vx_reg,ball_vy_reg,ball_y_t,ball_x_l,ball_x_r,
           ball_y_t,ball_y_b,bar_left_y_t,bar_left_y_b, bar_right_y_t,bar_right_y_b,gra_still)
   begin
      hit_left <='0';
      hit_right <='0';
      ball_vx_next <= ball_vx_reg;
      ball_vy_next <= ball_vy_reg;
      if gra_still='1' then            --initial velocity
         ball_vx_next <= BALL_V_N;
         ball_vy_next <= BALL_V_P;
      elsif ball_y_t < TOP then          -- reach top
         ball_vy_next <= BALL_V_P;
      elsif ball_y_b > (MAX_Y-1) then  -- reach bottom
         ball_vy_next <= BALL_V_N;
      elsif (BAR_LEFT_X_L<=ball_x_l) and (ball_x_l<=BAR_LEFT_X_R) and -- reach left paddle
            (bar_left_y_t<=ball_y_b) and (ball_y_t<=bar_left_y_b) then 
         ball_vx_next <= BALL_V_P;     -- bounce back
      elsif (BAR_RIGHT_X_L<=ball_x_r) and (ball_x_r<=BAR_RIGHT_X_R) and -- reach right paddle
            (bar_right_y_t<=ball_y_b) and (ball_y_t<=bar_right_y_b) then
			-- reach x of right bar
			ball_vx_next <= BALL_V_N; -- bounce back
		elsif (ball_x_l <= 1) then -- reach left border
			hit_right <= '1';
      elsif (ball_x_r >= MAX_X) then     -- reach right border
         hit_left <= '1';                 
      end if;
   end process;
   -- rgb multiplexing circuit
   process(bar_left_on,bar_right_on, rd_ball_on)
   begin
		if bar_left_on='1' then
			rgb <= BAR_RGB;
      elsif bar_right_on='1' then
         rgb <= BAR_RGB;
      elsif rd_ball_on='1' then
         rgb <= BALL_RGB;
      else
         rgb <= GAME_BACKGROUND;
      end if;
   end process;
   -- turn on graph
   graph_on <= bar_left_on or bar_right_on or rd_ball_on;
end arch;
