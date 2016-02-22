library IEEE;

use ieee.std_logic_1164.ALL;

entity mux4to1 IS

	PORT(

		A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		Output : out STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END ENTITY mux4to1;

ARCHITECTURE concurrent OF mux4to1 IS
	BEGIN

		Output <= A WHEN sel = "00" ELSE
			B WHEN sel = "01" ELSE
			C WHEN sel = "10" ELSE
			D WHEN sel = "11";
END ARCHITECTURE concurrent;
