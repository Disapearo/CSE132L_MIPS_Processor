LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY forward IS
	PORT (ID_EX_Rs, ID_EX_Rt : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		IF_ID_Rs, IF_ID_Rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		OpCode : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		EX_MEM_Rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_MEM_RegWrite : IN STD_LOGIC;
		MEM_WB_Rd : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		MEM_WB_RegWrite : IN STD_LOGIC;
		IDRegDataA, IDRegDataB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUSrcA, ALUSrcB : OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
END forward;

ARCHITECTURE arch OF forward IS

BEGIN
	--This forwarding unit does selective forwarding.
	--In other words, it will forward data to ID stage only if the branch/jump instruction in the ID stage requires a result coming from an instruction in the MEM or WB stage
	
	--Forward Data to EX stage for ALU
	ALUSrcA <= "10" WHEN (EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = ID_EX_Rs) ELSE	--Selects data forwarded from the EX/Mem Register
		   "01" WHEN (MEM_WB_RegWrite = '1' AND MEM_WB_Rd /= "00000" AND MEM_WB_Rd = ID_EX_Rs
			AND NOT(EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = ID_EX_Rs)) ELSE	--Selects data forwarded from the MEM/WB Register
		   "00";											--Selects data that came from the Register File in the ID stage
	
	ALUSrcB <= "10" WHEN (EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = ID_EX_Rt) ELSE	--Selects data forwarded from the EX/Mem Register
		   "01" WHEN (MEM_WB_RegWrite = '1' AND MEM_WB_Rd /= "00000" AND MEM_WB_Rd = ID_EX_Rt		
			AND NOT(EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = ID_EX_Rt)) ELSE	--Selects data forwarded from the MEM/WB Register
		   "00";											--Selects data that came from the Register File in the ID stage

	--Forward to ID stage for Comparator
	IDRegDataA <= "10" WHEN (EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = IF_ID_Rs) AND ((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101")) ELSE	--Selects data forwarded from the EX/Mem Register
		    "01" WHEN (MEM_WB_RegWrite = '1' AND MEM_WB_Rd /= "00000" AND MEM_WB_Rd = IF_ID_Rs AND ((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101"))
			AND NOT(EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = IF_ID_Rs)) ELSE	--Selects data forwarded from the MEM/WB Register
		    "00";											--Selects data that came from the Register File in the ID stage

	IDRegDataB <= "10" WHEN (EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = IF_ID_Rt) AND ((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101")) ELSE	--Selects data forwarded from the EX/Mem Register
		    "01" WHEN (MEM_WB_RegWrite = '1' AND MEM_WB_Rd /= "00000" AND MEM_WB_Rd = IF_ID_Rt AND ((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101"))		
			AND NOT(EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = IF_ID_Rt)) ELSE	--Selects data forwarded from the MEM/WB Register
		    "00";											--Selects data that came from the Register File in the ID stage

	--The Forwarding to ID from the WB stage (i.e. checking if MEM/WB.RegisterRd = IF/ID.RegisterRS(or Rt)) may not be needed b/c data is written to the register file on the rising edge of the clock and data is read from the register file on the falling edge of the clock.
	--In other words, the data has already been written back to the register file in time to be used by the Comparator. However, we still need to stall 2 cycles.
	--In other words, the 2nd line for IDRegDataA(or B) can possibly be removed
END arch;
