library IEEE;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity contrla is
port( clock : in std_logic;
	reset : in std_logic
);
End contrla;

architecture rt1 of contrla is
constant alupass : std_logic_vector(3 downto 0) := "0000";
constant plus : std_logic_vector(3 downto 0) := "0001";
constant alusub : std_logic_vector(3 downto 0) := "0010";
constant zero : std_logic_vector(3 downto 0) := "0011";
constant cryplus : std_logic_vector(3 downto 0) := "0100";

constant shftpass : std_logic_vector(2 downto 0) := "000";
constant sftl : std_logic_vector(2 downto 0) := "001";
constant sftr : std_logic_vector(2 downto 0) := "010";
constant rotl : std_logic_vector(2 downto 0) := "011";
constant rotr : std_logic_vector(2 downto 0) := "100";
--------------------------??-------------------------------
type states is ( 
	reset1,
	fetchinstr,
	execute, 
	nop, 
	load2, load3, 
	store2, store3, store4, store5,
	incPC,incPC2,
	loadI2, loadI3, 
	loadreg2,loadreg3,loadreg4,
	loadsixt2,
	add2, add3, add4,add5,add6,add7,--
	adc2,adc3,adc4,adc5,--
	sub2,sub3,sub4,sub5,sub6,sub7,--
	jmpr,jmpr2,--
	jmp2,jmp3,jmp4,jmp5,jmp6,--
	push2,push3,push4,
	pop2,pop3,
	call2,call3,call4,call5,call6,call7,
	ret2,ret3,ret4,ret5,ret6,ret7,
	memery,
	rewrite,
	sfr2,sfr3,sfr4
	);
---------------------------------------------------------------
component  REG_AR8  is
	port( reg_in_data : in std_logic_vector(15 downto 0);
		regSel : in std_logic_vector(1 downto 0);
		reg_cs : in std_logic;
		reg_wr : in std_logic;
		reg_q : out std_logic_vector(15 downto 0));
end component;
component  ALU_V  is
	port( alu_cs : in std_logic;
		alu_a,alu_b : in std_logic_vector(15 downto 0);
		alu_Sel : in std_logic_vector(3 downto 0);
		alu_c : out std_logic_vector(15 downto 0);
		zf : out std_logic);
end component;
component MEM_AR8 is
port( mem_in_data : in std_logic_vector(15 downto 0);
	mem_addr : in std_logic_vector(15 downto 0);
	mem_enable : in std_logic;
    	mem_wr : in std_logic;
	mem_out_data : out std_logic_vector(15 downto 0));
end component;

component SFT4 is
	port(sft_in_data :in std_logic_vector(15 downto 0);
		shiftSel :in std_logic_vector(2 downto 0);
		sft_cs : in std_logic;
		sft_out_data : out std_logic_vector(15 downto 0));
end component;
component INSTRR_REG is
port(instr_reg_pc : in std_logic_vector(15 downto 0);
	instr_reg_cs : in std_logic;
	instr_reg_q : out std_logic_vector(31 downto 0));
end component;
component STACK is
port(stack_in_data : in std_logic_vector(15 downto 0);
	stack_enable : in std_logic;
    stack_wr : in std_logic;
	stack_out_data : out std_logic_vector(15 downto 0));
end component;

signal current_state : states := fetchinstr;
signal next_state : states;
signal instrReg : std_logic_vector(31 downto 0);--??
signal PC : std_logic_vector(15 downto 0);
signal regSel : std_logic_vector(1 downto 0);
signal regWr : std_logic;
signal add_data1 : std_logic_vector(15 downto 0);
signal add_data2 : std_logic_vector(15 downto 0);
signal add_data3 : std_logic_vector(15 downto 0);
signal add_data4 : std_logic_vector(15 downto 0);
signal reg_in_data : std_logic_vector(15 downto 0);
signal reg_cs : std_logic;
signal reg_wr : std_logic;
signal reg_q :  std_logic_vector(15 downto 0);
signal alu_a,alu_b : std_logic_vector(15 downto 0);
signal alu_Sel : std_logic_vector(3 downto 0);
signal alu_c : std_logic_vector(15 downto 0);
signal alu_cs :std_logic;
signal ZF : std_logic;
signal rew_enable : std_logic;
signal rew_regaddr : std_logic_vector(1 downto 0);
signal rew_data : std_logic_vector(15 downto 0);
signal mem_enable : std_logic;
signal mem_addr : std_logic_vector(15 downto 0);
signal mem_wr : std_logic;
signal mem_in_data : std_logic_vector(15 downto 0);
signal mem_out_data : std_logic_vector(15 downto 0);
signal sft_in_data : std_logic_vector(15 downto 0);
signal shiftSel : std_logic_vector(2 downto 0);
signal sft_cs : std_logic;
signal sft_out_data : std_logic_vector(15 downto 0);
signal instr_reg_pc : std_logic_vector(15 downto 0);
signal instr_reg_cs : std_logic;
signal instr_reg_q : std_logic_vector(31 downto 0);
signal stack_in_data : std_logic_vector(15 downto 0);
signal stack_enable : std_logic;
signal stack_wr : std_logic;
signal stack_out_data : std_logic_vector(15 downto 0);
signal idata : std_logic_vector(15 downto 0);
--signal temp : std_logic_vector(1 downto 0);
--PC <= "0000000000000000";
begin

