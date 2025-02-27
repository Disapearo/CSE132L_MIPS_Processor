LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY reg IS
	PORT (ref_clk: 	IN 	std_logic;
		reg_reset: 	IN 	std_logic;
		reg_enable:	IN  std_logic;
		data_in: 	IN 	std_logic_vector (31 DOWNTO 0);
		data_out: 	OUT std_logic_vector (31 DOWNTO 0)
	);
END reg;

ARCHITECTURE arch OF reg IS
BEGIN
	PROCESS (ref_clk) -- Don't need asynchronous reset, so only sensitive to ref_clk
	BEGIN
		IF (ref_clk'EVENT and ref_clk = '1') THEN
			IF (reg_reset = '1') THEN
				data_out <= (OTHERS => '0');
			ELSIF (reg_enable = '1') THEN 
				data_out <= data_in;
			END IF;
		END IF;
	END PROCESS;
END arch;
