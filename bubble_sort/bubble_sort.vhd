library ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bubble_sort IS
	generic (
		LEN : integer := 10
	); 
   PORT
   (
		clk, rst, we : in std_logic;
		din : in std_logic_vector(31 downto 0);
		dout : out std_logic_vector(31 downto 0)
   );
end bubble_sort;

architecture behavioral of bubble_sort is

	component memory
	  generic (
		   LEN : integer := 10
	  ); 
	  port (
			clk, we_a, we_b : in std_logic;     
			addr_a, addr_b: in natural range 0 to LEN-1;  
			din_a, din_b  : in std_logic_vector(31 downto 0);   
			dout_a, dout_b  : out std_logic_vector(31 downto 0)
	  );	
	end component memory ;
	
	signal wea, web : std_logic;     
   signal addra, addrb: natural range 0 to LEN-1;  
	signal dina, dinb  : std_logic_vector(31 downto 0);   
	signal douta, doutb  : std_logic_vector(31 downto 0);
	signal re : std_logic := '0';
	signal bubble_flag: natural range 0 to 4 := 0;
begin

memory_component : memory 
	generic map ( 
		LEN => LEN 
	)
	port map (
		clk => clk, 
		we_a => wea, we_b => web, 
		addr_a => addra, addr_b => addrb, 
		din_a => dina, din_b => dinb, 
		dout_a => douta, dout_b => doutb
	);

process (clk, rst)

variable i, j : integer;
variable tmp1, tmp2, tmp3, tmp4 : std_logic_vector(31 downto 0);

begin 
	if clk'event and clk = '1'then

		if rst='1' then
			wea <= '0';
			web <= '0';
			addra <= 0;
			addrb <= 0;
			dina <= (others => '0');
			dinb <= (others => '0');
			
			dout <= (others => '0');
			
			i := 0;
			j := 0;
			tmp1 := (others => '0');
			tmp2 := (others => '0');
			tmp3 := (others => '0');
			tmp4 := (others => '0');
		end if;
		
		if we = '1' and rst = '0' and bubble_flag = 0 and re = '0' then
			wea <= '1';
			if addra = LEN - 2 then
				dina <= din;
				addra <= LEN - 1;
			elsif addra = LEN - 1 then 
				bubble_flag <= 1;
				i := 0;
				j := 0;
			elsif addra < LEN - 2 then
				dina <= din;
				addra <= i;
				i := i + 1;
			end if;
		else 
			wea <= '0';
			web <= '0';
		end if;
		
		if bubble_flag = 1 then	
			addra <= j;
			addrb <= j + 1;
			if (j = LEN - i - 2) then
				i := i + 1;
				j := 0;
			else
				j := j + 1;
			end if;
			bubble_flag <= 2;
		elsif bubble_flag = 2 then	
			if (i = LEN - 1 and j = 1) then
				i := 0;
				bubble_flag <= 0;
				re <= '1';
			else 
				bubble_flag <= 3;
			end if;
		elsif bubble_flag = 3 then	
			tmp1 := douta;
			tmp2 := doutb;
			if (tmp1 > tmp2) then
				tmp3 := tmp2;
				tmp4 := tmp1;
			else 
				tmp3 := tmp1;
				tmp4 := tmp2;
			end if;
			bubble_flag <= 4;
		elsif bubble_flag = 4 then
			wea <= '1';
			web <= '1';
			dina <= tmp3;
			dinb <= tmp4;
			bubble_flag <= 1;
		end if;		
				
		if re = '1' then
			i := i + 1;
			if i < LEN then
				addra <= i;
			elsif i = LEN + 2 then
				re <= '0';
				addra <= 0;
				addrb <= 0;
				i := 0;
				j := 0;
			end if;
			if i > 1 then
				dout <= douta;
			end if;
		end if;
	
	end if;
end process;
	
end behavioral;