------------------ALU????????--------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity ALU_V is
	port(alu_cs : in std_logic;
		alu_a,alu_b : in std_logic_vector(15 downto 0);
		alu_Sel : in std_logic_vector(3 downto 0);
		alu_c : out std_logic_vector(15 downto 0);
		zf : out std_logic);
end ALU_V;
architecture rt1 of ALU_V is
constant alupass : std_logic_vector(3 downto 0) := "0000";
constant plus : std_logic_vector(3 downto 0) := "0001";
constant alusub : std_logic_vector(3 downto 0) := "0010";
constant zero : std_logic_vector(3 downto 0) := "0011";
constant cryplus : std_logic_vector(3 downto 0) := "0100";
signal temp_sub : std_logic_vector(15 downto 0);
signal sum_t : std_logic_vector(15 downto 0);
signal carry_t : std_logic;
begin
process(alu_a,alu_b,alu_Sel) 
begin
if(alu_cs = '1') then
case alu_Sel is
	when alupass => alu_c <= alu_a;
	when plus => alu_c <= alu_a+alu_b;
	when alusub => temp_sub <= alu_a-alu_b;
					if temp_sub = "0000000000000000" then 
						zf <= '1';
						alu_c <= temp_sub;
					else
						zf <= '0';
						alu_c <= temp_sub;
					end if;
	when zero => alu_c <= "0000000000000000";
	when cryplus => carry_t <= '0';
		for i in 0 to 15 loop
			sum_t(i) <= alu_a(i) xor alu_b(i) xor carry_t;
			carry_t <= (alu_a(i) and alu_b(i)) or (carry_t and (alu_a(i) or alu_b(i)));
		end loop;
		alu_c <= sum_t;
	when others => alu_c <= "0000000000000000";
end case;
end if;
end process;
end rt1;