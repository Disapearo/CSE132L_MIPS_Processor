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
	SIGNAL regarray : reg_file := (
		"00000000000000000000000000000000",
		"00000000000000000000000000000001",
		"00000000000000000000000000000010",
		"00000000000000000000000000000011",
		"00000000000000000000000000000100",
		"00000000000000000000000000000101",
		"00000000000000000000000000000110",
		"00000000000000000000000000000111",
		"00000000000000000000000000001000",
		"00000000000000000000000000001001",
		"00000000000000000000000000001010",
		"00000000000000000000000000001011",
		OTHERS => (OTHERS => '0')
		);

BEGIN
		--regarray(0) <= "00000000000000000000000000000000";
		--regarray(1) <= "00000000000000000000000000000001";
		--regarray(2) <= "00000000000000000000000000000010";
		--regarray(3) <= "00000000000000000000000000000011";
		--regarray(4) <= "00000000000000000000000000000100";
		--regarray(5) <= "00000000000000000000000000000101";
		--regarray(6) <= "00000000000000000000000000000110";
		--regarray(7) <= "00000000000000000000000000000111";
		--regarray(8) <= "00000000000000000000000000001000";
		--regarray(9) <= "00000000000000000000000000001001";
		--regarray(10) <= "00000000000000000000000000001010";
		--regarray(11) <= "00000000000000000000000000001011";


	PROCESS --(clk, rst_s, we, raddr_1, raddr_2, waddr)
	BEGIN


		IF (clk'EVENT and clk = '1') THEN
			IF (rst_s = '1') THEN
				regarray <= (OTHERS => (OTHERS => '0'));
			ELSIF (we = '1') THEN
				regarray(TO_INTEGER(UNSIGNED(waddr))) <= wdata;
			END IF;
		END IF;

		rdata_1 <= regarray(TO_INTEGER(UNSIGNED(raddr_1)));
		rdata_2 <= regarray(TO_INTEGER(UNSIGNED(raddr_2)));
		WAIT ON clk, rst_s, we, raddr_1, raddr_2, waddr;

	END PROCESS;
END arch;