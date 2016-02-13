LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY alu IS
	PORT (Func_in : IN std_logic_vector (5 DOWNTO 0);
		SHAMT : IN std_logic_vector (4 DOWNTO 0);
		A_in : IN std_logic_vector (31 DOWNTO 0);
		B_in : IN std_logic_vector (31 DOWNTO 0);
		O_out : OUT std_logic_vector (31 DOWNTO 0);
		Branch_out : OUT std_logic);
END alu ;

ARCHITECTURE arch OF alu IS

	COMPONENT Comparator IS
		PORT (In1, In2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			SLTS, SLTU : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			BLZ, BGEZ, BE, BNE, BLEZ, BGZ : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	END COMPONENT;

	SIGNAL CSLTS : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL CSLTU : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL CBLZ, CBGEZ, CBEQ, CBNE, CBLEZ, CBGZ : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN

	C1: Comparator PORT MAP (A_in, B_in, CSLTS, CSLTU, CBLZ, CBGEZ, CBEQ, CBNE, CBLEZ, CBGZ);

	O_out <= STD_LOGIC_VECTOR(signed(A_in) + signed(B_in)) WHEN Func_in = "100000" ELSE					-- ADD/ADDI (OPCODE = "001000"), LW (OPCODE = "100011"), LB (OPCODE = "100000"), LH (OPCODE = "100001"), LBU (OPCODE = "100100"), LHU (OPCODE = "100101"), SW (OPCODE = "101011"), SB (OPCODE = "101000"), SH (OPCODE = "101001")
		STD_LOGIC_VECTOR(unsigned(A_in) + unsigned(B_in)) WHEN Func_in = "100001" ELSE					-- ADDU/ADDIU (OPCODE = "001001")
		STD_LOGIC_VECTOR(signed(A_in) - signed(B_in)) WHEN Func_in = "100010" ELSE					-- SUB/Branch
		STD_LOGIC_VECTOR(unsigned(A_in) - unsigned(B_in)) WHEN Func_in = "100011" ELSE					-- SUBU
		(A_in AND B_in) WHEN Func_in = "100100" ELSE									-- AND
		(A_in OR B_in) WHEN Func_in = "100101" ELSE									-- OR/ORI (OPCODE = "001101")
		(A_in XOR B_in) WHEN Func_in = "100110" ELSE									-- XOR/XORI (OPCODE = "001110")
		(A_in NOR B_in) WHEN Func_in = "100111" ELSE									-- NOR
		CSLTS WHEN Func_in = "101010" ELSE										-- SLT Signed/SLTI Signed (OPCODE = "001010")
		CSLTU WHEN Func_in = "101011" ELSE										-- SLT Unsigned/SLTI Unsigned (OPCODE = "001011")
		TO_STDLOGICVECTOR(TO_BITVECTOR(B_in) SLL TO_INTEGER(SIGNED(Shamt))) WHEN Func_in = "000000" ELSE		-- SLL
		TO_STDLOGICVECTOR(TO_BITVECTOR(B_in) SRL TO_INTEGER(SIGNED(Shamt))) WHEN Func_in = "000010" ELSE		-- SRL
		TO_STDLOGICVECTOR(TO_BITVECTOR(B_in) SRA TO_INTEGER(SIGNED(Shamt))) WHEN Func_in = "000011" ELSE		-- SRA
		TO_STDLOGICVECTOR(TO_BITVECTOR(B_in) SLL TO_INTEGER(SIGNED(A_in))) WHEN Func_in = "000100" ELSE			-- SLLV
		TO_STDLOGICVECTOR(TO_BITVECTOR(B_in) SRL TO_INTEGER(SIGNED(A_in))) WHEN Func_in = "000110" ELSE			-- SRLV
		TO_STDLOGICVECTOR(TO_BITVECTOR(B_in) SRA TO_INTEGER(SIGNED(A_in))) WHEN Func_in = "000111" ELSE			-- SRAV
		B_in(15 DOWNTO 0) & A_in(15 DOWNTO 0) WHEN Func_in = "001111" ELSE						-- LUI
		CBLZ WHEN Func_in = "110001" ELSE										-- BLZ (OPCODE = "000001")
		CBGEZ WHEN Func_in = "110001" ELSE										-- BGEZ (OPCODE = "000001")
		CBEQ WHEN Func_in = "110100" ELSE										-- BEQ (OPCODE = "000100")
		CBNE WHEN Func_in = "110101" ELSE										-- BNE (OPCODE = "000101")
		CBLEZ WHEN Func_in = "110110" ELSE										-- BLEZ (OPCODE = "000110")
		CBGZ WHEN Func_in = "110111" ;											-- BGZ (OPCODE = "000111")


	Branch_out <= '1' WHEN (Func_in = "000001" OR Func_in = "000100" OR Func_in = "000101" OR Func_in = "000110" OR Func_in = "000111") ELSE '0';

END arch;
