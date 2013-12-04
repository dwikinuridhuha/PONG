library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ram_shifter is
   generic(
      ADDR_WIDTH: integer:=12;
      DATA_WIDTH: integer:=8
   );
   port(
      clk: in std_logic;
      we: in std_logic;
      addr: in std_logic_vector(ADDR_WIDTH-1 downto 0);
      din: in std_logic_vector(DATA_WIDTH-1 downto 0);
      dout: out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end ram_shifter;

architecture beh_arch of ram_shifter is
	constant MAX_ADDR: integer := 2**ADDR_WIDTH - 1;
   type ram_type is array (2**ADDR_WIDTH-1 downto 0)
        of std_logic_vector (DATA_WIDTH-1 downto 0) ;
   signal ram: ram_type := ((others=> (others=>'0')));
   signal addr_reg: std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
   process (clk)
   begin
      if (clk'event and clk = '1') then
         if (we='1') then
				-- shift down
				for I in 1 to MAX_ADDR-1 loop
					ram(I) <= ram(I-1); 
            end loop;
				-- write
				ram(0) <= din;
			end if;
        addr_reg <= addr;
      end if;
   end process;
   dout <= ram(to_integer(unsigned(addr_reg)));
end beh_arch;

