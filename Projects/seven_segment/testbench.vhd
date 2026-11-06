LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	COMPONENT seven_segment IS
		PORT (
			i_digit		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			-- Leftmost STD_LOGIC is segment G and rightmost STD_LOGIC is segment A
			o_gfedcba	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '1')
		);
	END COMPONENT;

	SIGNAL s_i_digit : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_o_gfedcba : STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '1');

	CONSTANT PERIOD : TIME := 1 ns;

BEGIN

	-- 7-segment display instantiation
	c_seven_segment : seven_segment PORT MAP (
		i_digit		=> s_i_digit,
		o_gfedcba	=> s_o_gfedcba
	);

	p_i_digit : PROCESS
	BEGIN
		FOR i IN 0 TO 15 LOOP -- 0 to F
			s_i_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 4));
			WAIT FOR PERIOD;
		END LOOP;
		WAIT;
	END PROCESS p_i_digit;

END behavioral;
