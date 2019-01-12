-------------------???????----------------
-----------------?????????--------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity INSTRR_REG is
port(instr_reg_pc : in std_logic_vector(15 downto 0);
	instr_reg_cs : in std_logic;
	instr_reg_q : out std_logic_vector(31 downto 0));
end INSTRR_REG;
architecture rtl of INSTRR_REG is 
type instructions is array(0 to 5) of std_logic_vector(31 downto 0);

begin
	process(instr_reg_cs) 
		variable temp_instr_reg_pc : std_logic_vector(15 downto 0);
		variable temp_data : std_logic_vector(31 downto 0);
		variable  memory: instructions :=(("01101000100000000000000000000000"),
				("00111010000111010000000000000000"),
				("01101000100000000000000000000000"),
				("01111000100000000000000000000000"),
				("00010000000000000000000000000000"),
				("10001000000000000000000000000000"));--???????
	begin
		temp_instr_reg_pc := instr_reg_pc;
		if (instr_reg_cs = '1') then
			temp_data := memory(conv_integer(temp_instr_reg_pc));
			instr_reg_q <= temp_data;
		end if;
	end process;
end rtl;
