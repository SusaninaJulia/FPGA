library ieee;
use ieee.std_logic_1164.all;

package p is
	constant TEST_NUM : integer := 11;
	type test_starts is array (0 to TEST_NUM - 1) of integer;
end p;

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
use work.memory.all;
use work.p.all; 

entity test is 
end entity; 

architecture beh of test is 

	signal clk : std_logic := '0';

	signal gen_flag, rec_flag, check_result : std_logic;
	signal cnt_g, cnt_r : integer := 0; 

	signal in_tvalid_a, in_tlast_a, in_tready_a : std_logic;
	signal in_tvalid_b, in_tlast_b, in_tready_b : std_logic;
	signal out_tready, out_tvalid : std_logic;
	signal in_tdata_a, in_tdata_b : in_merge;
	
	
	signal ress : result_merge;
	
	signal out_tdata : out_merge;
	
	shared variable i : integer := 0;
	
	function generate_data (start : integer) return in_merge is
		variable data : in_merge := (others => (others => '0'));
		variable j : integer := 0;
	begin
		for j in 0 to M - 1 loop
			data(j) := std_logic_vector(to_unsigned(start + j, N));
		end loop;
		return data;
	end function;
	
	function simple_merge (arr_a : in_merge; arr_b : in_merge) return out_merge is
		variable i, j, k : integer;
		variable ael, bel : array_element;
		variable res : out_merge;
	begin
		i := 0; j := 0; k := 0;
		for h in 0 to 2*M - 1 loop
			if i /= M and j /= M then
				ael := arr_a(i);
				bel := arr_b(j);
				if ael < bel 
				then
					res(k) := ael;
					i := i + 1;
				else
					res(k) := bel;
					j := j + 1;
				end if;
				k := k + 1;
			elsif i = M and j /= M then
				bel := arr_b(j);
				res(k) := bel;
				j := j + 1;
				k := k + 1;
			elsif j = M and i /= M then
				ael := arr_a(i);
				res(k) := ael;
				i := i + 1;
				k := k + 1;
			end if;
		end loop;
		return res;
	end function;
	

begin

	DUT : entity work.merge 
	generic map (N => N, 
					 M => M)
	port map    (
					 clk => clk , 
				    in_tvalid_a => in_tvalid_a, 
					 in_tdata_a => in_tdata_a,
					 in_tlast_a => in_tlast_a,
					 in_tready_a => in_tready_a,
					 
					 in_tvalid_b => in_tvalid_b,
					 in_tdata_b => in_tdata_b, 
					 in_tlast_b => in_tlast_b,
					 in_tready_b => in_tready_b,
					 
					 out_tready => out_tready, 
					 out_tvalid => out_tvalid,
					 out_tdata => out_tdata
					 );

  process is 		
  begin
    while true loop 
      clk <= '0'; 
      wait for 4 ns;
      clk <= '1' ;
      wait for 4 ns; 
    end loop; 
  end process; 
	
	process (clk) is 
	begin
		if rising_edge(clk) then
			if rec_flag = '1' then
				ress <= simple_merge(in_tdata_a, in_tdata_b) & ress(0 to T - 2);
			end if;
		end if;
	end process;
	
	--  GENERATOR : entity work.generator 
	--  port map (
	--    clk => clk, gen_flag => gen_flag,
	--	   in_tready_a => in_tready_a, in_tready_b => in_tready_b,
	--	 
	--	   in_tvalid_a => in_tvalid_a, in_tdata_a => in_tdata_a,
	--	   in_tvalid_b => in_tvalid_b, in_tdata_b => in_tdata_b
	--  ); 
	
		
	gen_flag <= '1'  when cnt_g /= 7 else '0';
 
	process (clk) is 
		constant out_zero : out_merge := (others => (others => '0')); 
		variable tels : test_starts := (12, 4, 7, 0, 13, 35, 3, 4, 22, 11, 9);
	begin 
		if rising_edge(clk) then
			if gen_flag = '1'
			then 
				if in_tready_a = '1' and in_tready_b = '1' 
				then
					in_tvalid_a <= '1';
					in_tvalid_b <= '1';
					in_tdata_a <= generate_data(tels(i));
					in_tdata_b <= generate_data(tels(i+1));
					in_tlast_a <= '1';
					in_tlast_b <= '1';
					
					if i = TEST_NUM - 2 
					then i := 0;
					else i := i + 1;
					end if;
					
					cnt_g <= cnt_g + 1;
				end if;
			else
				in_tvalid_a <= '0';
				in_tvalid_b <= '0';
				in_tlast_a <= '0';
				in_tlast_b <= '0';
								
				cnt_g <= 0;
			end if;
		end if;
	end process;
	
	--  RECEIVER : entity work.reciever 
	--  port map ( 
	--    clk => clk, rec_flag => rec_flag, 
	--	   out_tvalid => out_tvalid
	--  ); 

	rec_flag <= '1'  when cnt_r /= 13 else '0';
	out_tready <= rec_flag;
	
	process (clk) is 
	begin 
	 if rising_edge(clk) then
		if rec_flag = '1'
		then 
			cnt_r <= cnt_r + 1;
		else  
			cnt_r <= 0;
		end if;
		
		
		if out_tvalid = '1' and out_tready = '1' 
		then 
			if out_tdata = ress(T - 1)
			then 
				check_result <= '1';
			else 
				check_result <= '0';
			end if;
		end if;
	end if;
	end process;

end beh;