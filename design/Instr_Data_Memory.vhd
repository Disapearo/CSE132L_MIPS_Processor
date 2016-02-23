LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mem IS

	PORT (  ref_clk, rst : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		we, IorD : IN STD_LOGIC;
		dsize : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		wd : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rd : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));

END mem;

ARCHITECTURE arch OF mem IS

	TYPE ramtype IS ARRAY (63 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem : ramtype := (OTHERS => (OTHERS => '0'));
	TYPE buff IS ARRAY ((16*32)-1 DOWNTO 0) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL dataMemory : buff := (OTHERS => (OTHERS => '0'));

BEGIN

	PROCESS (ref_clk, addr)
		VARIABLE temp_dataO : STD_LOGIC_VECTOR (31 DOWNTO 0);
		VARIABLE loadInByte : STD_LOGIC_VECTOR (7 DOWNTO 0);
		VARIABLE loadInHalfword : STD_LOGIC_VECTOR (15 DOWNTO 0);
	BEGIN

		IF (IorD = '0') THEN 		-- Instruction
			mem(0)	<= X"20020005";
			mem(1)	<= X"2003000c";
			mem(2)	<= X"2067fff7";
			mem(3)	<= X"00e22025";
			mem(4)	<= X"00642824";
			mem(5)	<= X"00a42820";
			mem(6)	<= X"10a7000a";
			mem(7)	<= X"0064202a";
			mem(8)	<= X"10800001";
			mem(9)	<= X"20050000";
			mem(10) <= X"00e2202a";
			mem(11) <= X"00853820";
			mem(12) <= X"00e23822";
			mem(13) <= X"ac670044";
			mem(14) <= X"8c020050";
			mem(15) <= X"08000011";
			mem(16) <= X"20020001";
			mem(17) <= X"ac020054";
	
			rd <= mem(TO_INTEGER(unsigned(addr)));
		ELSE				-- Data
			IF (ref_clk'EVENT AND ref_clk = '1') THEN											-- SW, SB, SH
				IF (we = '1') THEN
					IF (dsize (1 DOWNTO 0) = "00") THEN
						dataMemory(to_integer(unsigned(addr))) (7 DOWNTO 0) <= wd (7 DOWNTO 0);
					ELSIF (dsize (1 DOWNTO 0) = "01") THEN
						dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 0) <= wd (15 DOWNTO 0);
					ELSIF (dsize (1 DOWNTO 0) = "11") THEN
						dataMemory(to_integer(unsigned(addr))) <= wd;
					END IF;
				END IF;
			--ELSIF (falling_edge(ref_clk) AND (re = '1')) THEN
			END IF;
			IF (we = '0') THEN											-- LOAD
	--			IF (dsize = "011") THEN										-- LW only
	--			        rd <= dataMemory(to_integer(unsigned(addr)));
	--			ELSE
	--				rd <= (OTHERS => '-');
	--			END IF;
				IF (dsize(2) = '0') THEN									-- NOT LBU or LHU
					IF (dsize (1 DOWNTO 0) = "00") THEN							-- LB
						temp_dataO (31 DOWNTO 8) := "000000000000000000000000";
						rd (31 DOWNTO 8) <= temp_dataO (31 DOWNTO 8);
						IF (addr(1 DOWNTO 0) = "00") THEN
							loadInByte := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (7 DOWNTO 0)));
							rd (7 DOWNTO 0) <= loadInByte;
						ELSIF (addr(1 DOWNTO 0) = "01") THEN
							loadInByte := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 8)));
							rd (7 DOWNTO 0) <= loadInByte;
						ELSIF (addr(1 DOWNTO 0) = "10") THEN
							loadInByte := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (23 DOWNTO 16)));
							rd (7 DOWNTO 0) <= loadInByte;
						ELSE
							loadInByte := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (31 DOWNTO 24)));
							rd (7 DOWNTO 0) <= loadInByte;
						END IF;
					ELSIF (dsize (1 DOWNTO 0) = "01") THEN							-- LH
						temp_dataO (31 DOWNTO 16) := "0000000000000000";
						rd (31 DOWNTO 15) <= temp_dataO (31 DOWNTO 15);
						IF (addr(0) = '0') THEN
							loadInHalfWord := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (31 DOWNTO 16)));
							rd (15 DOWNTO 0) <= loadInHalfWord;
						ELSE
							loadInHalfWord := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 0)));
							rd (15 DOWNTO 0) <= loadInHalfWord;
						END IF;
					ELSIF (dsize (1 DOWNTO 0) = "11") THEN							-- LW
					        rd <= dataMemory(to_integer(unsigned(addr)));
					END IF;
				ELSE												-- LBU or LHU
					IF (dsize (1 DOWNTO 0) = "00") THEN							-- LBU
						temp_dataO (31 DOWNTO 8) := "000000000000000000000000";
						rd (31 DOWNTO 8) <= temp_dataO (31 DOWNTO 8);
						IF (addr(1 DOWNTO 0) = "00") THEN
							loadInByte := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (7 DOWNTO 0)));
							rd (7 DOWNTO 0) <= loadInByte;
						ELSIF (addr(1 DOWNTO 0) = "01") THEN
							loadInByte := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 8)));
							rd (7 DOWNTO 0) <= loadInByte;
						ELSIF (addr(1 DOWNTO 0) = "10") THEN
							loadInByte := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (23 DOWNTO 16)));
							rd (7 DOWNTO 0) <= loadInByte;
						ELSE
							loadInByte := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (31 DOWNTO 24)));
							rd (7 DOWNTO 0) <= loadInByte;
						END IF;
					ELSIF (dsize (1 DOWNTO 0) = "01") THEN							-- LHU
						temp_dataO (31 DOWNTO 16) := "0000000000000000";
						rd (31 DOWNTO 15) <= temp_dataO (31 DOWNTO 15);
						IF (addr(0) = '0') THEN
							loadInHalfWord := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (31 DOWNTO 16)));
							rd (15 DOWNTO 0) <= loadInHalfWord;
						ELSE
							loadInHalfWord := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 0)));
							rd (15 DOWNTO 0) <= loadInHalfWord;
						END IF;
					END IF;
				END IF;	
			END IF;

		END IF;

	END PROCESS;
END arch;