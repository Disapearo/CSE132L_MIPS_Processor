LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controller IS
	PORT (clk, rst : 		IN STD_LOGIC;
		Funct, OpCode : 	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		MemtoReg, MemWrite, MemRead, Branch, ALUSrcA, RegDest, RegWrite, IRWrite, PCWrite, IorD : OUT STD_LOGIC;
		ALUSrcB, PCSrc : 	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		ALUControl : 		OUT STD_LOGIC_VECTOR (2 DOWNTO 0);--5 DOWNTO 0);
		dsize : 			OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
END controller;

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
			MemtoReg 	<= temp_MemtoReg;
			MemWrite 	<= temp_MemW;
			MemRead 	<= temp_MemR;
			Branch 		<= temp_Branch;
			ALUSrcA 	<= temp_ALUSrcA;
			ALUSrcB 	<= temp_ALUSrcB;
			RegDest 	<= temp_RegDst;
			RegWrite 	<= temp_RegW;
			IRWrite 	<= temp_IRW;
			PCSrc 		<= temp_PCSrc;
			PCWrite 	<= temp_PCW;
			IorD 		<= temp_IorD;
			ALUControl 	<= temp_ALUControl;
			dsize 		<= temp_dsize;
			pr_state 	<= nx_state;
		END IF;
	END PROCESS;

