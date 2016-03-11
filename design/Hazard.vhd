library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY hazard IS
	PORT(
		ID_EX_MemRead : IN STD_LOGIC;
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
		Load_EX_Flush : OUT STD_LOGIC
	);
END ENTITY hazard;

ARCHITECTURE detect OF hazard IS

BEGIN
	--Specify Branch OpCodes if we're only forwarding data to ID stage for branches
	--If we are going to arbitrarily forward to ID stage, instead of selectively forwarding to ID stage for branches and jumps and forwarding to EX stage for all other instructions, take out OpCode specification
	PCWrite <= '0' WHEN ID_EX_MemRead = '1' AND ((ID_EX_Rt = IF_ID_Rs) OR (ID_EX_Rt = IF_ID_Rt)) ELSE 	--Does not allow new PC to be written to PC Register (Load Hazard)
--		 '0' WHEN ID_EX_MemRead = '0' AND ID_EX_RegWrite = '1' AND 
--			((ID_EX_Rd = IF_ID_Rs) OR (ID_EX_Rd = IF_ID_Rt)) AND 
--			((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101")) ELSE	--Does not allow new PC to be written to PC Register (Data Hazard b/c Branch requires result of an R-type instruction but can't be forwarded yet)
--		 '0' WHEN EX_MEM_MemRead = '1' AND ((EX_MEM_Rd = IF_ID_Rs) OR (EX_MEM_Rd = IF_ID_Rt)) AND
--			((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101")) ELSE	--Does not allow new PC to be written to PC Register (Data Hazard b/c Branch requires result of a Load instruction but can't be forwarded yet)
		 '1';												--Allows new PC to be written to PC Register

	IF_ID_Write <= '0' WHEN ID_EX_MemRead = '1' AND ((ID_EX_Rt = IF_ID_Rs) OR (ID_EX_Rt = IF_ID_Rt)) ELSE	--Does not allow any values to be written to IF/ID Register (Load Hazard)
--		 '0' WHEN ID_EX_MemRead = '0' AND ID_EX_RegWrite = '1' AND 
--			((ID_EX_Rd = IF_ID_Rs) OR (ID_EX_Rd = IF_ID_Rt)) AND
--			((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101")) ELSE	--Does not allow new PC to be written to PC Register (Data Hazard b/c Branch requires result of an R-type instruction but can't be forwarded yet)
--		 '0' WHEN EX_MEM_MemRead = '1' AND ((EX_MEM_Rd = IF_ID_Rs) OR (EX_MEM_Rd = IF_ID_Rt)) AND
--			((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101")) ELSE	--Does not allow new PC to be written to PC Register (Data Hazard b/c Branch requires result of a Load instruction but can't be forwarded yet)
		 '1';												--Allows values to be written to IF/ID Register

	ControlSel <= '1' WHEN ID_EX_MemRead = '1' AND ((ID_EX_Rt = IF_ID_Rs) OR (ID_EX_Rt = IF_ID_Rt)) ELSE 	--Chooses to let 0s through (Load Hazard)
--		 '1' WHEN ID_EX_MemRead = '0' AND ID_EX_RegWrite = '1' AND 
--			((ID_EX_Rd = IF_ID_Rs) OR (ID_EX_Rd = IF_ID_Rt)) AND
--			((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101")) ELSE	--Chooses to let 0s through (Data Hazard b/c Branch requires result of an R-type instruction but can't be forwarded yet)
--		 '1' WHEN EX_MEM_MemRead = '1' AND ((EX_MEM_Rd = IF_ID_Rs) OR (EX_MEM_Rd = IF_ID_Rt)) AND
--			((OpCode = "000100") OR (OpCode = "000001") OR (OpCode = "000111") OR (OpCode = "000110") OR (OpCode = "000101")) ELSE	--Chooses to let 0s through (Data Hazard b/c Branch requires result of a Load instruction but can't be forwarded yet)
		 '0';												--Chooses to let control values through

	Load_EX_Flush <= '1' WHEN ID_EX_MemRead = '1' AND ((ID_EX_Rt = IF_ID_Rs) OR (ID_EX_Rt = IF_ID_Rt)) ELSE
		 '0';

END ARCHITECTURE detect;

