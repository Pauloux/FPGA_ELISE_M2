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
	SIGNAL s_i_phase      : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_o_data       : STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	-- LUT SINUS --

	c_lut_sinus : ENTITY work.lut_sinus
		GENERIC MAP (
			N => N
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

		FOR i IN 0 TO 2**N - 1 LOOP
			s_i_phase <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, N));
			WAIT UNTIL rising_edge(s_i_clk_125MHz);
		END LOOP;
		stop;
	END PROCESS p_behavioral;

END behavioral;
