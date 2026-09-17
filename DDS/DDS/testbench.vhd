-- Author: Paul ROUSSEAU
-- Date: 17 September 2026
--
-- Description:
-- Testbench for the DDS.vhd file.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;	-- For the STOP command to stop the simulation

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz
	CONSTANT N	: INTEGER := 10;

	-- Inputs
	SIGNAL s_i_clk	: STD_LOGIC;
	SIGNAL s_i_n_reset	: STD_LOGIC;
	SIGNAL s_i_increment	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL s_i_phase_shift	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);

	-- Outputs
	SIGNAL s_o_DAC_reset	: STD_LOGIC;
	SIGNAL s_o_DAC_sel	: STD_LOGIC;
	SIGNAL s_o_DAC_clk	: STD_LOGIC;
	SIGNAL s_o_DAC_wrt	: STD_LOGIC;
	SIGNAL s_o_DAC_data	: STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	-- DDS instantiation
	c_DDS	: ENTITY work.DDS
		GENERIC MAP(
			N	=> N
		)
		PORT MAP(
			i_clk	=> s_i_clk,
			i_n_reset	=> s_i_n_reset,
			i_increment	=> s_i_increment,
			i_phase_shift	=> s_i_phase_shift,
			o_DAC_reset	=> s_o_DAC_reset,
			o_DAC_sel	=> s_o_DAC_sel,
			o_DAC_clk	=> s_o_DAC_clk,
			o_DAC_wrt	=> s_o_DAC_wrt,
			o_DAC_data	=> s_o_DAC_data
		);

	-- CLOCK
	p_clock :	PROCESS
	BEGIN
		s_i_clk	<= '0';
		WAIT FOR PERIOD / 2;
		s_i_clk	<= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clock;

	p_cases:	PROCESS
	BEGIN
		-- Case 1 - Increment = 1 - Phase shift = 0
		s_i_n_reset	<= '1';
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(1, N));
		s_i_phase_shift	<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, N));
		WAIT FOR ((2**N + 10) * PERIOD);

		-- Reset
		s_i_n_reset	<= '0';
		WAIT FOR 1 * PERIOD;

		-- Case 2 - Increment = 2 - Phase shift = 0
		s_i_n_reset	<= '1';
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(2, N));
		s_i_phase_shift	<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, N));
		WAIT FOR ((2**N / 2 + 10) * PERIOD);

		-- Reset
		s_i_n_reset	<= '0';
		WAIT FOR 1 * PERIOD;

		-- Case 3 - Increment = 10 - Phase shift = 0
		s_i_n_reset	<= '1';
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(10, N));
		s_i_phase_shift	<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, N));
		WAIT FOR ((2**N / 10 + 10) * PERIOD);

		-- Reset
		s_i_n_reset	<= '0';
		WAIT FOR 1 * PERIOD;

		-- Case 4 - Increment = 10 - Phase shift = (2**N) / 2
		s_i_n_reset	<= '1';
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(10, N));
		s_i_phase_shift	<= STD_LOGIC_VECTOR(TO_UNSIGNED(2**N / 2, N));
		WAIT FOR ((2**N / 10 + 10) * PERIOD);

		-- Reset
		s_i_n_reset	<= '0';
		WAIT FOR 1 * PERIOD;

		-- Case 5 - Increment = 10 - Phase shift = 3 * (2**N) / 4
		s_i_n_reset	<= '1';
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(10, N));
		s_i_phase_shift	<= STD_LOGIC_VECTOR(TO_UNSIGNED(3 * (2**N) / 4, N));
		WAIT FOR ((2**N / 10 + 10) * PERIOD);

		STOP;
	END PROCESS p_cases;

END behavioral;
