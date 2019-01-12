library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity testbench is

end testbench;

architecture Behavioral of testbench is

component contrla is
port( clock : in std_logic;
	reset : in std_logic
);
End component;


constant clk_period:time:=100 ns;
signal reset:std_logic:='0';
signal clk1: std_logic:='0';

begin
u1: contrla 
port map(
    clock=>clk1,
    reset=>reset
);
--??????
process
begin
clk1<='1';
wait for clk_period/2;
clk1<='0';
wait for clk_period/2;
end process;

--reset????
process
begin
wait for 100ns;
reset<='1';
wait for 100ns;
reset<='0';
wait;
end process;
end Behavioral;