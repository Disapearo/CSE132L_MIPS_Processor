LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY processor IS
	PORT (clk : IN std_logic ;
		reset : IN std_logic );
END processor ;


ARCHITECTURE arch OF processor IS

	COMPONENT PC IS
		PORT (ref_clk: IN STD_LOGIC;
			pc_reset : IN STD_LOGIC;
			pc_in:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			pc_out: OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT adder IS
		GENERIC(addr_size : INTEGER := 32);
		PORT (oldcounter: IN STD_LOGIC_VECTOR(addr_size - 1 DOWNTO 0);
			inc: IN STD_LOGIC_VECTOR(addr_size - 1 DOWNTO 0);
				newcounter: OUT STD_LOGIC_VECTOR(addr_size - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT controller IS
		PORT (Funct, OpCode : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			MemtoReg, MemWrite, MemRead, Branch, ALUSrc, RegDest, RegWrite, JumpOut : OUT STD_LOGIC;
			ALUControl : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			dsize : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
	END COMPONENT;

	COMPONENT imem IS -- instruction memory
		port(addr: IN STD_LOGIC_VECTOR(5 downto 0);
		rd: OUT STD_LOGIC_VECTOR(31 downto 0));
	END COMPONENT;

--	COMPONENT synth_imem IS -- instruction memory (For Synthesis)
--		port(addr: IN STD_LOGIC_VECTOR(5 downto 0);
--		rd: OUT STD_LOGIC_VECTOR(31 downto 0));
--	END COMPONENT;

	COMPONENT regfile IS
		GENERIC ( NBIT : INTEGER := 32;
			NSEL : INTEGER := 5);
		PORT (ref_clk : IN std_logic ;
			rst_s : IN std_logic ; -- synchronous reset
			we : IN std_logic ; -- write enable
			raddr_1 : IN std_logic_vector ( NSEL -1 DOWNTO 0); -- read address 1
			raddr_2 : IN std_logic_vector ( NSEL -1 DOWNTO 0); -- read address 2
			waddr : IN std_logic_vector ( NSEL -1 DOWNTO 0); -- write address
			rdata_1 : OUT std_logic_vector ( NBIT -1 DOWNTO 0); -- read data 1
			rdata_2 : OUT std_logic_vector ( NBIT -1 DOWNTO 0); -- read data 2
			wdata : IN std_logic_vector ( NBIT -1 DOWNTO 0)); -- write data 1
	END COMPONENT;

	COMPONENT alu IS
		PORT (Func_in : IN std_logic_vector (5 DOWNTO 0);
			SHAMT : IN std_logic_vector (4 DOWNTO 0);
			A_in : IN std_logic_vector (31 DOWNTO 0);
			B_in : IN std_logic_vector (31 DOWNTO 0);
			O_out : OUT std_logic_vector (31 DOWNTO 0);
			Branch_out : OUT std_logic );
	END COMPONENT;

	COMPONENT ram IS
		PORT (ref_clk : IN std_logic ;
			we, re : IN std_logic ;
			dsize : IN std_logic_vector (2 DOWNTO 0);
			addr 	: IN std_logic_vector (31 DOWNTO 0);
			dataI 	: IN std_logic_vector (31 DOWNTO 0);
			dataO 	: OUT std_logic_vector (31 DOWNTO 0));	
	END COMPONENT;

--	COMPONENT dmem IS
--		PORT(
--		ref_clk, we : IN std_logic;
--		a, wd: IN std_logic_vector (31 DOWNTO 0);
--		rd : OUT std_logic_vector (31 DOWNTO 0));
--	END COMPONENT;

	SIGNAL Instr_Addr: STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL Instr : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL OpCode, Funct : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL RS, RT, RD, SHAMT : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL BitImmediate_16 : STD_LOGIC_VECTOR (15 DOWNTO 0);

	SIGNAL MemtoReg, MemWrite, MemRead, Branch, ALUSrc, RegDest, RegWrite, JumpOut : STD_LOGIC;
	SIGNAL ALUControl : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL dsize : STD_LOGIC_VECTOR (2 DOWNTO 0);

	SIGNAL RegDest_Mux : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ALUSrc_Mux, MemtoReg_Mux, Branch_Mux, new_immed : STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL RegOut1, RegOut2, ALUresult, WriteBack : STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL BranchOut : STD_LOGIC;

	SIGNAL ShiftLeft : STD_LOGIC_VECTOR (27 DOWNTO 0);
	SIGNAL shiftleft_im : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL AddALU_Result : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL JumpAddress : STD_LOGIC_VECTOR (31 DOWNTO 0);

	TYPE pipelineRegisterIF_ID IS ARRAY (0 TO 2) OF STD_LOGIC_VECTOR (31 DOWNTO 0);		-- Instr, PC4
	SIGNAL IF_ID : pipelineRegisterIF_ID;

	TYPE pipelineRegisterID_EX IS ARRAY (0 TO 16) OF STD_LOGIC_VECTOR (31 DOWNTO 0);	-- Instr, 10 Control, PC4, RegOut1, RegOut2, new_immed, RT, RD
	SIGNAL ID_EX : pipelineRegisterID_EX;

	TYPE pipelineRegisterEX_Mem IS ARRAY (0 TO 12) OF STD_LOGIC_VECTOR (31 DOWNTO 0);	-- PC4, 7 Control, AddALU_Result, ALUresult, BranchOut, RegOut2, RegDest_Mux
	SIGNAL EX_Mem : pipelineRegisterEX_Mem;

	TYPE pipelineRegisterMem_WB IS ARRAY (0 TO 4) OF STD_LOGIC_VECTOR (31 DOWNTO 0);	-- ALUResult, 2 Control: MemtoReg & RegWrite, ReDest_Mux, WriteBack
	SIGNAL Mem_WB : pipelineRegisterMem_WB;


	-- NEW -- TODO: Organize this
	SIGNAL New_PC : STD_LOGIC_VECTOR (31 DOWNTO 0) := X"00000000"; -- Initialize to PC = 0
	SIGNAL pc4 : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL BranchAndGate : STD_LOGIC;

BEGIN
---------- IF ---------- PC Mux, PC, InstrMem, PC Adder
-- PC
	ProgCnt : PC PORT MAP(clk, reset, New_PC, Instr_Addr); 		-- TODO: Connect New_PC to Branch/Jump datapath
-- PC Adder
	PCAdder: adder 
		GENERIC MAP (32)
		PORT MAP (Instr_Addr, X"00000001", pc4); -- Pass a constant or change Paul's code?
-- Instruction Memory (Use either imem OR synth_imem, not both!)
	IMEM_1 : imem PORT MAP(Instr_Addr(5 DOWNTO 0), Instr);		--NOR Reg(0) & Reg(1) into Reg(2)
--	IMEM_1 : synth_imem PORT MAP(Instr_Addr(5 DOWNTO 0), Instr);	-- Synthesis version

---------- IF/ID ---------- Instr, PC4
	IF_ID(0) <= pc4;
	IF_ID(1) <= Instr;
	IF_ID(2) <= Instr_Addr;
---------- ID ---------- RegFile, Sign Extend, Controller, Shift Left 2
-- Instruction Breakdown
	OpCode <= IF_ID(1)(31 DOWNTO 26);
	RS <= IF_ID(1)(25 DOWNTO 21);
	RT <= IF_ID(1)(20 DOWNTO 16);
	RD <= IF_ID(1)(15 DOWNTO 11);
	SHAMT <= IF_ID(1)(10 DOWNTO 6);
	Funct <= IF_ID(1)(5 DOWNTO 0);
	BitImmediate_16 <= IF_ID(1)(15 DOWNTO 0);
-- Controller
	C1: controller PORT MAP(Funct, OpCode, MemtoReg, MemWrite, MemRead, Branch, ALUSrc, RegDest, RegWrite, JumpOut, ALUControl, dsize);
-- Register File
	R1 : regfile
		GENERIC MAP (32, 5)
		PORT MAP (clk, reset, Mem_WB(2)(31), RS, RT, RegDest_Mux, RegOut1, RegOut2, MemToReg_Mux);		-- RegWrite
-- Sign Extend
	Sign_Expand: FOR i IN 0 TO 31 GENERATE
		
		not_fill: IF i <= 15 GENERATE
			new_immed(i) <= IF_ID(1)(i);
		END GENERATE not_fill;

		fill: IF i > 15 GENERATE
			new_immed(i) <= IF_ID(1)(15);
		END GENERATE fill;

	END GENERATE Sign_Expand;
-- Shift Left 2
	shiftleft <= IF_ID(1)(25 DOWNTO 0) & "00"; --TO_STDLOGICVECTOR(TO_BITVECTOR(Instr(25 DOWNTO 0)) sll 2);
--Jump Adress
	JumpAddress <= IF_ID(2)(31 DOWNTO 28) & shiftleft;

---------- ID/EX ---------- Instr, 10 Control, PC4, RegOut1, RegOut2, new_immed, RT, RD
	ID_EX(0) <= IF_ID(0);			-- PC4
	ID_EX(1) <= IF_ID(1);			-- Instr
	ID_EX(2)(0) <= MemtoReg;
	ID_EX(3)(0) <= MemWrite;
	ID_EX(4)(0) <= MemRead;
	ID_EX(5)(0) <= Branch;
	ID_EX(6)(0) <= ALUSrc;
	ID_EX(7)(0) <= RegDest;
	ID_EX(8)(0) <= RegWrite;
	ID_EX(9)(0) <= JumpOut;
	ID_EX(10)(5 DOWNTO 0) <= ALUControl;
	ID_EX(11)(2 DOWNTO 0) <= dsize;
	ID_EX(12) <= RegOut1;
	ID_EX(13) <= RegOut2;
	ID_EX(14) <= new_immed;
	ID_EX(15)(4 DOWNTO 0) <= RT;
	ID_EX(16)(4 DOWNTO 0) <= RD;

---------- EX ---------- ALU, SL2, Norm Adder
-- RegDest Mux
	RegDest_Mux <= ID_EX(15)(4 DOWNTO 0) WHEN (ID_EX(7)(0) = '0') ELSE			-- RT
		ID_EX(16)(4 DOWNTO 0) WHEN (ID_EX(7)(0) = '1');				-- RD
-- ALUSrc Mux
	ALUSrc_Mux <= ID_EX(13) WHEN (ID_EX(6)(0) = '0') ELSE			-- RegOut2
		ID_EX(14) WHEN (ID_EX(6)(0) = '1');				-- new_immed
-- ALU
	A1 : alu PORT MAP (ID_EX(10)(5 DOWNTO 0), ID_EX(1)(10 DOWNTO 6), ID_EX(12), ALUSrc_Mux, ALUresult, BranchOut);	-- ALUControl, SHAMT, RegOut1
-- Shift Left 2 Immediate
	shiftleft_im <= TO_STDLOGICVECTOR(TO_BITVECTOR(ID_EX(14)) sll 2);	-- new_immed
-- Normal Adder
	NormAdder: adder
		GENERIC MAP(32)
		PORT MAP(ID_EX(0), shiftleft_im, AddALU_Result);			-- PC4

---------- EX/Mem ---------- PC4, 7 Control, AddALU_Result, ALUResult, BranchOut, RegOut2, RegDest_Mux
	EX_Mem(0) <= ID_EX(0);				-- PC4
	EX_Mem(1)(0) <= ID_EX(2)(0);			-- MemtoReg
	EX_Mem(2)(0) <= ID_EX(3)(0);			-- MemWrite
	EX_Mem(3)(0) <= ID_EX(4)(0);			-- MemRead
	EX_Mem(4)(0) <= ID_EX(5)(0);			-- Branch
	EX_Mem(5)(0) <= ID_EX(8)(0);			-- RegWrite
	EX_Mem(6)(0) <= ID_EX(9)(0);			-- JumpOut
	EX_Mem(7)(2 DOWNTO 0) <= ID_EX(11)(2 DOWNTO 0);	-- dsize
	EX_Mem(8) <= AddALU_Result;
	EX_Mem(9) <= ALUresult;
	EX_Mem(10)(0) <= BranchOut;
	EX_Mem(11) <= ID_EX(13);			-- RegOut2
	EX_Mem(12)(4 DOWNTO 0) <= RegDest_Mux;

---------- Mem ---------- DataMem, Jump Mux, Branch Mux
---- Data Memory
	Ram1: ram PORT MAP (clk, EX_Mem(2)(0), EX_Mem(3)(0), EX_Mem(7)(2 DOWNTO 0), EX_Mem(9), EX_Mem(11), WriteBack);		-- MemWrite, MemRead, dsize, ALUresult, RegOut2
--	RAM: dmem PORT MAP ( -- USE FOR SYNTHESIS APPROX. ONLY
--		ref_clk => clk, we => MemWrite, 
--		a => ALUresult, wd => RegOut2, rd => WriteBack);
-- Branch And Gate
	BranchAndGate <= EX_Mem(10)(0) AND EX_Mem(4)(0);			-- BranchOut, Branch
--Branch Mux
	Branch_Mux <= EX_Mem(8) WHEN (BranchAndGate = '1') ELSE			-- AddALU_Result
		      EX_Mem(0) WHEN (BranchAndGate = '0');			-- PC4
--Jump Mux
	New_PC <= Branch_Mux WHEN (EX_Mem(6)(0) = '0') ELSE			-- JumpOut
		    JumpAddress WHEN (EX_Mem(6)(0) = '1');			-- JumpOut

---------- Mem/WB ---------- ALUresult, 2 Control: MemtoReg & RegWrite, RegDest_Mux, WriteBack
	Mem_WB(0)(0) <= EX_Mem(9)(0);				-- ALUresult
	Mem_WB(1)(0) <= EX_Mem(1)(0);				-- MemtoReg
	Mem_WB(2)(0) <= EX_Mem(5)(0);				-- RegWrite
	Mem_WB(3)(4 DOWNTO 0) <= EX_Mem(12)(4 DOWNTO 0);	-- RegDest_Mux
	Mem_WB(4) <= WriteBack;

---------- WB ----------
-- MemToRegMux
	MemToReg_Mux <= Mem_WB(0) WHEN (Mem_WB(1)(0) = '0') ELSE	-- ALUresult, MemtoReg
		Mem_WB(4) WHEN (Mem_WB(1)(0) = '1');			-- WriteBack, MemtoReg

END arch;
