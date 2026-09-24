LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;	-- For the STOP command to stop the simulation

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;
	CONSTANT PHASE_WIDTH : INTEGER := 10;


	SIGNAL s_i_clk_125MHz : STD_LOGIC := '0';

	SIGNAL s_i_phase : STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_o_data  : STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	-- LUT INTERLEAVED SIGNALS PHASE_WIDTH = 10 --

	c_lut_interleaved_signals : ENTITY work.LUT_interleaved_signals
		GENERIC MAP (
			PHASE_WIDTH => PHASE_WIDTH
		)
		PORT MAP (
			i_phase => s_i_phase,
			o_data  => s_o_data
		);

	-- CLOCK --

	p_clock : PROCESS
	BEGIN
		s_i_clk_125MHz <= '0';
		WAIT FOR PERIOD / 2;
		s_i_clk_125MHz <= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clock;


	p_behavioral : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(s_i_clk_125MHz);

		-- PHASE_WIDTH = 10
		FOR i IN 0 TO 2**PHASE_WIDTH - 1 LOOP
			s_i_phase <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, PHASE_WIDTH));
			WAIT UNTIL rising_edge(s_i_clk_125MHz);
		END LOOP;

		STOP;
	END PROCESS p_behavioral;

END behavioral;
