LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.NUMERIC_STD_UNSIGNED.ALL;

entity imem is -- instruction memory
	port(addr: in STD_LOGIC_VECTOR(5 downto 0);
	rd: out STD_LOGIC_VECTOR(31 downto 0));
end;

ARCHITECTURE arch OF imem IS

BEGIN

	PROCESS
		FILE mem_file : TEXT;
		VARIABLE L : LINE;
		VARIABLE ch : CHARACTER;
		VARIABLE i, index, result : INTEGER;
		TYPE ramtype IS ARRAY (63 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
		VARIABLE mem : ramtype;
	BEGIN
		-- initialize memory from file
		FOR i in 0 TO 63 LOOP
			mem(i) := (OTHERS => '0');
		END LOOP;

		index := 0;
		FILE_OPEN (mem_file, "imem.h", READ_MODE);

		WHILE NOT ENDFILE(mem_file) LOOP
			READLINE(mem_file, L);
			result := 0;

			FOR i IN 1 TO 8 LOOP
				READ (L, ch);
				IF ('0' <= ch AND ch <= '9') THEN
					result := CHARACTER'POS(ch) - CHARACTER'POS('0');
				ELSIF ('a' <= ch AND ch <= 'f') THEN
					result := CHARACTER'POS(ch) - CHARACTER'POS('a')+10;
				ELSE
					REPORT "Format Error on Line" & INTEGER'
					IMAGE(index) SEVERITY ERROR;
				END IF;
				mem(index)(35-i*4 DOWNTO 32-i*4) := TO_STD_LOGIC_VECTOR(result, 4);
			END LOOP;
			index := index + 1;
		END LOOP;
		-- read memory
		WAIT ON addr; -- Suspend process on first initialization
		LOOP
			rd <= mem(TO_INTEGER(addr));
			WAIT ON addr;
		END LOOP;
	END PROCESS;
END arch;
