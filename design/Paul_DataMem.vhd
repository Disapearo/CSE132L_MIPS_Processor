LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ram IS
	GENERIC ( N : INTEGER := 11);
	PORT (clk : IN std_logic ;
		we, re : IN std_logic ;
		dsize : IN std_logic_vector (2 DOWNTO 0);
		addr 	: IN std_logic_vector (N-1 DOWNTO 0);
		dataI 	: IN std_logic_vector (31 DOWNTO 0);
		dataO 	: OUT std_logic_vector (31 DOWNTO 0));
END ram ;

ARCHITECTURE arch OF ram IS

	TYPE buff IS ARRAY (0 TO (2**N)-1) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL dataMemory : buff := (OTHERS => (OTHERS => '0'));

BEGIN
	PROCESS (clk)
		VARIABLE max : INTEGER;
		VARIABLE byte_extend_unsigned : STD_LOGIC_VECTOR(23 DOWNTO 0) := (OTHERS=>'0');
		VARIABLE hw_extend_unsigned : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS=>'0');
		VARIABLE temp_dataO : STD_LOGIC_VECTOR (31 DOWNTO 0);

	BEGIN
		IF (clk'event and clk ='1') THEN
			IF (we = '1') THEN
				IF (dsize(1 DOWNTO 0) = "00") THEN
					dataMemory(to_integer(unsigned(addr))) <= dataI(7 DOWNTO 0);
				ELSIF (dsize(1 DOWNTO 0) = "01") THEN
					dataMemory(to_integer(unsigned(addr))) <= dataI(7 DOWNTO 0);
					dataMemory(to_integer(unsigned(addr)) + 1) <= dataI(15 DOWNTO 8);
				ELSIF (dsize(1 DOWNTO 0) = "11") THEN
					dataMemory(to_integer(unsigned(addr))) <= dataI(7 DOWNTO 0);
					dataMemory(to_integer(unsigned(addr)) + 1) <= dataI(15 DOWNTO 8);
					dataMemory(to_integer(unsigned(addr)) + 2) <= dataI(23 DOWNTO 16);
					dataMemory(to_integer(unsigned(addr)) + 3) <= dataI(31 DOWNTO 24);
				END IF;
			ELSIF (re = '1') THEN
				IF (dsize(1 DOWNTO 0) = "11") THEN								--LW
					dataO(7 DOWNTO 0) <= dataMemory(to_integer(unsigned(addr)));
					dataO(15 DOWNTO 8) <= dataMemory(to_integer(unsigned(addr)) + 1);
					dataO(23 DOWNTO 16) <= dataMemory(to_integer(unsigned(addr)) + 2);
					dataO(31 DOWNTO 24) <= dataMemory(to_integer(unsigned(addr)) + 3);
				ELSIF (dsize(2) = '1') THEN									--LBU, LHU
					IF (dsize(1 DOWNTO 0) = "00") THEN
						dataO(31 DOWNTO 8) <= byte_extend_unsigned;
						dataO(7 DOWNTO 0) <= dataMemory(to_integer(unsigned(addr)));
					ELSIF (dsize(1 DOWNTO 0) = "01") THEN
						dataO(31 DOWNTO 16) <= hw_extend_unsigned;
						dataO(7 DOWNTO 0) <= dataMemory(to_integer(unsigned(addr)));
						dataO(15 DOWNTO 8) <= dataMemory(to_integer(unsigned(addr)) + 1);
					END IF;
				ELSIF (dsize(2) = '0') THEN												--LB, LH
					IF (dsize(1 DOWNTO 0) = "00") THEN
						FOR i IN 0 TO 23 LOOP
							dataO(31 - i) <= dataMemory(to_integer(unsigned(addr))) (7);
						END LOOP;
						dataO(7 DOWNTO 0) <= dataMemory(to_integer(unsigned(addr)));
					ELSIF (dsize(1 DOWNTO 0) = "01") THEN
						FOR i IN 0 TO 16 LOOP
							dataO(31 - i) <= dataMemory(to_integer(unsigned(addr)) + 1) (7);
						END LOOP;
						dataO(7 DOWNTO 0) <= dataMemory(to_integer(unsigned(addr)));
						dataO(15 DOWNTO 8) <= dataMemory(to_integer(unsigned(addr)) + 1);
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END arch;

