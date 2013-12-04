library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use pongConstants.all;
entity pong_top is
   port(
      clk, reset: in std_logic;
		PS2C  : in  STD_LOGIC;
		PS2D  : in  STD_LOGIC;
		screen_sel: in std_logic;
--      btn: out std_logic_vector (3 downto 0);
      hsync, vsync: out std_logic;
      rgb: out   std_logic_vector (2 downto 0)
   );
end pong_top;

architecture arch of pong_top is
	
   type state_type is (welcome, playernames, newgame, play, newball, over);
   signal video_on, pixel_tick: std_logic;
   
	signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
	signal pix_x, pix_y: unsigned(9 downto 0);
   
	signal gra_still, hit_left, hit_right: std_logic;
  
	signal highscore_rgb, gameover_rgb, game_rgb, player_names_rgb, welcome_rgb: std_logic_vector(2 downto 0);
   signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
   
	signal state_reg, state_next: state_type;
	
	-- player names
	signal left_player : std_logic_vector(20 downto 0);
	signal right_player : std_logic_vector(20 downto 0);
	
	-- ram
	signal we: std_logic;
	signal din, dout: std_logic_vector(41 downto 0);
	signal addr: std_logic_vector(2 downto 0);
	
	--keyboard controller;
	signal keyval, ascii_code: std_logic_vector(7 downto 0);
	signal key_ready: std_logic;
	
	-- key2button
	signal btn: std_logic_vector(3 downto 0);
	
	-- name input controller
	signal name_input_done: std_logic :='0';
	
	
	-- timer unit
   signal timer_tick, timer_start, timer_up: std_logic;
	
	--score state
	signal sleft_reg, sleft_next: unsigned(1 downto 0);
	signal sleft: std_logic_vector(1 downto 0);
	signal sright_reg, sright_next: unsigned(1 downto 0);
	signal sright: std_logic_vector(1 downto 0);
	
