LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controller IS
	PORT (ref_clk, rst : IN STD_LOGIC;
		Funct, OpCode : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		MemtoReg, MemWrite, MemRead, Branch, ALUSrcA, RegDest, RegWrite, IRWrite, PCWrite, IorD : OUT STD_LOGIC; --JumpOut, IorD : OUT STD_LOGIC;
		ALUSrcB, PCSrc : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUControl : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		dsize : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
END controller;


ARCHITECTURE arch OF controller IS

	TYPE state is (Fetch, Decode, MemAdr, MemoryRead, MemWB, MemoryWrite, RExe, ALUWB, BranchExe, ADDIExe, ADDIWB, Jump);
	SIGNAL pr_state, nx_state : state; --These signals, at any time, will be just 1 of the states/items mentioned above
	
	SIGNAL temp_MemtoReg, temp_MemW, temp_MemR, temp_Branch, temp_ALUSrcA, temp_RegDst, temp_RegW, temp_IRW, temp_PCW, temp_IorD : STD_LOGIC;

	SIGNAL temp_ALUSrcB, temp_PCSrc : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL temp_ALUControl : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL temp_dsize : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN --Synchronous Output, so a lot of temp signals

-------------------Sequential logic-----------------------------

	PROCESS(ref_clk, rst)
	BEGIN
		IF (rst = '1') THEN
			pr_state <= Fetch;

		ELSIF (ref_clk'EVENT and ref_clk ='1') THEN
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
			PCWrite <= temp_PCW;
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
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '0';
				temp_ALUSrcB <= "01";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '1';
				temp_PCSrc <= "00";
				temp_PCW <= '1';
				temp_IorD <= '0';
				temp_ALUControl <= "100000";
				temp_dsize <= "000";
				nx_state <= Decode;
			WHEN Decode =>
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '0';
				temp_ALUSrcB <= "11";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '0';
				temp_ALUControl <= "100000";
				temp_dsize <= "000";
				IF (OpCode(5 DOWNTO 4) = "10") THEN
					nx_state <= MemAdr;
				ELSIF (OpCode = "000000") THEN
					nx_state <= RExe;
				ELSIF (OpCode(5 DOWNTO 1) = "00001") THEN
					nx_state <= Jump;
				ELSIF (OpCode = "000100" OR OpCode = "000001" OR OpCode = "000111" OR OpCode = "000110" OR OpCode = "000101")THEN
					nx_state <= BranchExe;
				ELSIF (OpCode(5 DOWNTO 3) = "001") THEN
					nx_state <= ADDIExe;
				END IF;
			WHEN MemAdr =>
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '1';
				temp_ALUSrcB <= "10";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '0';
				IF (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101" OR OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") THEN
					temp_ALUControl <= "100000";	-- LW, LB, LH, LBU, LHU, SW, SB, SH (Add)
				END IF;
				temp_dsize <= "000";
				IF (OpCode(5 DOWNTO 3) = "100") THEN
					nx_state <= MemoryRead;
				ELSIF (OpCode(5 DOWNTO 3) = "101") THEN
					nx_state <= MemoryWrite;
				END IF; 
			WHEN MemoryRead =>
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '1';
				temp_Branch <= '0';
				temp_ALUSrcA <= '0';
				temp_ALUSrcB <= "00";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '1';
				temp_ALUControl <= "000000";	
				temp_dsize <= OpCode(2 DOWNTO 0);
				nx_state <= MemWB;
			WHEN MemWB =>
				temp_MemtoReg <= '1';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '0';
				temp_ALUSrcB <= "00";
				temp_RegDst <= '0';
				temp_RegW <= '1';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '0';
				temp_ALUControl <= "000000";
				temp_dsize <= OpCode(2 DOWNTO 0);
				nx_state <= Fetch;
			WHEN MemoryWrite =>
				temp_MemtoReg <= '0';
				temp_MemW <= '1';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '0';
				temp_ALUSrcB <= "00";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '1';
				temp_ALUControl <= "000000";
				temp_dsize <= OpCode(2 DOWNTO 0);
				nx_state <= Fetch;
			WHEN RExe =>
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '1';
				temp_ALUSrcB <= "00";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '0';
				temp_ALUControl <= Funct;
				temp_dsize <= "000";
				nx_state <= ALUWB;
			WHEN ALUWB =>
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '0';
				temp_ALUSrcB <= "00";
				temp_RegDst <= '1';
				temp_RegW <= '1';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '0';
				temp_ALUControl <= "000000";
				temp_dsize <= "000";
				nx_state <= Fetch;
			WHEN BranchExe =>
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '1';
				temp_ALUSrcA <= '1';
				temp_ALUSrcB <= "00";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '0';
				temp_PCSrc <= "01";
				temp_PCW <= '0';
				temp_IorD <= '0';
				IF (OpCode = "000100") THEN
					temp_ALUControl <= "110100";
				ELSIF (OpCode = "000101") THEN
					temp_ALUControl <= "110101";
				ELSIF (OpCode = "000001") THEN
					temp_ALUControl <= "110001";
				ELSIF (OpCode = "000001") THEN
					temp_ALUControl <= "110001";
				ELSIF (OpCode = "000110") THEN
					temp_ALUControl <= "110110";
				ELSIF (OpCode = "000111") THEN
					temp_ALUControl <= "110111";
				END IF;
				temp_dsize <= "000";
				nx_state <= Fetch;
			WHEN ADDIExe => --I say ADDI but it's really going to be all I-type instructions
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '1';
				temp_ALUSrcB <= "10";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '0';
				--temp_ALUControl <= "100100" WHEN (OpCode = "001100") ELSE												-- ANDI (Funct = AND Operation)
				--	      "100101" WHEN (OpCode = "001101") ELSE												-- ORI (Funct = OR Operation)
				--	      "100110" WHEN (OpCode = "001110") ELSE												-- XORI (Funct = XOR Operation)
				--	      "100000" WHEN (OpCode = "001000") ELSE												-- ADDI
				--	      "100001" WHEN (OpCode = "001001") ELSE												-- ADDIU
				--	      "101010" WHEN (OpCode = "001010") ELSE												-- SLTI
				--	      "101011" WHEN (OpCode = "001011") ELSE												-- SLTIU
				--	      "001111" WHEN (OpCode = "001111");												-- LUI

				IF (OpCode = "001100") THEN
					temp_ALUControl <= "100100";		-- ANDI (Funct = AND Operation)
				ELSIF (OpCode = "001101") THEN
					temp_ALUControl <= "100101";		-- ORI (Funct = OR Operation)
				ELSIF (OpCode = "001110") THEN
					temp_ALUControl <= "100110";		-- XORI (Funct = XOR Operation)
				ELSIF (OpCode = "001000") THEN
					temp_ALUControl <= "100000";		-- ADDI
				ELSIF (OpCode = "001001") THEN
					temp_ALUControl <= "100001";		-- ADDIU
				ELSIF (OpCode = "001010") THEN
					temp_ALUControl <= "101010";		-- SLTI
				ELSIF (OpCode = "001011") THEN
					temp_ALUControl <= "101011";		-- SLTIU
				ELSIF (OpCode = "001111") THEN
					temp_ALUControl <= "001111";		-- LUI
				END IF;
				temp_dsize <= "000";
				nx_state <= ADDIWB;
			WHEN ADDIWB =>
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '0';
				temp_ALUSrcB <= "00";
				temp_RegDst <= '0';
				temp_RegW <= '1';
				temp_IRW <= '0';
				temp_PCSrc <= "00";
				temp_PCW <= '0';
				temp_IorD <= '0';
				temp_ALUControl <= "000000";
				temp_dsize <= "000";
				nx_state <= Fetch;
			WHEN Jump =>
				temp_MemtoReg <= '0';
				temp_MemW <= '0';
				temp_MemR <= '0';
				temp_Branch <= '0';
				temp_ALUSrcA <= '0';
				temp_ALUSrcB <= "00";
				temp_RegDst <= '0';
				temp_RegW <= '0';
				temp_IRW <= '0';
				temp_PCSrc <= "10";
				temp_PCW <= '1';
				temp_IorD <= '0';
				temp_ALUControl <= Funct;
				temp_dsize <= "000";
				nx_state <= Fetch;
		END CASE;
	END PROCESS;
END arch;
