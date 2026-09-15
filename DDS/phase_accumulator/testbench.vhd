LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;  -- pour avoir la commande "stop" qui met fin à la simulation

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;
	CONSTANT N      : INTEGER := 10;

	SIGNAL s_i_clk_125MHz : STD_LOGIC := '0';
	SIGNAL s_i_N_reset    : STD_LOGIC := '0';
	SIGNAL s_i_w          : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0');
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
			i_w       => s_i_w,
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
		-- cas avec w = 0 
		s_i_N_reset <= '1';
		s_i_w <= (OTHERS => '0');
		WAIT FOR 4 * PERIOD;

		-- cas avec w = 1 
		s_i_w <= STD_LOGIC_VECTOR(TO_UNSIGNED(1, N));
		WAIT FOR 32 * PERIOD;

		-- cas avec w=1 + reset 
		WAIT FOR 16 * PERIOD;
		s_i_N_reset <= '0';
		WAIT FOR 4 * PERIOD;
		s_i_N_reset <= '1';
		WAIT UNTIL rising_edge(s_i_clk_125MHz);
		WAIT FOR 16 * PERIOD;

		-- cas avec w = 128
		s_i_w <= STD_LOGIC_VECTOR(TO_UNSIGNED(128, N));
		WAIT FOR 24 * PERIOD;

		stop;
	END PROCESS p_scenario;

END behavioral;
