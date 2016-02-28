library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY hazard IS
	PORT(
		ID_EX_MemRead : IN STD_LOGIC;
		IF_ID_Rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		IF_ID_Rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ID_EX_Rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ID_EX_Rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		PCWrite : OUT STD_LOGIC;
		IF_ID_Write : OUT STD_LOGIC;
		ControlSel : OUT STD_LOGIC
	);
END ENTITY hazard;

ARCHITECTURE detect OF hazard IS

BEGIN

	PCWrite <= '0' WHEN ID_EX_MemRead = '1' AND ((ID_EX_Rt = IF_ID_Rs) OR (ID_EX_Rt = IF_ID_Rt)) ELSE 
		 '1';

	IF_ID_Write <= '0' WHEN ID_EX_MemRead = '1' AND ((ID_EX_Rt = IF_ID_Rs) OR (ID_EX_Rt = IF_ID_Rt)) ELSE
		 '1';

	ControlSel <= '1' WHEN ID_EX_MemRead = '1' AND ((ID_EX_Rt = IF_ID_Rs) OR (ID_EX_Rt = IF_ID_Rt)) ELSE 
		 '0';



END ARCHITECTURE detect;
