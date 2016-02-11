LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controller IS
	PORT (Funct, OpCode : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		MemtoReg, MemWrite, Branch, ALUSrc, RegDest, RegWrite, JumpOut : OUT STD_LOGIC;
		ALUControl : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		dsize : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
END controller;

-- Notes (From MIPS reference online)
-- R-type instructions use OPCODE = 000000
-- I-type instructions use every opcode except 000000, 00001x, and 0100xx.
-- J-type instructions use OPCODEs 00001x
-- (Just FYI) Coprocessor instructions use OPCODEs 0100xx 

-- * From Assignment Spec*
-- R-type if OpCode = 000000
-- I-type (Lw and Sw only) if OpCode = 100011 or 101011
-- J-type OpCode is currently unknown

ARCHITECTURE arch OF controller IS

BEGIN

	MemtoReg <=  '0' WHEN (OpCode = "000000") ELSE									-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE						-- JType
		     '1' WHEN (OpCode (5 DOWNTO 3) = "100") ELSE							-- LW
		     '0' WHEN (OpCode (2 DOWNTO 0) = "101" OR OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111"); 	-- SW and Branch

	MemWrite <=  '0' WHEN (OpCode = "000000") ELSE									-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE						-- JType
		     '0' WHEN (OpCode (5 DOWNTO 3) = "100" OR OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE	-- LW
		     '1' WHEN (OpCode (2 DOWNTO 0) = "101"); 								-- SW

	Branch <=    '1' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE '0';				-- Branch

	ALUSrc <=    '0' WHEN (OpCode = "000000") ELSE									-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE						-- JType
		     '1';												-- IType

	RegDest <=   '1' WHEN (OpCode = "000000") ELSE									-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE						-- JType
		     '0';												-- IType

	RegWrite <=  '1' WHEN (OpCode = "000000") ELSE									-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE						-- JType
		     '1' WHEN (OpCode (5 DOWNTO 3) = "100") ELSE							-- LW
		     '0' WHEN (OpCode (2 DOWNTO 0) = "101" OR OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111");	-- SW


	JumpOut <=   '1' WHEN (OpCode = "000000" AND (Funct = "001001" OR Funct = "001000")) ELSE			-- RType, Funct = JALR or JR
		     '0' WHEN (OpCode = "000000" AND (Funct /= "001001" OR Funct /= "001000")) ELSE			-- RType, Funct = JALR or JR
		     '1' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE						-- JType
		     '0';												-- IType

	ALUControl <= Funct WHEN (OpCode = "000000") ELSE								-- RType
		      Funct WHEN (OpCode = "000010" OR OpCode = "000011") ELSE						-- JType
		      "100000" WHEN (OpCode (5 DOWNTO 3) = "100" OR OpCode (2 DOWNTO 0) = "101") ELSE			-- LW or SW (Add)
		      "110100" WHEN (OpCode = "000100") ELSE								-- BEQ
		      "110101" WHEN (OpCode = "000101") ELSE								-- BNE
		      "110001" WHEN (OpCode = "000001") ELSE								-- BLZ
		      "110001" WHEN (OpCode = "000001") ELSE								-- BGEZ
		      "110110" WHEN (OpCode = "000110") ELSE								-- BLEZ
		      "110111" WHEN (OpCode = "000111");								-- BGZ

	dsize <=      OpCode (2 DOWNTO 0);

END arch;

--ARCHITECTURE arch OF controller IS
--
--BEGIN
--	PROCESS (Funct, OpCode)
--		VARIABLE RTYPE : STD_LOGIC;
--		VARIABLE ITYPE : STD_LOGIC;
--		VARIABLE JTYPE : STD_LOGIC;
--	BEGIN
--		-- Finish determining instruction type
--		IF (OpCode = "000000") THEN	-- R-Type
--			RTYPE := '1';
--			ITYPE := '0';
--			JTYPE := '0';
--		ELSIF (OpCode = "000010") OR (OpCode = "000011") THEN 	-- J-Type
--			RTYPE := '0';
--			ITYPE := '0';
--			JTYPE := '1';
--		ELSE				-- I-Type
--			RTYPE := '0';
--			ITYPE := '1';
--			JTYPE := '0';
--		END IF;
--
--		-- Core of Controller -- TODO: Continue fixing here!!!!!
--
--		IF (RTYPE = '1') THEN
--			RegDest 	<= '1';
--			RegWrite 	<= '1';
--			ALUSrc 		<= '0';
--			MemWrite 	<= '0';
--			MemtoReg 	<= '0';
--			ALUControl 	<= Funct;
--			Branch 		<= '0';
--			IF (Funct = "001001" or Funct = "001000") THEN --Jump and Link Register, Jump Return
--				JumpOut <= '1';
--			ELSE
--				JumpOut <= '0';
--			END IF;
--
--		ELSIF (ITYPE = '1') THEN
--			RegDest 	<= '0';
--			ALUSrc 		<= '1';
--			JumpOut 	<= '0';
--			IF (OpCode (5 DOWNTO 3) = "100") THEN -- Load Instruction
--				RegWrite 	<= '1';
--				MemtoReg 	<= '1';
--				MemWrite 	<= '0';
--				ALUControl	<= "100000"; -- Add
--
--			ELSIF (OpCode (2 DOWNTO 0) = "101") THEN -- Store Instruction
--				RegWrite 	<= '0';
--				MemtoReg 	<= '0';
--				MemWrite 	<= '1';
--				ALUControl	<= "100000"; -- Add
--
--			ELSIF (OpCode = "000100") THEN -- Branch on Equal
--				RegWrite 	<= '0';
--				MemtoReg 	<= '0';
--				MemWrite 	<= '0';
--				ALUControl	<= "100010"; -- Sub
--				Branch 		<= '1';
--
--			ELSIF (OpCode = "000001") THEN -- Branch on Greater Than Equal Zero
--				RegWrite 	<= '0';
--				MemtoReg 	<= '0';
--				MemWrite 	<= '0';
--				ALUControl	<= "100000"; -- Add
--				Branch 		<= '1';
--
--			ELSIF (OpCode = "000111") THEN -- Branch on Greater Than Zero
--				RegWrite 	<= '0';
--				MemtoReg 	<= '0';
--				MemWrite 	<= '0';
--				ALUControl	<= "100000"; -- Add
--				Branch 		<= '1';
--
--			ELSIF (OpCode = "000110") THEN -- Branch on Less Than Equal Zero
--				RegWrite 	<= '0';
--				MemtoReg 	<= '0';
--				MemWrite 	<= '0';
--				ALUControl	<= "100000"; -- Add
--				Branch 		<= '1';
--
--			ELSIF (OpCode = "000001") THEN -- Branch On Less Than Zero
--				RegWrite 	<= '0';
--				MemtoReg 	<= '0';
--				MemWrite 	<= '0';
--				ALUControl	<= "100000"; -- Add
--				Branch 		<= '1';
--
--			ELSIF (OpCode = "000101") THEN -- Branch On Not Equal
--				RegWrite 	<= '0';
--				MemtoReg 	<= '0';
--				MemWrite 	<= '0';
--				ALUControl	<= "100011"; -- Sub
--				Branch 		<= '1';
--
--			END IF;
--			dsize <= OpCode (2 DOWNTO 0);
--		ELSIF (JTYPE = '1') THEN	-- Jump, Jump and Link
--			RegDest 	<= '0';
--			RegWrite 	<= '0';
--			ALUSrc 		<= '0';
--			MemWrite 	<= '0';
--			MemtoReg 	<= '0';
--			ALUControl 	<= Funct;
--			Branch 		<= '0';
--			JumpOut		<= '1';
--		END IF;
--
--		-- TEMP: Doing this while we ignore J-Type instructions
--		Branch <= '0';
--
--	END PROCESS;
--END arch;
