-- Author: Paul ROUSSEAU
-- Date: 7 November 2026
--
-- Description:
-- Test bench for the seven_segment.vhd file.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz

	SIGNAL s_i_digit : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_o_gfedcba : STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '1');

BEGIN

	-- 7-segment display instantiation
	c_seven_segment	: ENTITY work.seven_segment
	PORT MAP(
		i_digit		=> s_i_digit,
		o_gfedcba	=> s_o_gfedcba
	);

	p_i_digit : PROCESS
	BEGIN
		FOR i IN 0 TO 15 LOOP -- 0 to F
			s_i_digit <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 4));
			WAIT FOR PERIOD;
		END LOOP;

		STOP;
	END PROCESS p_i_digit;

END behavioral;
