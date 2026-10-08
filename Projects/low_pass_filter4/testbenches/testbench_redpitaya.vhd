-- Author: Maxime BELLAUD
-- Date: 2 October 2026
--
-- Modified by Paul ROUSSEAU, 8 October 2026
--
-- Description:
-- Testbench for low_pass_filter4r_redpitaya_simulation_model.vhd.
-- The filter runs on the 125 MHz clock. freq_divider pulses i_enable for one
-- clock every 8 cycles, so the filter samples at 125/8 MHz (15.625 MHz).
-- Two LUT generate the tones in parallel: 244 kHz, below the 0.5 MHz cutoff,
-- and 6.1 MHz, above it. The filter input selects the 244 kHz sine first,
-- then the 6.1 MHz sine.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz
	CONSTANT CLK_FREQUENCY : INTEGER := 125_000_000;
	CONSTANT SAMPLING_FREQUENCY : INTEGER := CLK_FREQUENCY / 8;	-- 15.625 MHz

	CONSTANT PHASE_WIDTH : INTEGER := 10;
	CONSTANT INCREMENT_244KHZ : INTEGER := 2;	-- 244 kHz at 125 MHz
	CONSTANT INCREMENT_6MHZ : INTEGER := 50;	-- 6.1 MHz at 125 MHz

	SIGNAL s_clk : STD_LOGIC := '0';
	SIGNAL s_n_reset : STD_LOGIC := '1';
	SIGNAL s_enable : STD_LOGIC := '0';
	SIGNAL s_select_6MHz : STD_LOGIC := '0';

	SIGNAL s_phase_244kHz : UNSIGNED(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_sine_244kHz : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_phase_6MHz : UNSIGNED(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_sine_6MHz : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');

	SIGNAL s_filter_input : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');

	-- DAC output
	SIGNAL s_DAC_rst	: STD_LOGIC	:= '0';
	SIGNAL s_DAC_sel	: STD_LOGIC	:= '0';
	SIGNAL s_DAC_clk	: STD_LOGIC	:= '0';
	SIGNAL s_DAC_wrt	: STD_LOGIC	:= '0';
	SIGNAL s_DAC_dat	: STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	c_freq_divider : ENTITY work.freq_divider
		GENERIC MAP(
			FREQ_IN => CLK_FREQUENCY,
			FREQ_OUT => SAMPLING_FREQUENCY
		)
		PORT MAP(
			i_clk => s_clk,
			o_overflow => s_enable
		);

	c_lut_244kHz : ENTITY work.LUT_sinus
		GENERIC MAP(
			PHASE_WIDTH => PHASE_WIDTH
		)
		PORT MAP(
			i_phase => STD_LOGIC_VECTOR(s_phase_244kHz),
			o_data => s_sine_244kHz
		);

	c_lut_6MHz : ENTITY work.LUT_sinus
		GENERIC MAP(
			PHASE_WIDTH => PHASE_WIDTH
		)
		PORT MAP(
			i_phase => STD_LOGIC_VECTOR(s_phase_6MHz),
			o_data => s_sine_6MHz
		);

	s_filter_input <= s_sine_6MHz WHEN s_select_6MHz = '1' ELSE s_sine_244kHz;

	c_low_pass_filter4_redpitaya_simulation_model : ENTITY work.low_pass_filter4_redpitaya_simulation_model
		PORT MAP(
			i_clk	=> s_clk,
			Button	=> s_n_reset,
			adc_dat_a_i	=> s_filter_input,
			dac_rst_o	=> s_DAC_rst,
			dac_sel_o	=> s_DAC_sel,
			dac_clk_o	=> s_DAC_clk,
			dac_wrt_o	=> s_DAC_wrt,
			dac_dat_o	=> s_DAC_dat
		);

	-- 125 MHz clock.
	p_clock : PROCESS
	BEGIN
		s_clk <= '0';
		WAIT FOR PERIOD / 2;
		s_clk <= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clock;

	-- Both phases advance at 125 MHz, each with its own increment.
	p_phase : PROCESS(s_clk, s_n_reset)
	BEGIN
		IF rising_edge(s_clk) THEN
			s_phase_244kHz <= s_phase_244kHz + INCREMENT_244KHZ;
			s_phase_6MHz <= s_phase_6MHz + INCREMENT_6MHZ;
		END IF;
	END PROCESS p_phase;

	p_scenario : PROCESS
	BEGIN

		-- 244 kHz, below the cutoff.
		s_select_6MHz <= '0';
		WAIT FOR 512 * PERIOD;
		s_n_reset <= '0';
		WAIT FOR 128 * PERIOD;
		s_n_reset <= '1';
		WAIT FOR 512 * PERIOD;

		-- 6.1 MHz, above the cutoff.
		s_select_6MHz <= '1';
		WAIT FOR 512 * PERIOD;
		s_n_reset <= '0';
		WAIT FOR 128 * PERIOD;
		s_n_reset <= '1';
		WAIT FOR 512 * PERIOD;
		STOP;
	END PROCESS p_scenario;

END behavioral;
