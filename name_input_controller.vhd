----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:05:29 12/01/2013 
-- Design Name: 
-- Module Name:    nameInputController - Behavioral 
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

entity nameInputController is
    Port ( ascii_code : in  STD_LOGIC_VECTOR (7 downto 0);
			  key_ready : in STD_LOGIC;
			  clk : in STD_LOGIC;
			  reset : in STD_LOGIC;
           left_player : out  STD_LOGIC_VECTOR (20 downto 0);
           right_player : out  STD_LOGIC_VECTOR(20 downto 0);			  
			  done : out STD_LOGIC);
end nameInputController;

architecture arch of nameInputController is
	
	constant BACKSPACE : std_logic_vector(7 downto 0) := "00001000"; --backspace
	constant ENTER : std_logic_vector(7 downto 0) := "00001101"; --enter
	constant UNDERSCORE : std_logic_vector(6 downto 0) := "1011111"; --underscore
	constant MAX_INPUTS: integer:= 5;
	
	signal finish : std_logic;
	signal state_reg,state_next : integer range 0 to MAX_INPUTS := 0;
	type initials_array is array(0 to MAX_INPUTS) of std_logic_vector(6 downto 0);
	signal initials, initials_next: initials_array:= (0=>UNDERSCORE, others=> (others=>'0'));

	
begin

-- Registers update
process (clk, reset)
begin
--	done<='0';
	if(reset = '1') then  
		state_reg <= 0;
		initials <= (0=>UNDERSCORE, others=> (others=>'0'));
--		state_next <= 0;
--		initials_next <= (0=>UNDERSCORE, others=> (others=>'0'));
	elsif (clk'event and clk = '1') then	
		state_reg <= state_next;
		initials <= initials_next;
	end if;
end process;

process(state_reg, initials, ascii_code,key_ready, reset)
variable index, iterations: integer range 0 to MAX_INPUTS := 0;
begin
--
	if reset='1' then
		state_next <= 0;
		initials_next <= (0=>UNDERSCORE, others=> (others=>'0'));
		finish <= '0';
	elsif (key_ready'event and key_ready='1') then
		state_next <= state_reg;
		initials_next <= initials;
		finish <= '0';
		if ascii_code=ENTER and initials(state_reg) /= UNDERSCORE then
			if state_reg = MAX_INPUTS then
				state_next <= state_reg +1;
				finish <= '1';
--				initials_next <= (0=>UNDERSCORE, others=> (others=>'0'));
			elsif state_reg < MAX_INPUTS then
				state_next <= state_reg + 1;
				initials_next(state_reg +1) <= UNDERSCORE;
			else
				state_next <= state_reg;
				initials_next <= initials;
				finish<='1';
			end if;
		elsif ascii_code=BACKSPACE and state_reg > 0 then
			index:=0;
			iterations:= MAX_INPUTS - state_reg;
			while index <= iterations loop
				initials_next(state_reg + index) <= (others=>'0');
				index := index+1;
			end loop;

			initials_next(state_reg-1) <= UNDERSCORE;
			state_next <= state_reg - 1;
		else
			initials_next(state_reg) <= ascii_code(6 downto 0);
		end if;
	end if;
end process;


-- Set the output lines
left_player  <= initials(0) & initials(1) & initials(2);
right_player <= initials(3) & initials(4) & initials(5);
done <= finish;
end arch;

