LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controller IS
	PORT (clk, rst : IN STD_LOGIC;
		Funct, OpCode : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		MemtoReg, MemWrite, MemRead, Branch, ALUSrcA, RegDest, RegWrite, IRWrite, PCWrite, IorD : OUT STD_LOGIC; --JumpOut, IorD : OUT STD_LOGIC;
		ALUSrcB, PCSrc : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUControl : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);--5 DOWNTO 0);
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

	TYPE state is (Fetch, Decode, MemAdr, MemoryRead, MemWB, MemoryWrite, RExe, ALUWB, BranchExe, ADDIExe, ADDIWB, Jump);
	SIGNAL pr_state, nx_state : state; --These signals, at any time, will be just 1 of the states/items mentioned above
	
	SIGNAL temp_MemtoReg, temp_MemW, temp_MemR, temp_Branch, temp_ALUSrcA, temp_RegDst, temp_RegW, temp_IRW, temp_PCW, temp_IorD : STD_LOGIC;

	SIGNAL temp_ALUSrcB, temp_PCSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL temp_ALUControl, temp_dsize : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN --Synchronous Output, so a lot of temp signals

-------------------Sequential logic-----------------------------

	PROCESS(clk, rst)
	BEGIN
		IF (rst = '1') THEN
			pr_state <= Fetch;

		ELSIF (clk'EVENT and clk ='1') THEN
			MemtoReg <= temp_MemtoReg;
			MemWrite <= temp_MemW;
			MemRead <= temp_MemR;
			Branch <= temp_Branch;
			ALUSrcA <= temp_ALUSrcA;
			ALUSrcB <= temp_ALUSrcB;
			RegDest <= temp_RegDst;
			RegWrite <= temp_RegW;
			IRWrite <= temp_IRW;
			PCSrc <= temp_PCSrc;
			PCWrite <= temp_PCWrite;
			IorD <= temp_IorD;
			ALUControl <= temp_ALUControl;
			dsize <= temp_dsize;
			pr_state <= nx_state;
		END IF;
	END PROCESS;

-------------------Combinational logic---------------------------

	PROCESS(OpCode, pr_state)
	BEGIN
		CASE pr_state IS
			WHEN Fetch =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "01";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '1';
				PCSrc <= "00";
				PCWrite <= '1';
				IorD <= '0';
				ALUControl <= "100000";
				dsize <= "000";
				nx_state <= Decode;
			WHEN Decode =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "11";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '0';
				ALUControl <= "100000";
				dsize <= "000";
				IF (OpCode(5 DOWNTO 4) = "10" THEN
					nx_state <= MemAdr;
				ELSIF (OpCode = "000000") THEN
					nx_state <= RExe;
				ELSIF (OpCode(5 DOWNTO 1) = "00001") THEN
					nx_state <= Jump;
				ELSIF THEN
					nx_state <= BranchExe;
				ELSIF (OpCode(5 DOWNTO 3) = "001") THEN
					nx_state <= ADDIExe;
				END IF;
			WHEN MemAdr =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '0';
				ALUControl <= "100000" WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101" OR OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001");	-- LW, LB, LH, LBU, LHU, SW, SB, SH (Add)

				dsize <= "000";
				IF (OpCode(5 DOWNTO 3) = "100") THEN
					nx_state <= MemeoryRead;
				ELSIF (OpCode(5 DOWNTO 3) = "101") THEN
					nx_state <= MemoryWrite;
				END IF; 
			WHEN MemoryRead =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '1';
				Branch <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "00";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '1';
				ALUControl <= "000000";	
				dsize <= OpCode(2 DOWNTO 0);
				nx_state <= MemWB;
			WHEN MemWB =>
				MemtoReg <= '1';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "00";
				RegDest <= '0';
				RegWrite <= '1';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '0';
				ALUControl <= "000000";
				dsize <= OpCode(2 DOWNTO 0);
				nx_state <= Fetch;
			WHEN MemoryWrite =>
				MemtoReg <= '0';
				MemWrite <= '1';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "00";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '1';
				ALUControl <= "000000";
				dsize <= OpCode(2 DOWNTO 0);
				nx_state <= Fetch;
			WHEN RExe =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '0';
				ALUControl <= Funct;
				dsize <= "000";
				nx_state <= ALUWB;
			WHEN ALUWB =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "00";
				RegDest <= '1';
				RegWrite <= '1';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '0';
				ALUControl <= "000000";
				dsize <= "000";
				nx_state <= Fetch;
			WHEN BranchExe =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '0';
				PCSrc <= "01";
				PCWrite <= '0';
				IorD <= '0';
				ALUControl <= "110100" WHEN (OpCode = "000100") ELSE												-- BEQ
					      "110101" WHEN (OpCode = "000101") ELSE												-- BNE
					      "110001" WHEN (OpCode = "000001") ELSE												-- BLZ
					      "110001" WHEN (OpCode = "000001") ELSE												-- BGEZ
					      "110110" WHEN (OpCode = "000110") ELSE												-- BLEZ
					      "110111" WHEN (OpCode = "000111");												-- BGZ
				dsize <= "000";
				nx_state <= Fetch;
			WHEN ADDIExe => --I say ADDI but it's really going to be all I-type instructions
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '0';
				ALUControl <= "100100" WHEN (OpCode = "001100") ELSE												-- ANDI (Funct = AND Operation)
					      "100101" WHEN (OpCode = "001101") ELSE												-- ORI (Funct = OR Operation)
					      "100110" WHEN (OpCode = "001110") ELSE												-- XORI (Funct = XOR Operation)
					      "100000" WHEN (OpCode = "001000") ELSE												-- ADDI
					      "100001" WHEN (OpCode = "001001") ELSE												-- ADDIU
					      "101010" WHEN (OpCode = "001010") ELSE												-- SLTI
					      "101011" WHEN (OpCode = "001011") ELSE												-- SLTIU
					      "001111" WHEN (OpCode = "001111");												-- LUI
				dsize <= "000";
				nx_state <= ADDIWB;
			WHEN ADDIWB =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "00";
				RegDest <= '0';
				RegWrite <= '1';
				IRWrite <= '0';
				PCSrc <= "00";
				PCWrite <= '0';
				IorD <= '0';
				ALUControl <= "000000";
				dsize <= "000";
				nx_state <= Fetch;
			WHEN Jump =>
				MemtoReg <= '0';
				MemWrite <= '0';
				MemRead <= '0';
				Branch <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "00";
				RegDest <= '0';
				RegWrite <= '0';
				IRWrite <= '0';
				PCSrc <= "10";
				PCWrite <= '1';
				IorD <= '0';
				ALUControl <= Funct;
				dsize <= "000";
				nx_state <= Fetch;
	END PROCESS;
END arch;
