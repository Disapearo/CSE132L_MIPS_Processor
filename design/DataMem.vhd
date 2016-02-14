LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ram IS
	GENERIC ( N : INTEGER := 32);
	PORT (clk : IN std_logic ;
		we, re : IN std_logic ;
		dsize : IN std_logic_vector (2 DOWNTO 0);
		addr 	: IN std_logic_vector (31 DOWNTO 0);
		dataI 	: IN std_logic_vector (31 DOWNTO 0);
		dataO 	: OUT std_logic_vector (31 DOWNTO 0));
END ram ;

ARCHITECTURE arch OF ram IS

	TYPE buff IS ARRAY ((16*N)-1 DOWNTO 0) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL dataMemory : buff := (OTHERS => (OTHERS => '0'));

BEGIN
	PROCESS (clk)
		VARIABLE max : INTEGER;
		VARIABLE temp_dataO : STD_LOGIC_VECTOR (31 DOWNTO 0);
	BEGIN
		IF (rising_edge(clk) AND (we = '1')) THEN
			IF (dsize (1 DOWNTO 0) = "00") THEN
				dataMemory(to_integer(unsigned(addr))) (7 DOWNTO 0) <= dataI (7 DOWNTO 0);
			ELSIF (dsize (1 DOWNTO 0) = "01") THEN
				dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 0) <= dataI (15 DOWNTO 0);
			ELSIF (dsize (1 DOWNTO 0) = "11") THEN
				dataMemory(to_integer(unsigned(addr))) <= dataI;
			END IF;
		ELSIF (falling_edge(clk) AND (re = '1')) THEN
-- Sign Extend
                    	IF (dsize(2) = '0') THEN
                            	max := 23;
                    	ELSE
                            	max := 15;
                    	END IF;

                    	FOR i IN 0 TO max LOOP
                            	temp_dataO (31-i) := dataMemory(to_integer(unsigned(addr))) (30-max);
                    	END LOOP;

                    	IF (dsize (1 DOWNTO 0) = "00") THEN
                            	dataO (31 DOWNTO 8) <= temp_dataO (31 DOWNTO 8);
                            	dataO (7 DOWNTO 0) <= dataMemory(to_integer(unsigned(addr))) (7 DOWNTO 0);
                    	ELSIF (dsize (1 DOWNTO 0) = "01") THEN
                            	dataO (31 DOWNTO 16) <= temp_dataO (31 DOWNTO 16);
                            	dataO (15 DOWNTO 0) <= dataMemory(to_integer(unsigned(addr))) (15 DOWNTO 0);
                    	ELSE
                                dataO <= dataMemory(to_integer(unsigned(addr)));
                        END IF;
		ELSE
			dataO <= (OTHERS => 'U'); -- The MemToReg mux should block this if it's an R-Type instruction
		END IF;
	END PROCESS;
END arch;
