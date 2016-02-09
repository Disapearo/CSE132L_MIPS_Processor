LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Comparator IS
	PORT (In1, In2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		SLTS, SLTU : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		BLZ, BGEZ, BE, BNE, BLEZ, BGZ : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
END Comparator;

ARCHITECTURE arch OF Comparator IS

BEGIN
	PROCESS (In1, In2)
	
	BEGIN

		IF (signed(In1) < signed(In2)) THEN
			SLTS <= (OTHERS => '1');
		ELSE
			SLTS <= (OTHERS => '0');
		END IF;

		IF (In1 < In2) THEN
			SLTU <= (OTHERS => '1');
		ELSE
			SLTU <= (OTHERS => '0');
		END IF;

		IF (In1 < "0") THEN
			BLZ <= (OTHERS => '1');
			BGZ <= (OTHERS => '0');
			BLEZ <= (OTHERS => '1');
			BGEZ <= (OTHERS => '0');
		ELSIF (IN1 > "0") THEN
			BLZ <= (OTHERS => '0');
			BGZ <= (OTHERS => '1');
			BLEZ <= (OTHERS => '0');
			BGEZ <= (OTHERS => '1');
		ELSE
			BLZ <= (OTHERS => '0');
			BGZ <= (OTHERS => '0');
			BLEZ <= (OTHERS => '1');
			BGEZ <= (OTHERS => '1');
		END IF;

		IF (In1 = In2) THEN
			BE <= (OTHERS => '1');
			BNE <= (OTHERS => '0');
		ELSE
			BE <= (OTHERS => '0');
			BNE <= (OTHERS => '1');
		END IF;

	END PROCESS;

END arch;