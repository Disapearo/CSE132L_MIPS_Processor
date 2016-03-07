LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

-- Use this version of Instruction Memory when synthesizing.
-- The tested MIPS instructions have already been preloaded into memory.

entity synth_imem is -- instruction memory
	port(addr: in STD_LOGIC_VECTOR(5 downto 0);
	rd: out STD_LOGIC_VECTOR(31 downto 0));
end;

ARCHITECTURE arch OF synth_imem IS
	TYPE ramtype IS ARRAY (63 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem : ramtype := (OTHERS => (OTHERS => '0'));

BEGIN

	PROCESS (addr)
--		TYPE ramtype IS ARRAY (63 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
--		VARIABLE mem : ramtype := (OTHERS => (OTHERS => '0'));
	BEGIN
		-- Preload memory
		mem(0)	<= X"20020005";
		mem(1)	<= X"2003000c";
		mem(2)	<= X"2067fff7";
		mem(3)	<= X"00e22025";
		mem(4)	<= X"00642824";
		mem(5)	<= X"00a42820";
--		mem(6)	<= X"10a7000a";
		mem(6)	<= X"0064202a";
--		mem(8)	<= X"10800001";
		mem(7)	<= X"20050000";
		mem(8) <= X"00e2202a";
		mem(9) <= X"00853820";
		mem(10) <= X"00e23822";
		mem(11) <= X"ac670044";
		mem(12) <= X"8c020050";
--		mem(15) <= X"08000011";
		mem(13) <= X"20020001";
		mem(14) <= X"ac020054";

		-- SYNTHESIS DOESN'T SUPPORT WAIT STATEMENTS FOR NON-CLOCK EVENTS!
		-- Read memory
		--WAIT ON addr; -- Suspend process on first initialization
		--LOOP
		--	rd <= mem(TO_INTEGER(unsigned(addr)));
		--	WAIT ON addr;
		--END LOOP;

		rd <= mem(TO_INTEGER(unsigned(addr)));

	END PROCESS;
END arch;
