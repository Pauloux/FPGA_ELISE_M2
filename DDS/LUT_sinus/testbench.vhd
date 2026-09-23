LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;	-- For the STOP command to stop the simulation

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;
	CONSTANT N_10   : INTEGER := 10;
	CONSTANT N_14   : INTEGER := 14;

	SIGNAL s_i_clk_125MHz : STD_LOGIC := '0';

	SIGNAL s_i_phase_10 : STD_LOGIC_VECTOR(N_10-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_i_phase_14 : STD_LOGIC_VECTOR(N_14-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_o_data_10  : STD_LOGIC_VECTOR(13 DOWNTO 0);
	SIGNAL s_o_data_14  : STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	-- LUT SINUS N = 10 --

	c_lut_sinus_10 : ENTITY work.LUT_sinus
		GENERIC MAP (
			N => N_10
		)
		PORT MAP (
			i_phase => s_i_phase_10,
			o_data  => s_o_data_10
		);

	-- LUT SINUS N = 14 --

	c_lut_sinus_14 : ENTITY work.LUT_sinus
		GENERIC MAP (
			N => N_14
		)
		PORT MAP (
			i_phase => s_i_phase_14,
			o_data  => s_o_data_14
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

		-- N = 10
		FOR i IN 0 TO 2**N_10 - 1 LOOP
			s_i_phase_10 <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, N_10));
			WAIT UNTIL rising_edge(s_i_clk_125MHz);
		END LOOP;

		-- N = 14
		FOR i IN 0 TO 2**N_14 - 1 LOOP
			s_i_phase_14 <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, N_14));
			WAIT UNTIL rising_edge(s_i_clk_125MHz);
		END LOOP;

		STOP;
	END PROCESS p_behavioral;

END behavioral;
