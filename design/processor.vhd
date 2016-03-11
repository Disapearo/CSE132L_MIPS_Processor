LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY processor IS
	PORT (clk : IN std_logic ;
		reset : IN std_logic );
END processor ;


ARCHITECTURE arch OF processor IS

	COMPONENT PC IS
		PORT (ref_clk: IN STD_LOGIC;
			pc_reset : IN STD_LOGIC;
			pc_in:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			PCWrite: IN STD_LOGIC;
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
			ControlSel : IN STD_LOGIC;
			MemtoReg, MemWrite, MemRead, Branch, ALUSrc, RegDest, RegWrite, JumpOut : OUT STD_LOGIC;
			ALUControl : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			dsize : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
	END COMPONENT;

--	COMPONENT imem IS -- instruction memory
--		port(addr: IN STD_LOGIC_VECTOR(5 downto 0);
--		rd: OUT STD_LOGIC_VECTOR(31 downto 0));
--	END COMPONENT;

	COMPONENT synth_imem IS -- instruction memory (For Synthesis)
		port(addr: IN STD_LOGIC_VECTOR(5 downto 0);
		rd: OUT STD_LOGIC_VECTOR(31 downto 0));
	END COMPONENT;

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

	COMPONENT hazard IS
		PORT (ID_EX_MemRead : IN STD_LOGIC;
			EX_Mem_MemRead : IN STD_LOGIC;
			ID_EX_RegWrite : IN STD_LOGIC;
			IF_ID_Rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			IF_ID_Rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			ID_EX_Rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			ID_EX_Rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			EX_MEM_Rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			OpCode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			PCWrite : OUT STD_LOGIC;
			IF_ID_Write : OUT STD_LOGIC;
			ControlSel : OUT STD_LOGIC;
			Load_EX_Flush : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT BranchComparator IS
		PORT (In1, In2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			BEQ : OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT alu IS
		PORT (Func_in : IN std_logic_vector (5 DOWNTO 0);
			SHAMT : IN std_logic_vector (4 DOWNTO 0);
			A_in : IN std_logic_vector (31 DOWNTO 0);
			B_in : IN std_logic_vector (31 DOWNTO 0);
			O_out : OUT std_logic_vector (31 DOWNTO 0));
--			Branch_out : OUT std_logic );
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

	COMPONENT forward IS
		PORT (ID_EX_Rs, ID_EX_Rt : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			IF_ID_Rs, IF_ID_Rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			EX_MEM_Rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			EX_MEM_RegWrite : IN STD_LOGIC;
			MEM_WB_Rd : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			MEM_WB_RegWrite : IN STD_LOGIC;
			IDRegDataA, IDRegDataB : OUT STD_LOGIC; --_VECTOR(1 DOWNTO 0);
			ALUSrcA, ALUSrcB : OUT STD_LOGIC_VECTOR (1 DOWNTO 0));

	END COMPONENT;

	SIGNAL Instr_Addr: STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL Instr : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL OpCode, Funct : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL RS, RT, RD, SHAMT : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL BitImmediate_16 : STD_LOGIC_VECTOR (15 DOWNTO 0);

	SIGNAL MemtoReg, MemWrite, MemRead, Branch, ALUSrc, RegDest, RegWrite, JumpOut : STD_LOGIC;
	SIGNAL ALUControl : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL dsize : STD_LOGIC_VECTOR (2 DOWNTO 0);

	SIGNAL PCWrite, IF_ID_Write, ControlSel, Load_EX_Flush : STD_LOGIC;

	SIGNAL IDRegDataA, IDRegDataB : STD_LOGIC; 

	SIGNAL ALUSrcA, ALUSrcB : STD_LOGIC_VECTOR (1 DOWNTO 0);

	SIGNAL RegDest_Mux : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ALUin1_MUX, ALUin2_MUX, ALUSrc_Mux, Compare1_MUX, Compare2_MUX, MemtoReg_Mux, Branch_Mux, new_immed : STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL RegOut1, RegOut2, ALUresult, WriteBack : STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL BEQ : STD_LOGIC;

	SIGNAL ShiftLeft : STD_LOGIC_VECTOR (27 DOWNTO 0);
	SIGNAL shiftleft_im : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL AddALU_Result : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL JumpAddress : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');

	TYPE pipelineRegisterIF_ID IS ARRAY (0 TO 1) OF STD_LOGIC_VECTOR (31 DOWNTO 0);		-- Instr, PC4
	SIGNAL IF_ID : pipelineRegisterIF_ID;

	TYPE pipelineRegisterID_EX IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR (31 DOWNTO 0);	-- Instr, 10 Control, PC4, RegOut1, RegOut2, new_immed, RT, RD
	SIGNAL ID_EX : pipelineRegisterID_EX;

	TYPE pipelineRegisterEX_Mem IS ARRAY (0 TO 11) OF STD_LOGIC_VECTOR (31 DOWNTO 0);	-- PC4, 7 Control, AddALU_Result, ALUresult, BranchOut, RegOut2, RegDest_Mux
	SIGNAL EX_Mem : pipelineRegisterEX_Mem;

	TYPE pipelineRegisterMem_WB IS ARRAY (0 TO 5) OF STD_LOGIC_VECTOR (31 DOWNTO 0);	-- ALUResult, 2 Control: MemtoReg & RegWrite, ReDest_Mux, WriteBack
	SIGNAL Mem_WB : pipelineRegisterMem_WB;


	-- NEW -- TODO: Organize this
	SIGNAL New_PC : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0'); -- Initialize to PC = 0
	SIGNAL pc4 : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL BranchAndGate : STD_LOGIC;

BEGIN
---------- IF ---------- PC Mux, PC, InstrMem, PC Adder
--Branch Mux
	Branch_Mux <= AddALU_Result WHEN (BranchAndGate = '1') ELSE
		     pc4 WHEN (BranchAndGate = '0'); -- EX_Mem(0) WHEN (BranchAndGate = '0');			-- PC4
--Jump Mux
	New_PC <= Branch_Mux WHEN (JumpOut = '0') ELSE			-- JumpOut
		    JumpAddress WHEN (JumpOut = '1');			-- JumpOut
-- PC
	ProgCnt : PC PORT MAP(clk, reset, New_PC, PCWrite, Instr_Addr); 		-- TODO: Connect New_PC to Branch/Jump datapath
-- PC Adder
	PCAdder: adder 
		GENERIC MAP (32)
		PORT MAP (Instr_Addr, X"00000001", pc4); -- Pass a constant or change Paul's code?
-- Instruction Memory (Use either imem OR synth_imem, not both!)
--	IMEM_1 : imem PORT MAP(Instr_Addr(5 DOWNTO 0), Instr);		--NOR Reg(0) & Reg(1) into Reg(2)
	IMEM_1 : synth_imem PORT MAP(Instr_Addr(5 DOWNTO 0), Instr);	-- Synthesis version

---------- IF/ID ---------- Instr, PC4
	IF_ID(0) <= pc4 WHEN (rising_edge(clk) AND IF_ID_Write = '1');-- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' AND IF_ID_Write = '0');
	IF_ID(1) <= Instr WHEN (rising_edge(clk) AND IF_ID_Write = '1');-- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' AND IF_ID_Write = '0');

---------- ID ---------- RegFile, Sign Extend, Controller, Shift Left 2
-- Instruction Breakdown
	OpCode <= IF_ID(1)(31 DOWNTO 26);
	RS <= IF_ID(1)(25 DOWNTO 21);
	RT <= IF_ID(1)(20 DOWNTO 16);
	RD <= IF_ID(1)(15 DOWNTO 11);
	SHAMT <= IF_ID(1)(10 DOWNTO 6);
	Funct <= IF_ID(1)(5 DOWNTO 0);
	BitImmediate_16 <= IF_ID(1)(15 DOWNTO 0);
-- Hazard
	H : hazard PORT MAP(ID_EX(4)(0), EX_Mem(3)(0), ID_EX(7)(0), IF_ID(1)(25 DOWNTO 21), IF_ID(1)(20 DOWNTO 16), ID_EX(1)(20 DOWNTO 16), ID_EX(1)(15 DOWNTO 11), EX_Mem(10)(4 DOWNTO 0),
		OpCode, PCWrite, IF_ID_Write, ControlSel, Load_EX_Flush); -- ID/EX MemRead, EX/Mem MemRead, ID/EX RegWrite, IF/ID RS, IF/ID RT, ID/EX RT, ID/EX RD, EX/Mem RD, OpCode
-- Controller
	C1: controller PORT MAP(Funct, OpCode, ControlSel, MemtoReg, MemWrite, MemRead, Branch, ALUSrc, RegDest, RegWrite, JumpOut, ALUControl, dsize);
-- Register File
	R1 : regfile
		GENERIC MAP (32, 5)
		PORT MAP (clk, reset, Mem_WB(2)(0), RS, RT, Mem_WB(3)(4 DOWNTO 0), RegOut1, RegOut2, MemToReg_Mux);		-- RegWrite, RegDest_Mux
-- Sign Extend
	Sign_Expand: FOR i IN 0 TO 31 GENERATE
		
		not_fill: IF i <= 15 GENERATE
			new_immed(i) <= IF_ID(1)(i);
		END GENERATE not_fill;

		fill: IF i > 15 GENERATE
			new_immed(i) <= IF_ID(1)(15);
		END GENERATE fill;

	END GENERATE Sign_Expand;
-- Shift Left 2 Immediate
	shiftleft_im <= TO_STDLOGICVECTOR(TO_BITVECTOR(ID_EX(13)) sll 2);	-- new_immed
-- Normal Adder
	NormAdder: adder
		GENERIC MAP(32)
		PORT MAP(ID_EX(0), shiftleft_im, AddALU_Result);			-- PC4
-- Compare1_Mux
	Compare1_MUX <= RegOut1 WHEN (IDRegDataA = '0') ELSE
			EX_Mem(8) WHEN (IDRegDataA = '1');		-- ALUresult
-- Compare2_Mux
	Compare2_MUX <= RegOut2 WHEN (IDRegDataB = '0') ELSE
			EX_Mem(8) WHEN (IDRegDataB = '1');		-- ALUresult
-- Comparator
	BC : BranchComparator PORT MAP (Compare1_MUX, Compare2_MUX, BEQ);
-- Branch And Gate
	BranchAndGate <= Branch AND BEQ;			-- Branch, BranchComparator
-- Shift Left 2
	shiftleft <= IF_ID(1)(25 DOWNTO 0) & "00"; --TO_STDLOGICVECTOR(TO_BITVECTOR(Instr(25 DOWNTO 0)) sll 2);
--Jump Adress
	JumpAddress <= IF_ID(0)(31 DOWNTO 28) & shiftleft;

---------- ID/EX ---------- Instr, 10 Control, PC4, RegOut1, RegOut2, new_immed, RT, RD
	ID_EX(0) <= IF_ID(0) WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');			-- PC4
	ID_EX(1) <= IF_ID(1) WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');			-- Instr
	ID_EX(2)(0) <= MemtoReg WHEN (rising_edge(clk)); -- ELSE '0' WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(3)(0) <= MemWrite WHEN (rising_edge(clk)); -- ELSE '0' WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(4)(0) <= MemRead WHEN (rising_edge(clk)); -- ELSE '0' WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
--	ID_EX(5)(0) <= Branch WHEN (rising_edge(clk));
	ID_EX(5)(0) <= ALUSrc WHEN (rising_edge(clk)); -- ELSE '0' WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(6)(0) <= RegDest WHEN (rising_edge(clk)); -- ELSE '0' WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(7)(0) <= RegWrite WHEN (rising_edge(clk)); -- ELSE '0' WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(8)(0) <= JumpOut WHEN (rising_edge(clk)); -- ELSE '0' WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(9)(5 DOWNTO 0) <= ALUControl WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(10)(2 DOWNTO 0) <= dsize WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(11) <= RegOut1 WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(12) <= RegOut2 WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(13) <= new_immed WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(14)(4 DOWNTO 0) <= RT WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');
	ID_EX(15)(4 DOWNTO 0) <= RD WHEN (rising_edge(clk)); -- ELSE (OTHERS => '0') WHEN (BranchAndGate = '1' OR Load_EX_Flush = '1');

---------- EX ---------- ALU, SL2, Norm Adder
-- Forwarding
--	F: forward PORT MAP (ID_EX(1)(25 DOWNTO 21), ID_EX(1)(20 DOWNTO 16), EX_Mem(11) (4 DOWNTO 0), EX_Mem(4)(0), Mem_WB(3)(4 DOWNTO 0), Mem_WB(2)(0), ALUSrcA, ALUSrcB);
			-- ID_EX_Rs, ID_EX_Rt, EX_MEM_Rd, EX_MEM_RegWrite, MEM_WB_Rd, MEM_WB_RegWrite
	F: forward PORT MAP (ID_EX(1)(25 DOWNTO 21), ID_EX(1)(20 DOWNTO 16), IF_ID(1)(25 DOWNTO 21), IF_ID(1)(20 DOWNTO 16), EX_Mem(10) (4 DOWNTO 0),
		EX_Mem(4)(0), Mem_WB(3)(4 DOWNTO 0), Mem_WB(2)(0), IDRegDataA, IDRegDataB, ALUSrcA, ALUSrcB);
		-- ID_EX_Rs, ID_EX_Rt, IF_ID_Rs, IF_ID_Rt, EX_MEM_Rd, EX_MEM_RegWrite, MEM_WB_Rd, MEM_WB_RegWrite

-- RegDest Mux
	RegDest_Mux <= ID_EX(14)(4 DOWNTO 0) WHEN (ID_EX(6)(0) = '0') ELSE		-- RT
		ID_EX(15)(4 DOWNTO 0) WHEN (ID_EX(6)(0) = '1');				-- RD
-- ALUin Muxes
	ALUin1_MUX <= ID_EX(11) WHEN (ALUSrcA = "00") ELSE				-- RegOut1
		Mem_WB(0) WHEN (ALUSrcA = "01") ELSE					-- MEM/WB ALUresult
		EX_Mem(8) WHEN (ALUSrcA = "10");					-- EX/Mem ALUresult	

	ALUin2_MUX <= ID_EX(12) WHEN (ALUSrcB = "00") ELSE				-- RegOut2
		Mem_WB(0) WHEN (ALUSrcB = "01") ELSE					-- MEM/WB ALUresult
		EX_Mem(8) WHEN (ALUSrcB = "10");					-- EX/Mem ALUresult
-- ALUSrc Mux
	ALUSrc_Mux <= ALUin2_MUX WHEN (ID_EX(5)(0) = '0') ELSE
		ID_EX(13) WHEN (ID_EX(5)(0) = '1');				-- new_immed
-- ALU
	A1 : alu PORT MAP (ID_EX(9)(5 DOWNTO 0), ID_EX(1)(10 DOWNTO 6), ALUin1_MUX, ALUSrc_Mux, ALUresult); -- , BranchOut);	-- ALUControl, SHAMT, RegOut1

---------- EX/Mem ---------- PC4, 7 Control, AddALU_Result, ALUResult, BranchOut, RegOut2, RegDest_Mux
	EX_Mem(0) <= ID_EX(0) WHEN (rising_edge(clk));				-- PC4
	EX_Mem(1)(0) <= ID_EX(2)(0) WHEN (rising_edge(clk));			-- MemtoReg
	EX_Mem(2)(0) <= ID_EX(3)(0) WHEN (rising_edge(clk));			-- MemWrite
	EX_Mem(3)(0) <= ID_EX(4)(0) WHEN (rising_edge(clk));			-- MemRead
--	EX_Mem(4)(0) <= ID_EX(5)(0) WHEN (rising_edge(clk));			-- Branch
	EX_Mem(4)(0) <= ID_EX(7)(0) WHEN (rising_edge(clk));			-- RegWrite
	EX_Mem(5)(0) <= ID_EX(8)(0) WHEN (rising_edge(clk));			-- JumpOut
	EX_Mem(6)(2 DOWNTO 0) <= ID_EX(10)(2 DOWNTO 0) WHEN (rising_edge(clk));	-- dsize
--	EX_Mem(7) <= AddALU_Result WHEN (rising_edge(clk));
	EX_Mem(8) <= ALUresult WHEN (rising_edge(clk));
--	EX_Mem(10)(0) <= BranchOut WHEN (rising_edge(clk));
	EX_Mem(9) <= ALUin2_MUX WHEN (rising_edge(clk));			-- ALUin2_MUX
	EX_Mem(10)(4 DOWNTO 0) <= RegDest_Mux WHEN (rising_edge(clk));
	EX_Mem(11)(15 DOWNTO 11) <= ID_EX(15)(4 DOWNTO 0) WHEN (rising_edge(clk));	-- RD

---------- Mem ---------- DataMem, Jump Mux, Branch Mux
---- Data Memory
	Ram1: ram PORT MAP (clk, EX_Mem(2)(0), EX_Mem(3)(0), EX_Mem(6)(2 DOWNTO 0), EX_Mem(8), EX_Mem(9), WriteBack);		-- MemWrite, MemRead, dsize, ALUresult, ALUin2_MUX
--	RAM: dmem PORT MAP ( -- USE FOR SYNTHESIS APPROX. ONLY
--		ref_clk => clk, we => MemWrite, 
--		a => ALUresult, wd => RegOut2, rd => WriteBack);
---------- Mem/WB ---------- ALUresult, 2 Control: MemtoReg & RegWrite, RegDest_Mux, WriteBack
	Mem_WB(0) <= EX_Mem(8) WHEN (rising_edge(clk));					-- ALUresult
	Mem_WB(1)(0) <= EX_Mem(1)(0) WHEN (rising_edge(clk));				-- MemtoReg
	Mem_WB(2)(0) <= EX_Mem(4)(0) WHEN (rising_edge(clk));				-- RegWrite
	Mem_WB(3)(4 DOWNTO 0) <= EX_Mem(10)(4 DOWNTO 0) WHEN (rising_edge(clk));	-- RegDest_Mux
	Mem_WB(4) <= WriteBack WHEN (rising_edge(clk));
	Mem_WB(5)(15 DOWNTO 11) <= EX_Mem(11)(15 DOWNTO 11) WHEN (rising_edge(clk));	-- RD

---------- WB ----------
-- MemToRegMux
	MemToReg_Mux <= Mem_WB(0) WHEN (Mem_WB(1)(0) = '0') ELSE	-- ALUresult, MemtoReg
		Mem_WB(4) WHEN (Mem_WB(1)(0) = '1');			-- WriteBack, MemtoReg

END arch;