begin

	-- instantiate keyboardController
	keyboardController: entity work.keyboardController
		port map(clk=>clk, reset=>reset, PS2C=>PS2C, PS2D=>PS2D, keyval=>keyval, 
				ascii_code=>ascii_code, key_ready=>key_ready);
	-- instantiate key2button
	key2button: entity work.key2button
		port map(clk=>clk, reset=>reset, ascii_code=>ascii_code, key_ready=>key_ready, btn=>btn);
		
				
   -- instantiate video synchonization unit
   vga_sync_unit: entity work.vga_sync
      port map(clk=>clk, reset=>reset,
               hsync=>hsync, vsync=>vsync,
               pixel_x=>pixel_x, pixel_y=>pixel_y,
               video_on=>video_on, p_tick=>pixel_tick);
	
	-- cast signals
	pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
	sleft <= std_logic_vector(sleft_reg); 
	sright <= std_logic_vector(sright_reg);
	
	-- instantiate ram
	ram_unit: entity work.ram_shifter
		generic map(ADDR_WIDTH=>3, DATA_WIDTH=>42)
		port map(clk=>clk, we=>we, din=>din, dout=>dout, addr=>addr);
		

	-- instantiate select player names screen
	nameInputController: entity work.nameInputController
		port map(clk=>clk, reset=>reset, ascii_code=>ascii_code, key_ready=>key_ready, 
				left_player=>left_player, right_player=>right_player, done=>name_input_done);
	-- instantiate game screen
	game_screen: entity work.game_screen
		port map(clk=>clk, reset=>reset, pixel_x=>pixel_x, pixel_y=>pixel_y,
			sleft=>sleft, sright=>sright, btn=>btn, gra_still=>gra_still,
			left_player=>left_player, right_player=>right_player,
			hit_left=>hit_left, hit_right=>hit_right, rgb=>game_rgb);
   
	-- instantiate highscore screen
	highscore_screen: entity work.highscore_screen
		port map(clk=>clk, pixel_x=>pix_x, pixel_y=>pix_y, addr=>addr, names=>dout, rgb=>highscore_rgb);
	-- instantiate gameover screen
	welcome_screen: entity work.welcome_screen
		port map(clk=>clk, pixel_x=>pix_x, pixel_y=>pix_y, rgb=>welcome_rgb);
	-- instantiate gameover screen
	gameover_screen: entity work.gameOverScreen
		port map(clk=>clk, pixel_x=>pix_x, pixel_y=>pix_y, rgb=>gameover_rgb);
		
	player_names_screen: entity work.player_names_screen
		port map(clk=>clk, pixel_x=>pix_x, pixel_y=>pix_y, rgb=>player_names_rgb,
				left_player=>left_player, right_player=>right_player);
		
   
   timer_tick <=  -- 60 Hz tick
      '1' when pixel_x="0000000000" and
               pixel_y="0000000000" else
      '0';
   
	-- instantiate 2 sec timer
	timer_unit: entity work.timer
      port map(clk=>clk, reset=>reset,
               timer_tick=>timer_tick,
               timer_start=>timer_start,
               timer_up=>timer_up);
   -- registers
   change_state: process (clk,reset)
   begin
      if reset='1' then
         state_reg <= welcome;
         rgb_reg <= (others=>'0');
			sleft_reg <= (others=>'0');
			sright_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
         sleft_reg <= sleft_next;
			sright_reg <= sright_next;
         if (pixel_tick='1') then
           rgb_reg <= rgb_next;
         end if;
      end if;
   end process change_state;
   
	-- fsmd next-state logic
   next_state: process(btn,hit_left,hit_right,timer_up,state_reg,
           sleft_reg, sright_reg, sleft_next, sright_next,
			  left_player, right_player)
   begin
		-- defaults
      gra_still <= '1';
      timer_start <='0';
      state_next <= state_reg;
      sleft_next <= sleft_reg;
		sright_next <= sright_reg;
		we<='0';
      case state_reg is
			when welcome =>
				if key_ready='1' then
					state_next <= playernames;
				end if;
			when playernames =>
				if name_input_done='1' then
					state_next <= newgame;
				end if;
         when newgame =>
            sleft_next <= "00";
				sright_next <= "00";
            if (btn /= "0000") then -- button pressed
               state_next <= play;
            end if;
         when play =>
            gra_still <= '0';    -- animated screen
            
				-- increment the appropiate score
				if hit_left='1' then
               sleft_next <= sleft_reg + 1;
            elsif hit_right='1' then
					sright_next <= sright_reg +1;
            end if;
				
				-- handle transitions
				if hit_left='1' or hit_right='1' then
					if hit_left='1' and sleft_reg=MAX_SCORE   then
						state_next <= over;
						din <= left_player & right_player;
						we<='1';
					elsif hit_right='1' and sright_reg=MAX_SCORE then
						state_next <= over;
						din <= right_player & left_player;
						we<='1';
					else
						state_next <= newball;
					end if;
					timer_start <= '1';
				end if;
				
         when newball =>
            -- wait for 2 sec and until button pressed
            if  timer_up='1' and (btn /= "0000") then
              state_next <= play;
            end if;
         
			when over =>
            -- wait for 2 sec to display game over
            if timer_up='1' then
                state_next <= playernames;
            end if;
       end case;
   end process next_state;
	
   -- rgb multiplexing circuit
   mux_rbg: process(state_reg,video_on, game_rgb, gameover_rgb, highscore_rgb, player_names_rgb, welcome_rgb, screen_sel)
   begin
      if video_on='0' then
         rgb_next <= "000"; -- blank the edge/retrace
      else
			if screen_sel='1' then
				rgb_next <= highscore_rgb;
			else
				case state_reg is
					when welcome =>
						rgb_next <= welcome_rgb;
					when playernames =>
						rgb_next <= player_names_rgb;
					when newgame | newball | play =>
						rgb_next <= game_rgb;
					when over =>
						rgb_next <= gameover_rgb;
				end case;
			end if;
		end if;
   end process mux_rbg;
   rgb <= rgb_reg;
end arch;