library ieee;
use ieee.std_logic_1164.all;

entity memory is
	generic (
		LEN : integer := 10
	); 
	port 
	(	
		clk		: in std_logic;
		we_a	   : in std_logic;
		we_b	   : in std_logic;
		addr_a	: in natural range 0 to LEN-1;
		addr_b	: in natural range 0 to LEN-1;
		din_a	   : in std_logic_vector(31 downto 0);
		din_b  	: in std_logic_vector(31 downto 0);
		dout_a	: out std_logic_vector(31 downto 0);
		dout_b	: out std_logic_vector(31 downto 0)
	);
	
end memory;

architecture rtl of memory is
	
	subtype element_type is std_logic_vector(31 downto 0);
	type memory_type is array(LEN-1 downto 0) of element_type;
	shared variable ram : memory_type;

begin

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if (we_a = '1') then
				ram(addr_a) := din_a;
			end if;
			dout_a <= ram(addr_a);
		end if;
	end process;
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if (we_b = '1') then
				ram(addr_b) := din_b;
			end if;
			dout_b <= ram(addr_b);
		end if;
	end process;
end rtl;
