---------------------???--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity STACK is
port( stack_in_data : in std_logic_vector(15 downto 0);
	stack_enable : in std_logic;
    	stack_wr : in std_logic;
	stack_out_data : out std_logic_vector(15 downto 0));
end STACK;
architecture rtl of STACK is 
type t_ram is array (127 downto 0) of std_logic_vector(15 downto 0);

begin
	process(stack_enable, stack_wr) 
	variable sp : integer range 0 to 127;
	variable ramdata : t_ram;
	variable temp_data : std_logic_vector(15 downto 0);
		begin
		sp := 127;
		if (stack_enable = '1') then
			if(stack_wr = '1') then
				ramdata(sp) := stack_in_data;
				sp := sp - 1;
			elsif (stack_wr = '0') then
				temp_data := ramdata(sp);
				stack_out_data <= temp_data;
				sp := sp +1;
			end if;
		end if;
		if(sp = 0) then
			sp := 127;
		
		end if;
	end process;
end rtl;
