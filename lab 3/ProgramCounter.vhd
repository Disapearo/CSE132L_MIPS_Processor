LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PC IS
	PORT (clk: 		IN 	std_logic;
		pc_reset: 	IN 	std_logic;
		pc_in: 		IN 	std_logic_vector (31 DOWNTO 0);
		pc_out: 	OUT std_logic_vector (31 DOWNTO 0)
	);
END PC;

ARCHITECTURE arch OF PC IS
BEGIN
	PROCESS (clk) -- Don't need asynchronous reset, so only sensitive to clk
	BEGIN
		IF (clk'EVENT and clk = '1') THEN
			IF (pc_reset = 1) THEN
				pc_out <= (OTHERS => '0'); -- Assumes iMem starts at 0
			ELSE 
				pc_out <= pc_in; -- Update the PC
			END IF;
		END IF;
	END PROCESS;
END arch;