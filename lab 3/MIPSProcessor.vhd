LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY processor IS
	PORT (ref_clk : IN std_logic ;
		reset : IN std_logic );
END processor ;


ARCHITECTURE arch OF processor IS

	COMPONENT PC IS
		PORT (clk: IN std_logic;
			i:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			o: OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT adder IS
		GENERIC(addr_size : INTEGER := 32);
		PORT (oldcounter: IN STD_LOGIC_VECTOR(addr_size - 1 DOWNTO 0);
			inc: IN STD_LOGIC_VECTOR(addr_size - 1 DOWNTO 0);
				newcounter: : OUT STD_LOGIC_VECTOR(addr_size - 1 DOWNTO 0);
	END COMPONENT;

	COMPONENT controller IS
		PORT (Funct, OpCode : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			MemtoReg, MemWrite, Branch, Jump, ALUSrc, RegDest, RegWrite : OUT STD_LOGIC;
			ALUControl : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			dsize : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
	END COMPONENT;

	COMPONENT imem IS -- instruction memory
		port(addr: IN STD_LOGIC_VECTOR(5 downto 0);
		rd: OUT STD_LOGIC_VECTOR(31 downto 0));
	END COMPONENT;


	COMPONENT regfile IS
		GENERIC ( NBIT : INTEGER := 32;
			NSEL : INTEGER := 5);
		PORT (clk : IN std_logic ;
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
--			Jump_out : OUT std_logic );
	END COMPONENT;

	COMPONENT ram IS
		GENERIC ( N : INTEGER := 32);
		PORT (clk : IN std_logic ;
			we : IN std_logic ;
			dsize : IN std_logic_vector (2 DOWNTO 0);
			addr 	: IN std_logic_vector (31 DOWNTO 0);
			dataI 	: IN std_logic_vector (31 DOWNTO 0);
			dataO 	: OUT std_logic_vector (31 DOWNTO 0));	
	END COMPONENT;

	SIGNAL Instr_Addr: STD_LOGIC_VECTOR (5 DOWNTO 0);

	SIGNAL Instr : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL OpCode, Funct : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL RS, RT, RD, SHAMT : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL BitImmediate_16 : STD_LOGIC_VECTOR (15 DOWNTO 0);

	SIGNAL MemtoReg, MemWrite, Branch, ALUSrc, RegDest, RegWrite : STD_LOGIC;
	SIGNAL ALUControl : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL dsize : STD_LOGIC_VECTOR (2 DOWNTO 0);

	SIGNAL mux1out : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL mux2out, mux3out, mux4out, new_immed : STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL RegOut1, RegOut2, WriteBack, ALUresult : STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL BranchOut : STD_LOGIC;

	SIGNAL ShiftLeft,shiftleft_im : STD_LOGIC_VECTOR (27 DOWNTO 0);
	
	SIGNAL JumpAddress : STD_LOGIC_VECTOR (31 DOWNTO 0);

	-- NEW -- TODO: Organize this
	SIGNAL New_PC : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN
	ProgCnt : PC PORT MAP(ref_clk, New_PC, Instr_Addr); -- TODO: Connect New_PC to Branch/Jump datapath
-- Instruction Memory
	IMEM_1 : imem PORT MAP(Instr_Addr, Instr);			--NOR Reg(0) & Reg(1) into Reg(2)
-- Instruction Breakdown
	OpCode <= Instr(31 DOWNTO 26);
	RS <= Instr(25 DOWNTO 21);
	RT <= Instr(20 DOWNTO 16);
	RD <= Instr(15 DOWNTO 11);
	SHAMT <= Instr(10 DOWNTO 6);
	Funct <= Instr(5 DOWNTO 0);
	BitImmediate_16 <= Instr(15 DOWNTO 0);
-- Controller
	C1: controller PORT MAP(Funct, OpCode, MemtoReg, MemWrite, Branch, Jump, ALUSrc, RegDest, RegWrite, ALUControl, dsize);

------ INSTRUCTION DATAPATH
-- Multiplexor 1
	mux1out <= RT WHEN (RegDest = '0') ELSE
		RD WHEN (RegDest = '1');
-- Sign Extend
	Sign_Expand: FOR i IN 0 TO 31 GENERATE
		
		not_fill: IF i <= 15 GENERATE
			new_immed(i) <= Instr(i);
		END GENERATE not_fill;

		fill: IF i > 15 GENERATE
			new_immed(i) <= Instr(15);
		END GENERATE fill;

	END GENERATE Sign_Expand;
-- Register File
	R1 : regfile
		GENERIC MAP (32, 5)
		PORT MAP (ref_clk, reset, RegWrite, RS, RT, mux1out, RegOut1, RegOut2, mux3out);
-- Multiplexor 2
	mux2out <= RegOut2 WHEN (ALUSrc = '0') ELSE
		new_immed WHEN (ALUSrc = '1');
-- ALU
	A1 : alu PORT MAP (ALUControl, SHAMT, RegOut1, mux2out, ALUresult, BranchOut);
-- Data Memory
	Ram1: ram PORT MAP (ref_clk, MemWrite, dsize, ALUresult, RegOut2, WriteBack);
-- Multiplexor 3
	mux3out <= ALUresult WHEN (MemtoReg = '0') ELSE
		WriteBack WHEN (MemtoReg = '1');
--Multiplexor 4
	mux4out <= JumpAdress WHEN (Jump = '1') ELSE
		mux3out WHEN (Jump = '0');

------ BRANCH/JUMP DATAPATH
-- PC Adder
	PCAdder: adder 
		GENERIC MAP (32)
		PORT MAP (Instr_Addr, "00000000000000000000000000000001", pc4); -- Pass a constant or change Paul's code?

-- Normal Adder
	NormAdder: adder
		GENERIC MAP(32)
		PORT MAP(pc4,shiftleft_im,branch_out);

-- Shift Left 2
	shiftleft <= Instr(25 DOWNTO 0) sll 2;

-- Shift Left 2 immediate
	shiftleft_im <= new_immed sll 2;


--Jump Adress
	JumpAddress <= Instr_Addr(31 DOWNTO 28) && shiftleft;

END arch;
