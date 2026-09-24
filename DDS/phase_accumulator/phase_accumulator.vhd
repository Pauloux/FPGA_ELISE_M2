-- Phase Accumulator (DDS)
-- Set PHASE_WIDTH, default is 10.
-- Drive i_clk, keep i_n_reset high (active low), set frequency word i_w.
-- On each rising clock edge: o_phase = o_phase + i_w (wraps at 2^PHASE_WIDTH).
-- Pulse i_n_reset low to clear o_phase to 0.

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

	PROCESS(i_clk, i_enable, i_n_reset)
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
