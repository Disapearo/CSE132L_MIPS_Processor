LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY register_2 IS
	PORT (ref_clk: 	IN 	std_logic;
		reg_reset: 	IN 	std_logic;
		reg_enable:	IN  std_logic;
		a_in, b_in: 	IN 	std_logic_vector (31 DOWNTO 0);
		a_out, b_out: 	OUT std_logic_vector (31 DOWNTO 0)
	);
END register_2;

ARCHITECTURE arch OF register_2 IS
BEGIN
	PROCESS (ref_clk) -- Don't need asynchronous reset, so only sensitive to ref_clk
	BEGIN
		IF (ref_clk'EVENT and ref_clk = '1') THEN
			IF (reg_reset = '1') THEN
				a_out <= (OTHERS => '0');
				b_out <= (OTHERS => '0');
			ELSIF (reg_enable = '1') THEN 
				a_out <= a_in;
				b_out <= b_in;
			END IF;
		END IF;
	END PROCESS;
END arch;
