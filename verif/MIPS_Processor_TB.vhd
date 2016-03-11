LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY PROCESSOR_TB IS
END PROCESSOR_TB;

ARCHITECTURE TEST OF PROCESSOR_TB IS
	COMPONENT processor IS
		PORT (clk : IN std_logic ;
			reset : IN std_logic ); 
	END component processor;

	SIGNAL clk_tb,reset_tb: std_logic;

BEGIN

	PROCESSOR_INST: processor
	 	PORT MAP(clk_tb, reset_tb);

	Clk: PROCESS
	BEGIN
		clk_tb <= '0';		-- 1
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 2
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 3
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 4
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 5
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 6
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 7
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 8
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 9
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 10
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 11
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 12
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 13
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 14
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 15
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 16
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 17
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 18
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 19
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 20
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 21
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 22
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 23
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 24
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 25
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 26
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 27
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 28
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 29
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '0';		-- 30
		reset_tb <= '0';
		wait for 100 ns;

		clk_tb <= '1';
		reset_tb <= '0';
		wait for 100 ns;

--		clk_tb <= '0';		-- Reset
--		reset_tb <= '1';
--		wait for 100 ns;
--
--		clk_tb <= '0';
--		reset_tb <= '0';
--		wait for 100 ns;

	END PROCESS;

END TEST;
