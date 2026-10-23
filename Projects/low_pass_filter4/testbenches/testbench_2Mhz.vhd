-- Author: Maxime BELLAUD
-- Date: 23 October 2026
--
-- Description:
-- Testbench for low_pass_filter4.vhd at Fs = F_clk / 63 (1.984 MHz).
-- The filter still runs on the 125 MHz clock. freq_divider pulses i_enable
-- once every 63 cycles. The coefficients are those of fir1 for this Fs,
-- passed through the generic map: SCALE = 8, B0 = 0, B1 = 52, B2 = 152.
-- Three LUT generate the tones in parallel, all below the 992 kHz Nyquist
-- frequency: 244 kHz, 488 kHz and 732 kHz.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz
	CONSTANT CLK_FREQUENCY : INTEGER := 125_000_000;
	CONSTANT SAMPLING_DIVIDER : INTEGER := 63;
	CONSTANT SAMPLING_FREQUENCY : INTEGER := CLK_FREQUENCY / SAMPLING_DIVIDER;	-- 1.984 MHz

	CONSTANT PHASE_WIDTH : INTEGER := 10;
	CONSTANT INCREMENT_244KHZ : INTEGER := 2;	-- 244 kHz at 125 MHz
	CONSTANT INCREMENT_488KHZ : INTEGER := 4;	-- 488 kHz at 125 MHz
	CONSTANT INCREMENT_732KHZ : INTEGER := 6;	-- 732 kHz at 125 MHz

	SIGNAL s_clk : STD_LOGIC := '0';
	SIGNAL s_n_reset : STD_LOGIC := '1';
	SIGNAL s_enable : STD_LOGIC := '0';
	SIGNAL s_select_tone : UNSIGNED(1 DOWNTO 0) := "00";

	SIGNAL s_phase_244kHz : UNSIGNED(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_sine_244kHz : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_phase_488kHz : UNSIGNED(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_sine_488kHz : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_phase_732kHz : UNSIGNED(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_sine_732kHz : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');

	SIGNAL s_filter_input : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_filter_output : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');

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

	c_lut_488kHz : ENTITY work.LUT_sinus
		GENERIC MAP(
			PHASE_WIDTH => PHASE_WIDTH
		)
		PORT MAP(
			i_phase => STD_LOGIC_VECTOR(s_phase_488kHz),
			o_data => s_sine_488kHz
		);

	c_lut_732kHz : ENTITY work.LUT_sinus
		GENERIC MAP(
			PHASE_WIDTH => PHASE_WIDTH
		)
		PORT MAP(
			i_phase => STD_LOGIC_VECTOR(s_phase_732kHz),
			o_data => s_sine_732kHz
		);

	s_filter_input <= s_sine_732kHz WHEN s_select_tone = "10"
		ELSE s_sine_488kHz WHEN s_select_tone = "01"
		ELSE s_sine_244kHz;

	c_low_pass_filter4 : ENTITY work.low_pass_filter4
		GENERIC MAP(
			SCALE => 8,
			B_0 => "00000000",
			B_1 => "00110100",
			B_2 => "10011000"
		)
		PORT MAP(
			i_clk => s_clk,
			i_N_reset => s_n_reset,
			i_enable => s_enable,
			i_signal => s_filter_input,
			o_signal => s_filter_output
		);

	-- 125 MHz clock.
	p_clock : PROCESS
	BEGIN
		s_clk <= '0';
		WAIT FOR PERIOD / 2;
		s_clk <= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clock;

	-- The three phases advance at 125 MHz, each with its own increment.
	p_phase : PROCESS(s_clk, s_n_reset)
	BEGIN
		IF rising_edge(s_clk) THEN
			s_phase_244kHz <= s_phase_244kHz + INCREMENT_244KHZ;
			s_phase_488kHz <= s_phase_488kHz + INCREMENT_488KHZ;
			s_phase_732kHz <= s_phase_732kHz + INCREMENT_732KHZ;
		END IF;
	END PROCESS p_phase;

	p_scenario : PROCESS
	BEGIN
		-- 244 kHz, below 500 kHz.
		s_select_tone <= "00";
		WAIT FOR 2048 * PERIOD;

		-- 488 kHz, next to 500 kHz.
		s_select_tone <= "01";
		WAIT FOR 2048 * PERIOD;

		-- 732 kHz, above 500 kHz and below Nyquist.
		s_select_tone <= "10";
		WAIT FOR 2048 * PERIOD;
		STOP;
	END PROCESS p_scenario;

END behavioral;
