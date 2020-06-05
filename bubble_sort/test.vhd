library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test is end entity;

architecture beh of test is
  
   constant LEN : integer := 10;
	signal clk, rst, we : std_logic;      
	signal din    : std_logic_vector(31 downto 0);

begin
	
	DUT : entity work.bubble_sort 
	generic map ( LEN => LEN )
	port map (clk => clk, rst => rst, we => we, din => din);
  
	process is 
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;
	
	process is 
	begin 
		rst <= '1';
		wait for 50 ns;
		rst <= '0';
		wait;
	end process;

	process is 
	variable inp: integer := LEN*LEN+1;
	variable c: integer := 1;
	begin		
		we <= '0';
		wait until clk'event and clk = '1';
		if rst = '1' then 
			wait until rst = '0';
		end if;
		we <= '1';
		for i in 0 to LEN-1 loop
		   inp := inp - 1;
			din <= std_logic_vector(to_unsigned(inp, din'length));
			wait until clk'event and clk = '1';
		end loop;
		inp := LEN+c;
		c := c + 1;
		wait until clk'event and clk = '1';
		we <= '0';
		wait for 3 us;
	end process; 
	
end beh;	
	