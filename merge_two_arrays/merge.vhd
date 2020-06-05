library ieee;
use ieee.std_logic_1164.all;

package memory is
	 constant N : integer := 32;
	 constant M : integer := 4;
	 constant P : integer := 4;
	 constant T : integer := 2*M / P;
	 
	 subtype array_element is std_logic_vector (N - 1 downto 0);
	 
	 type in_merge is array (0 to M - 1) of array_element;
	 type block_merge is array (0 to T - 1) of in_merge;
	 type out_merge is array (0 to 2*M - 1) of array_element;
	 type result_merge is array (0 to T - 1) of out_merge;
	 
	 type ind_array is array (0 to T - 1) of integer;
end memory;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memory.all;

entity merge is 
	generic ( 
		N : integer := N;
		M : integer := M;
		P : integer := P;
		T : integer := T
		);
	port (	
		clk : in std_logic;
		
		in_tready_a : out std_logic;
		in_tvalid_a : in std_logic;
		in_tdata_a : in in_merge;
		in_tlast_a : in std_logic;
		
		in_tready_b : out std_logic;
		in_tvalid_b : in std_logic;
		in_tdata_b : in in_merge;
		in_tlast_b : in std_logic;
		
		out_tready : in std_logic;
		out_tvalid : out std_logic;
		out_tdata : out out_merge
	);
	
	
end entity;

architecture rtl of merge is 

shared variable aels, bels : block_merge;
shared variable rels : result_merge;
shared variable iind, jind, kind: ind_array := (others => 0);

procedure submerge (q : integer) is 
		variable i, j, k : integer;
		variable ael, bel : array_element;
	begin
		for h in 0 to P - 1 loop
			i := iind(q); j := jind(q); k := kind(q);
			if k /= 2*M then
				if i /= M and j /= M then
					ael := aels(q)(i);
					bel := bels(q)(j);
					if ael < bel 
					then
						rels(q)(k) := ael;
						iind(q) := i + 1;
					else
						rels(q)(k) := bel;
						jind(q) := j + 1;
					end if;
					kind(q) := k + 1;
				elsif i = M and j /= M then
					bel := bels(q)(j);
					rels(q)(k) := bel;
					jind(q) := j + 1;
					kind(q) := k + 1;
				elsif j = M and i /= M then
					ael := aels(q)(i);
					rels(q)(k) := ael;
					iind(q) := i + 1;
					kind(q) := k + 1;
				end if;
			end if;
		end loop;
end submerge;
	
begin	

	in_tready_a <= out_tready;
	in_tready_b <= out_tready;
			
	process (clk) is
		constant in_zero : in_merge := (others => (others => '0'));
		constant out_zero : out_merge := (others => (others => '0')); 
		variable counter : integer := 0;
		variable flag : boolean;
	begin 
		if rising_edge(clk) then 
			if out_tready = '1' then
			
				flag := in_tvalid_a = '1' and in_tvalid_b = '1' and in_tlast_a = '1' and in_tlast_b = '1';
				
				if flag then 
					aels := in_tdata_a & aels(0 to T - 2);
					bels := in_tdata_b & bels(0 to T - 2);
				end if;
				rels := out_zero & rels(0 to T - 2);
				
				iind := 0 & iind(0 to T - 2);
				jind := 0 & jind(0 to T - 2);
				kind := 0 & kind(0 to T - 2);		
				
				for q in 0 to T - 1 loop
					submerge(q);
				end loop;
				
				if kind(T - 1) = 2*M and flag then 
					out_tvalid <= '1';
					out_tdata <= rels(T - 1);
				else 
					out_tvalid <= '0';
				end if;
			else 
				out_tvalid <= '0';
			end if;
		end if;
	end process;	
end rtl;