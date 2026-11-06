LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY seven_segment IS
PORT (
	i_digit		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	-- Leftmost STD_LOGIC is segment g and rightmost STD_LOGIC is segment a
	o_gfedcba 	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '1')
);
END seven_segment;

ARCHITECTURE arch OF seven_segment IS

	SIGNAL s_gfedcba : STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '0');

BEGIN

	WITH TO_INTEGER(UNSIGNED(i_digit)) SELECT
	s_gfedcba 	<=
		"0111111" WHEN 0,
		"0000110" WHEN 1,
		"1011011" WHEN 2,
		"1001111" WHEN 3,
		"1100110" WHEN 4,
		"1101101" WHEN 5,
		"1111101" WHEN 6,
		"0000111" WHEN 7,
		"1111111" WHEN 8,
		"1101111" WHEN 9,
		"1110111" WHEN 10,	-- A
		"1111100" WHEN 11,	-- B
		"0111001" WHEN 12,	-- C
		"1011110" WHEN 13,	-- D
		"1111001" WHEN 14,	-- E
		"1110001" WHEN 15,	-- F
		"1000000" WHEN OTHERS;	-- Should never happen

	o_gfedcba <= NOT s_gfedcba;	-- '0' = ON, '1' = OFF

END arch;
