----------------------------------------------------------------------------------
-- Company: 
-- Create Date:    13:15:14 10/30/2013 
-- Design Name: 
-- Module Name:    keyboardController - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Description: This module works for the Spartan XC3200 it constantly polls the clock 
-- to revise 
--
-- Dependencies: None
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;

entity keyboardController is
    Port ( clk : in  STD_LOGIC;
           reset   : in  STD_LOGIC;
           PS2C  : in  STD_LOGIC;
           PS2D  : in  STD_LOGIC;
           keyval : out  STD_LOGIC_VECTOR(7 downto 0);
			  ascii_code: out STD_LOGIC_VECTOR(7 downto 0);
           key_ready : out  STD_LOGIC
			  );
end keyboardController;

architecture Behavioral of keyboardController is
-- filters
signal PS2Df,PS2Cf: STD_LOGIC;
signal ps2c_filter, ps2d_filter: std_logic_vector(7 downto 0);

-- Scan Code
signal bitCount : integer range 0 to 100 := 0;
signal scancodeReady : STD_LOGIC := '0';
signal scancode : STD_LOGIC_VECTOR(7 downto 0);
signal breakReceived : STD_LOGIC := '0';

-- key2ascii
--signal ascii: STD_LOGIC_VECTOR(7 downto 0);

begin

-- instantiate key2ascii
	key2ascii: entity work.key2ascii
		port map(key_code=>scancode, ascii_code=>ascii_code);

-- Current State  
-- Module 1 Filter the clock and data signals!
filter: process(clk, reset)
begin
	if reset = '1' then
		ps2c_filter <= (others => '0');
		ps2d_filter <= (others => '0');
		PS2Df <= '1';
	elsif clk'event and clk ='1' then -- rising edge polling the 25mhz is faster than the keyboard clock which is 25khz
		ps2c_filter(7) <= PS2C; -- Add new clock data
		ps2c_filter(6 downto 0) <= ps2c_filter(7 downto 1); -- shift down Clock Data
		ps2d_filter(7) <= PS2D; -- Add new Key data 
		ps2d_filter(6 downto 0) <= ps2d_filter(7 downto 1); -- shift down Key data
		if ps2c_filter = X"FF" then 
			PS2Cf <= '1'; -- Poll the clock and set it to 1 
		elsif ps2c_filter = X"00" then 
			PS2Cf <= '0'; -- Poll the clock and set it to 0 
		end if;
		if ps2d_filter = X"FF" then 
			PS2Df <= '1'; -- Poll the data and set it to 1
		elsif ps2d_filter = X"00" then
			PS2Df <= '0'; -- Poll the data and set it to 0 
		end if;
	end if;
end process filter;

-- Module 2: get key data
FilterPros : process(PS2Cf)
begin
		 if falling_edge(PS2Cf) then
					if bitCount = 0 and PS2Df = '0' then --keyboard wants to send data
							  scancodeReady <= '0';
							  bitCount <= bitCount + 1;
					elsif bitCount > 0 and bitCount < 9 then -- shift one bit into the scancode from the left
							  scancode <= PS2Df & scancode(7 downto 1);
							  bitCount <= bitCount + 1;
					elsif bitCount = 9 then -- parity bit
							  bitCount <= bitCount + 1;
					elsif bitCount = 10 then -- end of message
							  scancodeReady <= '1';
							  bitCount <= 0;
					end if;
		 end if;
end process FilterPros;

-- Module 3: output keys
HandleKeys: process(scancodeReady, scancode)
begin
		 if scancodeReady'event and scancodeReady = '1' then
					-- breakcode breaks the current scancode
					if breakReceived = '1' then
							  breakReceived <= '0';
							  key_ready <= '0';
							  keyval <= scancode;
					elsif breakReceived = '0' then
							  -- scancode processing
							  if scancode = "11110000" then -- mark break for next scancode
									breakReceived <= '1';
							  end if;
							  key_ready <= '1';
							  keyval <= scancode;
					end if;
		 end if;
end process HandleKeys;

end Behavioral;