reg: REG_AR8 port map(reg_in_data,regSel,reg_cs,reg_wr,reg_q);
alu: ALU_V port map(alu_cs,alu_a,alu_b,alu_Sel,alu_c,zf);
mem: MEM_AR8 port map(mem_in_data,mem_addr,mem_enable,mem_wr,mem_out_data);
sft: SFT4 port map(sft_in_data,shiftSel,sft_cs,sft_out_data);
instructionreg: INSTRR_REG port map(instr_reg_pc,instr_reg_cs,instr_reg_q);

com:process(clock,reset,current_state)
	variable add_data11 : std_logic_vector(15 downto 0);
	variable add_data22 : std_logic_vector(15 downto 0);
	variable temp_pc : std_logic_vector(15 downto 0);
	begin
	--shiftSel <= shftpass; 
	--alu_Sel <= alupass;
	--regSel <= "00";
	
		case current_state is
			when reset1 => PC <= "0000000000000000"; next_state <=fetchinstr;
			when fetchinstr => instr_reg_cs <= '1'; 
				temp_pc := PC;
				instr_reg_pc <= PC; 
				instrReg <= instr_reg_q;
				next_state <= execute;
			when execute =>
			instr_reg_cs <= '0';
			case instrReg(31 downto 27) is
					when "00000" => mem_enable <= '0';
								rew_enable <= '0';
								next_state <= jmpr;
					when "00001" => if zf = '1' then
								mem_enable <= '0';
								rew_enable <= '0';
								next_state <= jmp2;
							else
								next_state <= incPc;
							end if;
					when "00010" => if zf = '0' then
								mem_enable <= '0';
								rew_enable <= '0';
								next_state <= jmp2;
							else
								next_state <= incPc;
							end if;
									
					when "00011" => next_state <= push2;
					when "00100" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '0';
							next_state <= pop2;
					when "00101" => next_state <= call2;
					when "00110" => next_state <= ret2;
					when "00111" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '0';
							next_state <= loadI2;
					when "01000" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '0';
							next_state <= load2;
					when "01001" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '1';
							mem_wr <= '0';
							next_state <= loadsixt2;
					when "01010" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '1';
							mem_wr <= '0';
							next_state <= loadreg2;
					when "01011" => rew_enable <= '0';
							mem_enable <= '1';
							mem_wr <= '0';				
							next_state <= store2;
					when "01100" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '0';
							next_state <= sfr2;
					when "01101" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '0';
							next_state <= add2;
					when "01110" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '0';
							next_state <= adc2;
					when "01111" => rew_enable <= '1';
							rew_regaddr <= instrReg(26 downto 25);
							mem_enable <= '0';
							next_state <= sub2;
					when "10000" => mem_enable <= '0';
							rew_enable <= '0';
							next_state <= incPc;
					when "10001" => next_state <= nop;--???
					when others =>  reg_cs <= '0'; stack_enable <= '0'; alu_cs <= '0'; instr_reg_cs <= '0';
							next_state <= incPc;
			end case;
			when incPC => reg_cs <= '0'; stack_enable <= '0'; alu_cs <= '0'; instr_reg_cs <= '0';
				temp_pc := PC + 1;
				next_state <= incPC2;
			when incPC2 => PC <= temp_pc;	
			     next_state <= fetchinstr; 
			when jmpr => 
			temp_pc := instrReg(26 downto 11);
			when jmpr2 =>
			PC <= temp_pc; next_state <= fetchinstr ;
			when jmp2 => regSel <= instrReg(26 downto 25); reg_wr <= '0';reg_cs <= '1'; add_data11 := reg_q; next_state <= jmp3;
			when jmp3 => add_data1 <= add_data11; reg_cs <= '0'; next_state <= jmp4;
			when jmp4 => regSel <= instrReg(24 downto 23); reg_wr <= '0';reg_cs <= '1'; add_data22 := reg_q; next_state <= jmp5;
			when jmp5 => add_data2 <= add_data22; reg_cs <= '0'; next_state <= jmp6;
			when jmp6 => PC <= (add_data1(7 downto 0) & add_data2(7 downto 0)); next_state <= fetchinstr ;
			when push2 => regSel <= instrReg(26 downto 25); reg_wr <= '0';reg_cs <= '1'; add_data1 <= reg_q; next_state <= push3;
			when push3 => reg_cs <= '0'; stack_enable <= '1'; stack_wr <= '1'; stack_in_data <= add_data1; next_state <= push4;
			when push4 => stack_enable <= '0';next_state <= incPc;
			when pop2 => stack_enable <= '1'; stack_wr <= '0'; add_data1 <= stack_out_data; next_state <= pop3;
			when pop3 => mem_in_data <= add_data1; reg_cs <= '0'; stack_enable <= '0'; next_state <= memery;
			when call2 => regSel <= "00"; reg_wr <= '0';reg_cs <= '1'; stack_enable <= '0'; add_data1 <= reg_q; -------
				 stack_enable <= '1'; stack_wr <= '1'; stack_in_data <= add_data1;
				 next_state <= call3;
			when call3 => regSel <= "01"; reg_wr <= '0';reg_cs <= '1'; add_data2 <= reg_q; 
				 stack_enable <= '1'; stack_wr <= '1'; stack_in_data <= add_data2;
				 next_state <= call4;
			when call4 => regSel <= "10"; reg_wr <= '0';reg_cs <= '1'; add_data3 <= reg_q; 
				 stack_enable <= '1'; stack_wr <= '1'; stack_in_data <= add_data3;
				 next_state <= call5;
			when call5 => regSel <= "11"; reg_wr <= '0';reg_cs <= '1'; add_data4 <= reg_q; 
				 stack_enable <= '1'; stack_wr <= '1'; stack_in_data <= add_data4;
				 next_state <= call6;
			when call6 => stack_enable <= '1'; stack_wr <= '1'; stack_in_data <= PC + 1; next_state <= call7;
			when call7 => reg_cs <= '0'; stack_enable <= '0'; PC <= (add_data1(7 downto 0) & add_data2(7 downto 0)); next_state <= fetchinstr;
			when ret2 => stack_enable <= '1'; stack_wr <= '0'; PC <= stack_out_data;next_state <= ret3;
			when ret3 => stack_enable <= '1'; stack_wr <= '0'; add_data4 <= stack_out_data;  
				 regSel <= "11"; reg_wr <= '1';reg_cs <= '1'; reg_in_data <= add_data4; 
				 next_state <= ret4;
			when ret4 => stack_enable <= '1'; stack_wr <= '0'; add_data3 <= stack_out_data;  
				 regSel <= "10"; reg_wr <= '1';reg_cs <= '1'; reg_in_data <= add_data3;
				 next_state <= ret5;
			when ret5 => stack_enable <= '1'; stack_wr <= '0'; add_data2 <= stack_out_data;  
				 regSel <= "01"; reg_wr <= '1';reg_cs <= '1'; reg_in_data <= add_data2;
				 next_state <= ret6;
			when ret6 => stack_enable <= '1'; stack_wr <= '0'; add_data1 <= stack_out_data;  
				 regSel <= "00"; reg_wr <= '1';reg_cs <= '1'; reg_in_data <= add_data1;
				 next_state <= ret7;
			when ret7 => stack_enable <= '0'; reg_cs <= '0'; next_state <= fetchinstr;
			when add2 => regSel <= instrReg(26 downto 25); reg_wr <= '0';reg_cs <= '1'; add_data11 := reg_q; next_state <= add3;
			when add3 => add_data1 <= add_data11; reg_cs <= '0'; next_state <= add4;
			when add4 => regSel <= instrReg(24 downto 23); reg_wr <= '0';reg_cs <= '1'; add_data22 := reg_q; next_state <= add5;
			when add5 => add_data2 <= add_data22; reg_cs <= '0'; next_state <= add6;
			when add6 => alu_Sel <= plus; alu_cs <= '1'; alu_a <=add_data1; alu_b <= add_data2; mem_in_data <= alu_c; next_state <= add7;
			when add7 => alu_cs <= '0'; next_state <= memery;
			when memery => 
				if mem_enable = '0' then 
					mem_out_data <= mem_in_data;
					next_state <= rewrite;
				else 
					next_state <= rewrite;
				end if;
			when rewrite => 
				if rew_enable = '0' then 
					next_state <= incPC;
				else
					regSel <= rew_regaddr; reg_wr <= '1';reg_cs <= '1'; reg_in_data <= mem_out_data; next_state <= incPC;
				end if;
			when sub2 => regSel <= instrReg(26 downto 25); reg_wr <= '0';reg_cs <= '1'; add_data11 := reg_q; next_state <= sub3;
			when sub3 => add_data1 <= add_data11; reg_cs <= '0'; next_state <= sub4;
			when sub4 => regSel <= instrReg(24 downto 23);reg_wr <= '0';reg_cs <= '1'; add_data22 := reg_q; next_state <= sub5;
			when sub5 => add_data2 <= add_data2; reg_cs <= '0'; next_state <= sub6;
			when sub6 => alu_Sel <= alusub; alu_a <=add_data1; alu_b <= add_data2; alu_cs <= '1'; mem_in_data <= alu_c; next_state <= sub7;
			when sub7 => alu_cs <= '0';next_state <= memery;
			when adc2 => regSel <= instrReg(26 downto 25); reg_wr <= '0';reg_cs <= '1'; add_data1 <= reg_q; next_state <= adc3;
			when adc3 => regSel <= instrReg(24 downto 23);reg_wr <= '0';reg_cs <= '1'; add_data2 <= reg_q; next_state <= adc4;
			when adc4 => alu_cs <= '1'; alu_Sel <= cryplus; alu_a <=add_data1; alu_b <= add_data2;  mem_in_data <= alu_c; next_state <= adc5;
			when adc5 => reg_cs <= '0'; alu_cs <= '0'; next_state <= memery;
			when sfr2 => regSel <= instrReg(26 downto 25); reg_wr <= '0';reg_cs <= '1'; add_data1 <= reg_q; next_state <= sfr3;
			when sfr3 => shiftSel  <= sftr; sft_cs <= '1'; sft_in_data <=add_data1; mem_in_data <= sft_out_data; next_state <= sfr4;
			when sfr4 => reg_cs <= '0'; sft_cs <= '0'; next_state <= memery;
			when load2 => regSel <= instrReg(24 downto 23); reg_wr <= '0';reg_cs <= '1'; add_data1 <= reg_q; next_state <= load3;
			when load3 => mem_in_data <= add_data1; reg_cs <= '0';next_state <= memery;
			when loadI2 => regSel <= instrReg(24 downto 23); reg_wr <= '0';reg_cs <= '1'; 
			 	idata <= ("00000000" & instrReg(22 downto 15));
			 	next_state <= loadI3;
			when loadI3 => mem_in_data <= idata; reg_cs <= '0'; next_state <= memery;	
			when loadsixt2 => mem_addr <= instrReg(22 downto 7); next_state <= memery;
			when loadreg2 => regSel <= instrReg(24 downto 23); reg_wr <= '0';reg_cs <= '1'; add_data1 <= reg_q; next_state <= loadreg3;
			when loadreg3 => regSel <= instrReg(22 downto 21); reg_wr <= '0';reg_cs <= '1'; add_data2 <= reg_q; next_state <= loadreg4;
			when loadreg4 => mem_addr <= (add_data1(7 downto 0) & add_data2(7 downto 0)); reg_cs <= '0'; next_state <= memery;
			when store2 => regSel <= instrReg(24 downto 23); reg_wr <= '0';reg_cs <= '1'; add_data1 <= reg_q; next_state <= store3;
			when store3 => regSel <= instrReg(22 downto 21); reg_wr <= '0';reg_cs <= '1'; add_data2 <= reg_q; next_state <= store4;
			when store4 => regSel <= instrReg(26 downto 25); reg_wr <= '0';reg_cs <= '1'; add_data3 <= reg_q; next_state <= store5;
			when store5 => mem_addr <= (add_data1(7 downto 0) & add_data2(7 downto 0)); reg_cs <= '0'; mem_in_data <= add_data3; next_state <= memery;
			when nop => next_state <= incPc;

		end case;
	end process;
CLOCK_REG: process(clock,reset) begin
		if reset = '1' then
			current_state <= reset1;
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;			
end rt1;