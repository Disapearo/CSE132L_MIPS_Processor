LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY forward IS
	PORT (ID_EX_Rs, ID_EX_Rt : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		IF_ID_Rs, IF_ID_Rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_MEM_Rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_MEM_RegWrite : IN STD_LOGIC;
		MEM_WB_Rd : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		MEM_WB_RegWrite : IN STD_LOGIC;
		IDRegDataA, IDRegDataB : OUT STD_LOGIC;-- _VECTOR(1 DOWNTO 0);
		ALUSrcA, ALUSrcB : OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
END forward;

ARCHITECTURE arch OF forward IS

BEGIN
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
	IDRegDataA <= '1' WHEN (EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = IF_ID_Rs) ELSE	--Selects data forwarded from the EX/Mem Register
--		    "01" WHEN (MEM_WB_RegWrite = '1' AND MEM_WB_Rd /= "00000" AND MEM_WB_Rd = IF_ID_Rs
--			AND NOT(EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = IF_ID_Rs)) ELSE	--Selects data forwarded from the MEM/WB Register
		    '0';											--Selects data that came from the Register File in the ID stage

	IDRegDataB <= '1' WHEN (EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = IF_ID_Rt) ELSE	--Selects data forwarded from the EX/Mem Register
--		    "01" WHEN (MEM_WB_RegWrite = '1' AND MEM_WB_Rd /= "00000" AND MEM_WB_Rd = IF_ID_Rt		
--			AND NOT(EX_MEM_RegWrite = '1' AND EX_MEM_Rd /= "00000" AND EX_MEM_Rd = IF_ID_Rt)) ELSE	--Selects data forwarded from the MEM/WB Register
		    '0';											--Selects data that came from the Register File in the ID stage

END arch;
