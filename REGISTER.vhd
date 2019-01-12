---------------------???????-------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity REG_AR8 is
port(reg_in_data : in std_logic_vector(15 downto 0);
	regSel : in std_logic_vector(1 downto 0);
	reg_cs : in std_logic;
    	reg_wr : in std_logic;
	reg_q : out std_logic_vector(15 downto 0));
end REG_AR8;
architecture rtl of REG_AR8 is 
type t_ram is array (10000 downto 0) of std_logic_vector(15 downto 0);
--signal ramdata : t_ram;
--signal temp_data : std_logic_vector(15 downto 0);
begin

	process(reg_cs, reg_wr, regSel) 
		variable ramdata : t_ram;
		variable temp_data : std_logic_vector(15 downto 0);
	begin
		ramdata(0) := "0000000000000001";
		ramdata(1) := "0000000000000011";
		
		if (reg_cs = '1') then
			if(reg_wr = '1') then
				ramdata(conv_integer(regSel)) := reg_in_data;
			elsif (reg_wr = '0') then
				temp_data := ramdata(conv_integer(regSel));
				reg_q <= temp_data;
			end if;
		end if;
		--if (reg_cs = '1' and reg_wr = '1') then
			--ramdata(conv_integer(regSel)) <= reg_in_data;
			--temp_data <= ramdata(conv_integer(regSel);
		
		--else (reg_cs ='1' and reg_wr = '0') then
			--q <= temp_data;
		--end if;
	end process;
end rtl;




