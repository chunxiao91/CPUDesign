library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
entity SFT4 is
port( sft_in_data :in std_logic_vector(15 downto 0);
	shiftSel :in std_logic_vector(2 downto 0);
	sft_cs : in std_logic;
	sft_out_data : out std_logic_vector(15 downto 0));
end SFT4;
architecture rt1 of SFT4 is
constant shftpass : std_logic_vector(2 downto 0) := "000";
constant sftl : std_logic_vector(2 downto 0) := "001";
constant sftr : std_logic_vector(2 downto 0) := "010";
constant rotl : std_logic_vector(2 downto 0) := "011";
constant rotr : std_logic_vector(2 downto 0) := "100";
begin
	process(sft_in_data,shiftSel,sft_cs) 

	begin
		if (sft_cs = '1') then
			case shiftSel is
				when shftpass => sft_out_data <= sft_in_data;
				when sftl =>sft_out_data <= sft_in_data(14 downto 0) & '0';--??
				when sftr => sft_out_data <= '0' & sft_in_data(14 downto 0);--??
				when rotl => sft_out_data <= sft_in_data(14 downto 0) & sft_in_data(15);--????
				when rotr => sft_out_data <= sft_in_data(0) & sft_in_data(14 downto 0);--????
				when others => sft_out_data <= "0000000000000000";
		end case;
	end if;
end process;
end rt1;
