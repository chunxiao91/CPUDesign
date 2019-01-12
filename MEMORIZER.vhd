--------------------?????--------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity MEM_AR8 is
port( mem_in_data : in std_logic_vector(15 downto 0);
	mem_addr : in std_logic_vector(15 downto 0);
	mem_enable : in std_logic;
    	mem_wr : in std_logic;
	mem_out_data : out std_logic_vector(15 downto 0));
end MEM_AR8;
architecture rtl of MEM_AR8 is 
type t_ram is array (15 downto 0) of std_logic_vector(15 downto 0);
--signal ramdata : t_ram;
--signal temp_data : std_logic_vector(15 downto 0);
begin
process(mem_enable, mem_wr, mem_addr) 
variable ramdata : t_ram;
variable temp_data : std_logic_vector(15 downto 0);
begin
	if (mem_enable = '1') then
		if(mem_wr = '1') then
			ramdata(conv_integer(mem_addr)) := mem_in_data;
		elsif (mem_wr = '0') then
			temp_data := ramdata(conv_integer(mem_addr));
			mem_out_data <= temp_data;
		end if;
	end if;
	--if (mem_enable = '1' and mem_wr = '1') then
		--ramdata(conv_integer(mem_addr)) <= mem_in_data;
		--temp_data <= ramdata(conv_integer(mem_addr));
	--else if (mem_enable = '1' and mem_wr = '0') then
		--mem_out_data <= temp_data;
	--end if;
end process;
end rtl;