-------------------Combinational logic---------------------------

	PROCESS(OpCode, pr_state)
	BEGIN
		CASE pr_state IS
			WHEN Fetch =>
				MemtoReg 	<= ;
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '0';
				ALUSrcB 	<= "01";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '1';
				PCSrc 		<= "00";
				PCWrite 	<= '1';
				IorD 		<= '0';
				ALUControl 	<= ;
				dsize 		<= ;
				nx_state 	<= Decode;
			WHEN Decode =>
				MemtoReg 	<= ;
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= '0';
				ALUSrcA 	<= '0';
				ALUSrcB 	<= "11";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '0';
				IorD 		<= '';
				ALUControl 	<= ;
				dsize 		<= ;
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
				MemtoReg 	<= ;
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '1';
				ALUSrcB 	<= "10";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '';
				IorD 		<= '';
				ALUControl 	<= ;
				dsize 		<= ;
				IF (OpCode(5 DOWNTO 3) = "100") THEN
					nx_state <= MemeoryRead;
				ELSIF (OpCode(5 DOWNTO 3) = "101") THEN
					nx_state <= MemoryWrite;
				END IF; 
			WHEN MemoryRead =>
				MemtoReg 	<= ;
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '';
				ALUSrcB 	<= "";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '';
				IorD 		<= '1';
				ALUControl 	<= "100000" WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101");	-- LW, LB, LH, LBU, LHU (Add)
				dsize 		<= OpCode(2 DOWNTO 0);
				nx_state 	<= MemWB;
			WHEN MemWB =>
				MemtoReg 	<= '1';
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '';
				ALUSrcB 	<= "";
				RegDest 	<= '0';
				RegWrite 	<= '1';
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '';
				IorD 		<= '';
				ALUControl 	<= ;
				dsize 		<= OpCode(2 DOWNTO 0);
				nx_state 	<= Fetch;
			WHEN MemoryWrite =>
				MemtoReg 	<= ;
				MemWrite 	<= '1';
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '';
				ALUSrcB 	<= "";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '';
				IorD 		<= '1';
				ALUControl 	<= "100000" WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001");	 						-- SW, SB, SH (Add)
				dsize 		<= OpCode(2 DOWNTO 0);
				nx_state 	<= Fetch;
			WHEN RExe =>
				MemtoReg 	<= ;
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '1';
				ALUSrcB 	<= "00";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '';
				IorD 		<= '';
				ALUControl 	<= Funct;
				dsize 		<= ;
				nx_state <= ALUWB;
			WHEN ALUWB =>
				MemtoReg 	<= '0';
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '';
				ALUSrcB 	<= "";
				RegDest 	<= '1';
				RegWrite 	<= '1';
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '';
				IorD 		<= '';
				ALUControl 	<= ;
				dsize 		<= ;
				nx_state 	<= Fetch;
			WHEN BranchExe =>
				MemtoReg 	<= ;
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= '1';
				ALUSrcA 	<= '1';
				ALUSrcB 	<= "00";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '';
				PCSrc 		<= "01";
				PCWrite 	<= '';
				IorD 		<= '';
				ALUControl 	<= "110100" WHEN (OpCode = "000100") ELSE												-- BEQ
					    		"110101" WHEN (OpCode = "000101") ELSE												-- BNE
					    		"110001" WHEN (OpCode = "000001") ELSE												-- BLZ
					    		"110001" WHEN (OpCode = "000001") ELSE												-- BGEZ
					    		"110110" WHEN (OpCode = "000110") ELSE												-- BLEZ
					    		"110111" WHEN (OpCode = "000111");												-- BGZ
				dsize 		<= ;
				nx_state 	<= Fetch;
			WHEN ADDIExe => --I say ADDI but it's really going to be all I-type instructions
				MemtoReg 	<= ;
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '1';
				ALUSrcB 	<= "10";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '';
				IorD 		<= '';
				ALUControl 	<= "100100" WHEN (OpCode = "001100") ELSE												-- ANDI (Funct = AND Operation)
								"100101" WHEN (OpCode = "001101") ELSE												-- ORI (Funct = OR Operation)
					    		"100110" WHEN (OpCode = "001110") ELSE												-- XORI (Funct = XOR Operation)
					    		"100000" WHEN (OpCode = "001000") ELSE												-- ADDI
					    		"100001" WHEN (OpCode = "001001") ELSE												-- ADDIU
					    		"101010" WHEN (OpCode = "001010") ELSE												-- SLTI
					    		"101011" WHEN (OpCode = "001011") ELSE												-- SLTIU
					    		"001111" WHEN (OpCode = "001111");													-- LUI
				dsize 		<= ;
				nx_state 	<= ADDIWB;
			WHEN ADDIWB =>
				MemtoReg 	<= '0';
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '';
				ALUSrcB 	<= "";
				RegDest 	<= '0';
				RegWrite 	<= '1';
				IRWrite 	<= '';
				PCSrc 		<= "";
				PCWrite 	<= '';
				IorD 		<= '';
				ALUControl 	<= ;
				dsize 		<= ;
				nx_state 	<= Fetch;
			WHEN Jump =>
				MemtoReg 	<= ;
				MemWrite 	<= ;
				MemRead 	<= ;
				Branch 		<= ;
				ALUSrcA 	<= '';
				ALUSrcB 	<= "";
				RegDest 	<= ;
				RegWrite 	<= ;
				IRWrite 	<= '1';
				PCSrc 		<= "10";
				PCWrite 	<= '1';
				IorD 		<= '';
				ALUControl 	<= Funct;
				dsize 		<= ;
				nx_state 	<= Fetch;
	END PROCESS;



	MemtoReg <=  '0' WHEN (OpCode = "000000") ELSE																						-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE																		-- JType
		     '1' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE		-- LW, LB, LH, LBU, LHU
		     '0' WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE	 											-- SW, SB, SH
		     '0' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE		-- Branch
		     '0';																														-- Everything else

	MemWrite <=  '0' WHEN (OpCode = "000000") ELSE																						-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE																		-- JType
		     '0' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE		-- LW, LB, LH, LBU, LHU
		     '1' WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE	 											-- SW, SB, SH
		     '0' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE		-- Branch
		     '0';																														-- Everything else

	MemRead	 <=  '0' WHEN (OpCode = "000000") ELSE                                                                                                  	-- RType
				'0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE                                                                             -- JType
                '1' WHEN (OpCode = "100011" OR OpCode = "100000" OR OpCode = "100001" OR OpCode = "100100" OR OpCode = "100101") ELSE              -- LW, LB, LH, LBU, LHU
                '0' WHEN (OpCode = "101011" OR OpCode = "101000" OR OpCode = "101001") ELSE                                                        -- SW, SB, SH
                '0' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE              -- Branch
                '0'; 

	Branch <=    '1' WHEN (OpCode = "000100" OR OpCode = "000101" OR OpCode = "000001" OR OpCode = "000110" OR OpCode = "000111") ELSE '0';		-- Branch

	ALUSrc <=    '0' WHEN (OpCode = "000000") ELSE								-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE				-- JType
		     '1';																-- IType

	RegDest <=   '1' WHEN (OpCode = "000000") ELSE								-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE				-- JType
		     '0';																-- IType

	RegWrite <=  '1' WHEN (OpCode = "000000") ELSE											-- RType
		     '0' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE							-- JType
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

	JumpOut <=   '1' WHEN (OpCode = "000000" AND (Funct = "001001" OR Funct = "001000")) ELSE			-- RType, Funct = JALR or JR
		     '0' WHEN (OpCode = "000000" AND (Funct /= "001001" OR Funct /= "001000")) ELSE				-- RType, Funct /= JALR or JR
		     '1' WHEN (OpCode = "000010" OR OpCode = "000011") ELSE										-- JType
		     '0';																						-- IType

	ALUControl <= Funct WHEN (OpCode = "000000") ELSE												-- RType
		      Funct WHEN (OpCode = "000010" OR OpCode = "000011") ELSE								-- JType
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
		      "110111" WHEN (OpCode = "000111");													-- BGZ

	dsize <=  OpCode (2 DOWNTO 0);

END arch;
