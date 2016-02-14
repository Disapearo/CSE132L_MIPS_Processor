LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL; -- No longer recommended (according to interwebz)
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY regfile IS
	GENERIC ( NBIT : INTEGER := 32;
		NSEL : INTEGER := 5);
	PORT (clk 	: IN 	std_logic ;
		rst_s 	: IN 	std_logic ; -- synchronous reset
		we 		: IN 	std_logic ; -- write enable
		raddr_1 : IN 	std_logic_vector ( NSEL -1 DOWNTO 0); -- read address 1
		raddr_2 : IN 	std_logic_vector ( NSEL -1 DOWNTO 0); -- read address 2
		waddr 	: IN 	std_logic_vector ( NSEL -1 DOWNTO 0); -- write address
		rdata_1 : OUT 	std_logic_vector ( NBIT -1 DOWNTO 0); -- read data 1
		rdata_2 : OUT 	std_logic_vector ( NBIT -1 DOWNTO 0); -- read data 2
		wdata 	: IN 	std_logic_vector ( NBIT -1 DOWNTO 0)); -- write data 1
END regfile ;



ARCHITECTURE arch OF regfile IS
	TYPE reg_file IS ARRAY (0 TO 2**NSEL -1) OF STD_LOGIC_VECTOR (NBIT -1 DOWNTO 0);
	SIGNAL regarray : reg_file := (OTHERS => (OTHERS => '0'));

BEGIN
	PROCESS
	BEGIN
		WAIT ON clk, rst_s, we, raddr_1, raddr_2, waddr;
		IF (clk'EVENT and clk = '1') THEN
			IF (rst_s = '1') THEN
				regarray <= (OTHERS => (OTHERS => '0'));
			ELSIF (we = '1') THEN
				regarray(TO_INTEGER(UNSIGNED(waddr))) <= wdata;
			END IF;
		END IF;

		rdata_1 <= regarray(TO_INTEGER(UNSIGNED(raddr_1)));
		rdata_2 <= regarray(TO_INTEGER(UNSIGNED(raddr_2)));
		-- WAIT ON clk, rst_s, we, raddr_1, raddr_2, waddr;

	END PROCESS;
END arch;
