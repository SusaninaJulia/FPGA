library ieee;
use ieee.std_logic_1164.all;

entity test is end entity;

architecture beh of test is
signal input_vector : std_logic_vector(9 downto 0);
signal exit_number: std_logic_vector(1 downto 0);

begin
	DUT : entity work.multiplexer port map (
		input_vector => input_vector, exit_number => exit_number);

	process is
	begin
		input_vector <= B"1111111111";
		exit_number   <= B"00";
		wait for 1 ns;
		
		exit_number   <= B"01";
		wait for 1 ns;
		
		exit_number   <= B"10";
		wait for 1 ns;

		exit_number   <= B"11";
		wait for 1 ns; 
		
	end process;
end beh;	
	