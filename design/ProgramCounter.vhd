LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PC IS
	PORT (ref_clk: 		IN 	std_logic;
		pc_reset: 	IN 	std_logic;
		pc_in: 		IN 	std_logic_vector (31 DOWNTO 0);
		PCWrite: 	IN STD_LOGIC;
		pc_out: 	OUT std_logic_vector (31 DOWNTO 0)
	);
END PC;

ARCHITECTURE arch OF PC IS
	--SIGNAL stored_pc : std_logic_vector(31 downto 0) := (OTHERS => '0');
BEGIN
	PROCESS (ref_clk) -- Don't need asynchronous reset, so only sensitive to ref_clk
		VARIABLE stored_pc : std_logic_vector(31 downto 0) := (OTHERS => '0');
	BEGIN
		IF (ref_clk'EVENT and ref_clk = '1') THEN
			IF (pc_reset = '1') THEN
				stored_pc := (OTHERS=>'0');
				pc_out <= (OTHERS => '0'); -- Assumes iMem starts at 0
			ELSIF (PCWrite = '1') THEN 
				pc_out <= stored_pc; -- Update the PC
--				stored_pc := pc_in;
--				pc_out <= pc_in;
			END IF;
		ELSIF (ref_clk'EVENT and ref_clk = '0') THEN
			stored_pc := pc_in;
		END IF;
	END PROCESS;
END arch;
