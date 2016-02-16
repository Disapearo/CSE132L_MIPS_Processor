LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controller IS
	PORT (Funct, OpCode : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		MemtoReg, MemWrite, MemRead, Branch, ALUSrc, RegDest, RegWrite, JumpOut : OUT STD_LOGIC;
		ALUControl : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		dsize : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
END controller;

-- Notes (From MIPS reference online)
-- R-type instructions use OPCODE = 000000
-- I-type instructions use every opcode except 000000, 00001x, and 0100xx.
-- J-type instructions use OPCODEs 00001x
-- (Just FYI) Coprocessor instructions use OPCODEs 0100xx 

-- * From Assignment Spec *
-- R-type if OpCode = 000000
-- I-type (Lw and Sw only) if OpCode = 100011 or 101011
-- J-type OpCode is currently unknown

ARCHITECTURE arch OF controller IS

BEGIN

	MemtoReg <=  '0' WHEN (OpCode = "000000") ELSE													-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE										-- JType
		     '1' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE		-- LW, LB, LH, LBU, LHU
		     '0' WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE	 						-- SW, SB, SH
		     '0' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE		-- Branch
		     '0';																-- Everything else

--	MemtoReg <=  '1' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE '0';		-- Load

	MemWrite <=  '0' WHEN (OpCode = "000000") ELSE													-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE										-- JType
		     '0' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE		-- LW, LB, LH, LBU, LHU
		     '1' WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE	 						-- SW, SB, SH
		     '0' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE		-- Branch
		     '0';																-- Everything else

--	MemWrite <=  '1' WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE '0';							-- Store

	MemRead	 <=  '0' WHEN (OpCode = "000000") ELSE                                                                                                  -- RType
                     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE                                                                             -- JType
                     '1' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE              -- LW, LB, LH, LBU, LHU
                     '0' WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE                                                        -- SW, SB, SH
                     '0' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE              -- Branch
                     '0'; 

--	MemRead <=   '1' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE '0';		-- Load

	Branch <=    '1' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE '0';		-- Branch

	ALUSrc <=    '0' WHEN (OpCode = "000000") ELSE													-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE										-- JType
		     '1';																-- IType

--	ALUSrc <=    '0' WHEN (OpCode = "000000" OR OpCode = "000010" OR OpCode = "000011") ELSE '1';							-- RType or JType

	RegDest <=   '1' WHEN (OpCode = "000000") ELSE													-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE										-- JType
		     '0';																-- IType

--	RegDest <=   '1' WHEN (OpCode = "000000") ELSE '0';												-- RType

	RegWrite <=  '1' WHEN (OpCode = "000000") ELSE													-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE										-- JType
		     '1' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE		-- LW, LB, LH, LBU, LHU
		     '0' WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE							-- SW, SB, SH
		     '1' WHEN (OpCode = "001100") ELSE												-- ANDI (Funct = AND Operation)
		     '1' WHEN (OpCode = "001101") ELSE												-- ORI (Funct = OR Operation)
		     '1' WHEN (OpCode = "001110") ELSE												-- XORI (Funct = XOR Operation)
		     '1' WHEN (OpCode = "001000") ELSE												-- ADDI
		     '1' WHEN (OpCode = "001001") ELSE												-- ADDIU
		     '1' WHEN (OpCode = "001010") ELSE												-- SLTI
		     '1' WHEN (OpCode = "001011") ELSE												-- SLTIU
		     '1' WHEN (OpCode = "001111") ELSE												-- LUI
		     '0' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111");			-- Branch

	JumpOut <=   '1' WHEN (OpCode = "000000" AND (Funct = "001001" OR Funct = "001000")) ELSE							-- RType, Funct = JALR or JR
		     '0' WHEN (OpCode = "000000" AND (Funct /= "001001" OR Funct /= "001000")) ELSE							-- RType, Funct /= JALR or JR
		     '1' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE										-- JType
		     '0';																-- IType

	ALUControl <= Funct WHEN (OpCode = "000000") ELSE												-- RType
		      Funct WHEN (OpCode = "000010" OR OpCode = "000011") ELSE										-- JType
		      "100100" WHEN (OpCode = "001100") ELSE												-- ANDI (Funct = AND Operation)
		      "100101" WHEN (OpCode = "001101") ELSE												-- ORI (Funct = OR Operation)
		      "100110" WHEN (OpCode = "001110") ELSE												-- XORI (Funct = XOR Operation)
		      "100000" WHEN (OpCode = "001000") ELSE												-- ADDI
		      "100001" WHEN (OpCode = "001001") ELSE												-- ADDIU
		      "101010" WHEN (OpCode = "001010") ELSE												-- SLTI
		      "101011" WHEN (OpCode = "001011") ELSE												-- SLTIU
		      "001111" WHEN (OpCode = "001111") ELSE												-- LUI
		      "100000" WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE	-- LW, LB, LH, LBU, LHU (Add)
		      "100000" WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE	 						-- SW, SB, SH (Add)
		      "110100" WHEN (OpCode = "000100") ELSE												-- BEQ
		      "110101" WHEN (OpCode = "000101") ELSE												-- BNE
		      "110001" WHEN (OpCode = "000001") ELSE												-- BLZ
		      "110001" WHEN (OpCode = "000001") ELSE												-- BGEZ
		      "110110" WHEN (OpCode = "000110") ELSE												-- BLEZ
		      "110111" WHEN (OpCode = "000111");												-- BGZ

	dsize <=      OpCode (2 DOWNTO 0);

END arch;
