-- Author: Maxime BELLAUD
-- Date: 23 September 2026
--
-- Description:
-- Testbench for the DDS.vhd file with aliasing.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;	-- For the STOP command to stop the simulation

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz
	CONSTANT PHASE_WIDTH	: INTEGER := 10;

	-- Inputs
	SIGNAL s_i_clk	: STD_LOGIC;
	SIGNAL s_i_n_reset	: STD_LOGIC;
	SIGNAL s_i_increment	: STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0);
	SIGNAL s_i_enable	: STD_LOGIC := '1';
	SIGNAL s_i_phase_shift	: STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0);

	-- Outputs
	SIGNAL s_o_data	: STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	-- DDS instantiation
	c_DDS	: ENTITY work.DDS
		GENERIC MAP(
			PHASE_WIDTH	=> PHASE_WIDTH
		)
		PORT MAP(
			i_clk	=> s_i_clk,
			i_n_reset	=> s_i_n_reset,
			i_increment	=> s_i_increment,
			i_phase_shift	=> s_i_phase_shift,
			i_enable	=> s_i_enable,
			o_data	=> s_o_data
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
		s_i_phase_shift	<= STD_LOGIC_VECTOR(TO_UNSIGNED(0, PHASE_WIDTH));

		-- Case 1 - Increment = 64 (below Nyquist, 16 samples/period)
		s_i_n_reset	<= '1';
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(64, PHASE_WIDTH));
		WAIT FOR ((2**(PHASE_WIDTH+1) / 64 + 10) * PERIOD);

		-- Reset
		s_i_n_reset	<= '0';
		WAIT FOR 1 * PERIOD;

		-- Case 2 - Increment = 960 = 2^PHASE_WIDTH - 64 (alias of case 1)
		s_i_n_reset	<= '1';
		s_i_increment <= STD_LOGIC_VECTOR(TO_UNSIGNED(960, PHASE_WIDTH));
		WAIT FOR ((2**(PHASE_WIDTH+1) / 64 + 10) * PERIOD);

		STOP;
	END PROCESS p_cases;

END behavioral;
