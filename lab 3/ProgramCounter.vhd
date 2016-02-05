LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PC IS
	PORT (clk: in std_logic;
		i: in 	std_logic_vector (31 DOWNTO 0);
		o: out 	std_logic_vector (31 DOWNTO 0)
	);
END PC;

ARCHITECTURE arch OF PC IS
BEGIN
	PROCESS (clk)
	BEGIN
		IF (clk'EVENT and clk = '1') THEN
			o <= i; -- Update the PC
		END IF;
	END PROCESS;
END arch;