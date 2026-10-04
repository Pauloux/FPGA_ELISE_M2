-- Author: Maxime BELLAUD
-- Date: 15 September 2026
--
-- Description:
-- Phase accumulator of the DDS.
-- On each rising edge of i_clk, if i_enable is high, the phase register is
-- incremented by i_increment and wraps around at 2^PHASE_WIDTH.
-- i_n_reset is active low and clears the phase to 0.
-- i_enable allows the accumulator to be frozen (used for the interleaved DAC).

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY phase_accumulator IS
	GENERIC(
		PHASE_WIDTH : INTEGER := 10
	);
	PORT(
		i_clk : IN STD_LOGIC;
		i_n_reset : IN STD_LOGIC;
		i_enable : IN STD_LOGIC;
		i_increment : IN STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
		o_phase : OUT STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0')
	);
END ENTITY phase_accumulator;

ARCHITECTURE arch OF phase_accumulator IS

	SIGNAL s_phase : STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');

BEGIN

	o_phase <= s_phase;

	PROCESS(i_clk, i_n_reset)
	BEGIN
		IF i_n_reset = '0' THEN
			s_phase <= (OTHERS => '0');
		ELSIF rising_edge(i_clk) THEN
			IF i_enable = '1' THEN 
				s_phase <= STD_LOGIC_VECTOR(UNSIGNED(s_phase) + UNSIGNED(i_increment));
			ELSE
				s_phase <= s_phase;
			END IF;
		ELSE
			s_phase	<= s_phase;
		END IF;

	END PROCESS;

END arch;
