LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Comparator IS
	PORT (In1, In2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		SLTS, SLTU : OUT STD_LOGIC);
--		BLZ, BGEZ, BE, BNE, BLEZ, BGZ : OUT STD_LOGIC);
END Comparator;

ARCHITECTURE arch OF Comparator IS

BEGIN
	PROCESS (In1, In2)
	
	BEGIN

		IF (signed(In1) < signed(In2)) THEN
			SLTS 	<= '1';
		ELSE
			SLTS 	<= '0';
		END IF;

		IF (In1 < In2) THEN
			SLTU 	<= '1';
		ELSE
			SLTU 	<= '0';
		END IF;

--		IF (In1 < X"00000000") THEN
--			BLZ 	<= '1';
--			BGZ 	<= '0';
--			BLEZ 	<= '1';
--			BGEZ 	<= '0';
--		ELSIF (IN1 > X"00000000") THEN
--			BLZ 	<= '0';
--			BGZ 	<= '1';
--			BLEZ 	<= '0';
--			BGEZ 	<= '1';
--		ELSE
--			BLZ 	<= '0';
--			BGZ 	<= '0';
--			BLEZ 	<= '1';
--			BGEZ 	<= '1';
--		END IF;
--
--		IF (In1 = In2) THEN
--			BE 	<= '1';
--			BNE 	<= '0';
--		ELSE
--			BE 	<= '0';
--			BNE 	<= '1';
--		END IF;

	END PROCESS;

END arch;
