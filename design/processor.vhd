LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY processor IS
	PORT (clk : IN std_logic ;
		reset : IN std_logic );
END processor ;


ARCHITECTURE arch OF processor IS

	COMPONENT reg IS
		PORT (ref_clk: IN STD_LOGIC;
			reg_reset : 	IN STD_LOGIC;
			reg_enable:	IN  std_logic;
			data_in:IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			data_out: OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
	END COMPONENT;

	COMPONENT controller IS
		PORT (ref_clk, rst : 		IN STD_LOGIC;
			Funct, OpCode : 	IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			MemtoReg, MemWrite, MemRead, Branch, ALUSrcA, RegDest,
			 RegWrite, IRWrite, PCWrite, IorD : OUT STD_LOGIC;
			ALUSrcB, PCSrc : 	OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
			ALUControl : 		OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
			dsize : 			OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
	END COMPONENT;

	COMPONENT mem IS
		PORT (ref_clk, rst : IN STD_LOGIC;
			addr : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			we, IorD : IN STD_LOGIC;
			dsize : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			wd : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			rd : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
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

	--SIGNAL Instr_Addr: STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL Instr : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL OpCode, Funct : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL RS, RT, RD, SHAMT : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL BitImmediate_16 : STD_LOGIC_VECTOR (15 DOWNTO 0);

	SIGNAL MemtoReg, MemWrite, MemRead, Branch, ALUSrcA, RegDest, RegWrite, IRWrite, PCWrite, IorD: STD_LOGIC;
	SIGNAL ALUControl : STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL ALUSrcB, PCSrc : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL dsize : STD_LOGIC_VECTOR (2 DOWNTO 0);

	SIGNAL RegDest_Mux : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL ALUSrcB_Mux, MemtoReg_Mux, Branch_Mux, new_immed : STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL RegOut1, RegOut2, ALUresult, WriteBack : STD_LOGIC_VECTOR (31 DOWNTO 0);

	SIGNAL BranchOut : STD_LOGIC;

	SIGNAL shiftleft_imm : STD_LOGIC_VECTOR (31 DOWNTO 0);
	
	SIGNAL JumpAddr : STD_LOGIC_VECTOR (31 DOWNTO 0);

	---- NEW -- TODO: Organize this
	SIGNAL BranchAndGate : STD_LOGIC;
	SIGNAL A_Reg_out, B_Reg_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL PCEn : STD_LOGIC;
	SIGNAL pc_in, pc_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL mem_addr, mem_out : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL Data : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL IorD_Mux : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ALUOut : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL PCSrc_Mux : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL ALUSrcA_Mux : STD_LOGIC_VECTOR (31 DOWNTO 0);

BEGIN
------ CONTROL ------
-- Controller
	C1: controller PORT MAP(clk, reset, Funct, OpCode, 
				MemtoReg, MemWrite, MemRead, Branch, 
				ALUSrcA, RegDest, RegWrite, IRWrite, PCWrite, IorD,
				ALUSrcB, PCSrc,
				ALUControl, dsize);
-- Branch And Gate
	BranchAndGate <= BranchOut AND Branch;

-- PCEn Mux
	PCEn <= BranchAndGate AND PCWrite;

------ DATAPATH ------
-- Program Counter
	ProgamCounter : reg PORT MAP (clk, reset, PCEn, pc_in, pc_out);

-- IorD_Mux
	mem_addr <= pc_out WHEN IorD = '0' ELSE
		PCSrc_Mux WHEN IorD = '1';
	
-- Instr/Data Memory
	Memory : mem PORT MAP (clk, reset, mem_addr, MemWrite, IorD, dsize, Data, mem_out);

-- Instruction register
	Instr_Reg : reg PORT MAP (clk, reset, IRWrite, mem_out, Instr);
-- Data register
	Data_Reg : reg PORT MAP (clk, reset, '1', mem_out, Data);
   
-- Instruction Breakdown
	OpCode <= Instr(31 DOWNTO 26);
	RS <= Instr(25 DOWNTO 21);
	RT <= Instr(20 DOWNTO 16);
	RD <= Instr(15 DOWNTO 11);
	SHAMT <= Instr(10 DOWNTO 6);
	Funct <= Instr(5 DOWNTO 0);
	BitImmediate_16 <= Instr(15 DOWNTO 0);


------ INSTRUCTION DATAPATH
-- RegDest Mux
	RegDest_Mux <= RT WHEN (RegDest = '0') ELSE
		RD WHEN (RegDest = '1');
-- MemToReg Mux
	MemToReg_Mux <= ALUOut WHEN (MemToReg = '0') ELSE
		Data WHEN (MemToReg = '1');

-- Register File
	R1 : regfile
		GENERIC MAP (32, 5)
		PORT MAP (clk, reset, RegWrite, RS, RT, RegDest_Mux, RegOut1, RegOut2, MemToReg_Mux);

------ Double Register TODO
	A_Reg : reg PORT MAP (clk, reset, '1', RegOut1, A_Reg_out);
	B_Reg : reg PORT MAP (clk, reset, '1', RegOut2, B_Reg_out);

-- Sign Extend
	Sign_Expand: FOR i IN 0 TO 31 GENERATE
		
		not_fill: IF i <= 15 GENERATE
			new_immed(i) <= Instr(i);
		END GENERATE not_fill;

		fill: IF i > 15 GENERATE
			new_immed(i) <= Instr(15);
		END GENERATE fill;

	END GENERATE Sign_Expand;

-- Shift Left 2 Immediate
	shiftleft_imm <= TO_STDLOGICVECTOR(TO_BITVECTOR(new_immed) sll 2);

-- ALUSrcA Mux
	ALUSrcA_Mux <= pc_out 	WHEN (ALUSrcA = '0') ELSE
				A_Reg_out  	WHEN (ALUSrcA = '1');
-- ALUSrcB Mux
	ALUSrcB_Mux <= B_Reg_out 		WHEN (ALUSrcB = "00") ELSE
		(0=>'1', OTHERS => '0') 	WHEN (ALUSrcB = "01") ELSE
		new_immed 					WHEN (ALUSrcB = "10") ELSE
		shiftleft_imm 				WHEN (ALUSrcB = "11");

-- ALU
	A1 : alu PORT MAP (ALUControl, SHAMT, RegOut1, ALUSrcB_Mux, ALUresult, BranchOut);

-- ALU Reg
	ALU_Reg : reg PORT MAP (clk, reset, '1', ALUresult, ALUOut);

-- Jump Address
	JumpAddr <= pc_out(31 DOWNTO 28) & Instr(25 DOWNTO 0) & "00";

-- PCSrc Mux
	PCSrc_Mux <= ALUresult 	WHEN (PCSrc = "00") ELSE
		ALUOut 	WHEN (PCSrc = "01") ELSE
		JumpAddr 	WHEN (PCSrc = "10") ELSE
		(OTHERS => '0');

END arch;
