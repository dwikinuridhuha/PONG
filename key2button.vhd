----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:33:36 12/02/2013 
-- Design Name: 
-- Module Name:    key2button - Behavioral 
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

entity key2button is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  key_ready: in STD_LOGIC;
           ascii_code : in  STD_LOGIC_VECTOR (7 downto 0);
           btn : out  STD_LOGIC_VECTOR (3 downto 0));
end key2button;

architecture Behavioral of key2button is

begin

	process(clk, reset)
	begin
		if reset='1' then 
			btn <= (others=>'0');
		elsif clk'event and clk='1' then
			btn <= (others=>'0');
			if key_ready='1' then
				case ascii_code is
					when LEFT_UP => btn(3) <= '1';
					when LEFT_DOWN => btn(2) <= '1';
					when RIGHT_UP => btn(0) <= '1';
					when RIGHT_DOWN => btn(1) <= '1';
					when others => btn <= (others=>'0');
				end case;
			end if;
		end if;
	end process;

end Behavioral;

