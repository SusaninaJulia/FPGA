library ieee;
use ieee.std_logic_1164.all;

entity multiplexer is 
port(
      
		input_vector: in std_logic_vector (9 downto 0);
      exit_number : in std_logic_vector (1 downto 0);
		
      out_0   : out std_logic_vector (9 downto 0);
		out_1   : out std_logic_vector (9 downto 0);
		out_2   : out std_logic_vector (9 downto 0);
	   out_err : out std_logic_vector (0 downto 0)
);
end multiplexer;

architecture rtl of multiplexer is
begin
process (input_vector, exit_number) is
	
	constant ZERO : std_logic_vector (9 downto 0):= (others => '0');
	begin	
		if exit_number = B"00" then out_0 <= input_vector; else out_0 <= ZERO;   end if;
		if exit_number = B"01" then out_1 <= input_vector; else out_1 <= ZERO;   end if;
		if exit_number = B"10" then out_2 <= input_vector; else out_2 <= ZERO;   end if;
		if exit_number = B"11" then out_err <= B"1";       else out_err <= B"0"; end if;
		
end process;
end rtl;	