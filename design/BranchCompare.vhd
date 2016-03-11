LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY BranchComparator IS
	PORT (In1, In2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		BEQ : OUT STD_LOGIC);
END BranchComparator;

ARCHITECTURE arch OF BranchComparator IS

BEGIN
	PROCESS (In1, In2)
	
	BEGIN

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
		IF (In1 = In2) THEN
			BEQ 	<= '1';
--			BNE 	<= '0';
		ELSE
			BEQ 	<= '0';
--			BNE 	<= '1';
		END IF;

	END PROCESS;

END arch;
