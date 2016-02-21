LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ram IS
--	GENERIC ( N : INTEGER := 32);
	PORT (ref_clk : IN std_logic ;
		we, re : IN std_logic ;
		dsize : IN std_logic_vector (2 DOWNTO 0);
		addr 	: IN std_logic_vector (31 DOWNTO 0);
		dataI 	: IN std_logic_vector (31 DOWNTO 0);
		dataO 	: OUT std_logic_vector (31 DOWNTO 0));
END ram ;

ARCHITECTURE arch OF ram IS

	TYPE buff IS ARRAY ((16*32)-1 DOWNTO 0) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL dataMemory : buff := (OTHERS => (OTHERS => '0'));

BEGIN

	PROCESS (ref_clk)
		VARIABLE temp_dataO : STD_LOGIC_VECTOR (31 DOWNTO 0);
		VARIABLE loadInByte : STD_LOGIC_VECTOR (7 DOWNTO 0);
		VARIABLE loadInHalfword : STD_LOGIC_VECTOR (15 DOWNTO 0);
	BEGIN
		--IF (rising_edge(ref_clk) AND (we = '1')) THEN
		IF (ref_clk'EVENT AND ref_clk = '1') THEN											-- SW, SB, SH
			IF (we = '1') THEN
				IF (dsize (1 DOWNTO 0) = "00") THEN
					dataMemory(to_integer(unsigned(addr))) (7 DOWNTO 0) <= dataI (7 DOWNTO 0);
				ELSIF (dsize (1 DOWNTO 0) = "01") THEN
					dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 0) <= dataI (15 DOWNTO 0);
				ELSIF (dsize (1 DOWNTO 0) = "11") THEN
					dataMemory(to_integer(unsigned(addr))) <= dataI;
				END IF;
			END IF;
		--ELSIF (falling_edge(ref_clk) AND (re = '1')) THEN
		END IF;
		IF (re = '1') THEN											-- LOAD
--			IF (dsize = "011") THEN										-- LW only
--			        dataO <= dataMemory(to_integer(unsigned(addr)));
--			ELSE
--				dataO <= (OTHERS => '-');
--			END IF;
			IF (dsize(2) = '0') THEN									-- NOT LBU or LHU
				IF (dsize (1 DOWNTO 0) = "00") THEN							-- LB
					temp_dataO (31 DOWNTO 8) := "000000000000000000000000";
					dataO (31 DOWNTO 8) <= temp_dataO (31 DOWNTO 8);
					IF (addr(1 DOWNTO 0) = "00") THEN
						loadInByte := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (7 DOWNTO 0)));
						dataO (7 DOWNTO 0) <= loadInByte;
					ELSIF (addr(1 DOWNTO 0) = "01") THEN
						loadInByte := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 8)));
						dataO (7 DOWNTO 0) <= loadInByte;
					ELSIF (addr(1 DOWNTO 0) = "10") THEN
						loadInByte := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (23 DOWNTO 16)));
						dataO (7 DOWNTO 0) <= loadInByte;
					ELSE
						loadInByte := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (31 DOWNTO 24)));
						dataO (7 DOWNTO 0) <= loadInByte;
					END IF;
				ELSIF (dsize (1 DOWNTO 0) = "01") THEN							-- LH
					temp_dataO (31 DOWNTO 16) := "0000000000000000";
					dataO (31 DOWNTO 15) <= temp_dataO (31 DOWNTO 15);
					IF (addr(0) = '0') THEN
						loadInHalfWord := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (31 DOWNTO 16)));
						dataO (15 DOWNTO 0) <= loadInHalfWord;
					ELSE
						loadInHalfWord := STD_LOGIC_VECTOR(signed(dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 0)));
						dataO (15 DOWNTO 0) <= loadInHalfWord;
					END IF;
				ELSIF (dsize (1 DOWNTO 0) = "11") THEN							-- LW
				        dataO <= dataMemory(to_integer(unsigned(addr)));
				END IF;
			ELSE												-- LBU or LHU
				IF (dsize (1 DOWNTO 0) = "00") THEN							-- LBU
					temp_dataO (31 DOWNTO 8) := "000000000000000000000000";
					dataO (31 DOWNTO 8) <= temp_dataO (31 DOWNTO 8);
					IF (addr(1 DOWNTO 0) = "00") THEN
						loadInByte := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (7 DOWNTO 0)));
						dataO (7 DOWNTO 0) <= loadInByte;
					ELSIF (addr(1 DOWNTO 0) = "01") THEN
						loadInByte := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 8)));
						dataO (7 DOWNTO 0) <= loadInByte;
					ELSIF (addr(1 DOWNTO 0) = "10") THEN
						loadInByte := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (23 DOWNTO 16)));
						dataO (7 DOWNTO 0) <= loadInByte;
					ELSE
						loadInByte := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (31 DOWNTO 24)));
						dataO (7 DOWNTO 0) <= loadInByte;
					END IF;
				ELSIF (dsize (1 DOWNTO 0) = "01") THEN							-- LHU
					temp_dataO (31 DOWNTO 16) := "0000000000000000";
					dataO (31 DOWNTO 15) <= temp_dataO (31 DOWNTO 15);
					IF (addr(0) = '0') THEN
						loadInHalfWord := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (31 DOWNTO 16)));
						dataO (15 DOWNTO 0) <= loadInHalfWord;
					ELSE
						loadInHalfWord := STD_LOGIC_VECTOR(unsigned(dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 0)));
						dataO (15 DOWNTO 0) <= loadInHalfWord;
					END IF;
				END IF;
			END IF;	
		END IF;
	END PROCESS;
END arch;
