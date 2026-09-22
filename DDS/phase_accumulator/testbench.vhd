LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;	-- For the STOP command to stop the simulation

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;
	CONSTANT N      : INTEGER := 10;

	SIGNAL s_i_clk_125MHz : STD_LOGIC := '0';
	SIGNAL s_i_N_reset    : STD_LOGIC := '0';
	SIGNAL s_i_enable	  : STD_LOGIC := '0';
	SIGNAL s_i_increment  : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_o_phase      : STD_LOGIC_VECTOR(N-1 DOWNTO 0);

BEGIN

	-- PHASE ACCUMULATOR --

	c_phase_accumulator : ENTITY work.phase_accumulator
		GENERIC MAP (
			N => N
		)
		PORT MAP (
			i_clk     => s_i_clk_125MHz,
			i_N_reset => s_i_N_reset,
			i_enable => s_i_enable,
			i_increment  => s_i_increment,
			o_phase   => s_o_phase
		);

	-- CLOCK --

	p_clock : PROCESS
	BEGIN
		s_i_clk_125MHz <= '0';
		WAIT FOR PERIOD / 2;
		s_i_clk_125MHz <= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clock;

	-- SCENARIO --

	p_scenario : PROCESS
	BEGIN
		-- case with increment = 0 
		s_i_enable <= '1';
		s_i_N_reset <= '1';
		s_i_increment <= (OTHERS => '0');
		WAIT FOR 4 * PERIOD;
	
		-- case with increment = 1 
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(1, N));
		WAIT FOR 128 * PERIOD;

		-- case with increment=64 + reset toggle 
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(64,N));
		WAIT FOR 8 * PERIOD;
		s_i_N_reset <= '0';
		WAIT FOR 4 * PERIOD;
		s_i_N_reset <= '1';
		WAIT FOR 10 * PERIOD;

		-- case with increment=64 + enable toggle
		s_i_enable <= '0';
		WAIT FOR 4 * PERIOD;
		s_i_enable <= '1';
		WAIT FOR 4 * PERIOD;

		-- case with increment = 128
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(128, N));
		WAIT FOR 12 * PERIOD;

		stop;
	END PROCESS p_scenario;

END behavioral;
