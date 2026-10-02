-- Author: Maxime BELLAUD
-- Date: 2 October 2026
--
-- Description:
-- Testbench for Low_Pass_Filter.vhd.


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD_CLK    : TIME    := 8 ns;	-- 125 MHz, sine generation
	CONSTANT PERIOD_FILTER : TIME    := 64 ns;	-- 15.625 MHz, filter
	CONSTANT PHASE_WIDTH   : INTEGER := 10;
	CONSTANT INCREMENT     : INTEGER := 50;	-- 6.1 MHz at 125 MHz

	SIGNAL s_i_clk        : STD_LOGIC := '0';
	SIGNAL s_i_clk_filter : STD_LOGIC := '0';
	SIGNAL s_div          : INTEGER RANGE 0 TO 3 := 0;
	SIGNAL s_i_N_reset    : STD_LOGIC := '1';
	SIGNAL s_i_enable     : STD_LOGIC := '1';
	SIGNAL s_phase        : UNSIGNED(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_lut          : STD_LOGIC_VECTOR(13 DOWNTO 0);
	SIGNAL s_o_signal     : UNSIGNED(13 DOWNTO 0);

BEGIN

	c_LUT : ENTITY work.LUT_sinus
		GENERIC MAP(
			PHASE_WIDTH => PHASE_WIDTH
		)
		PORT MAP(
			i_phase => STD_LOGIC_VECTOR(s_phase),
			o_data  => s_lut
		);

	c_filter : ENTITY work.Low_Pass_Filter
		PORT MAP(
			i_clk     => s_i_clk_filter,
			i_N_reset => s_i_N_reset,
			i_enable  => s_i_enable,
			i_signal  => UNSIGNED(s_lut),
			o_signal  => s_o_signal
		);

	-- 125 MHz clock, used to build the sine.
	p_clock : PROCESS
	BEGIN
		s_i_clk <= '0';
		WAIT FOR PERIOD_CLK / 2;
		s_i_clk <= '1';
		WAIT FOR PERIOD_CLK / 2;
	END PROCESS p_clock;

	-- Filter clock: 125 MHz divided by 8.
	p_clk_filter : PROCESS(s_i_clk)
	BEGIN
		IF rising_edge(s_i_clk) THEN
			IF s_div = 3 THEN
				s_div <= 0;
				s_i_clk_filter <= NOT s_i_clk_filter;
			ELSE
				s_div <= s_div + 1;
			END IF;
		END IF;
	END PROCESS p_clk_filter;

	-- Phase of the input sine, advanced at 125 MHz.
	p_phase : PROCESS(s_i_clk)
	BEGIN
		IF rising_edge(s_i_clk) THEN
			s_phase <= s_phase + INCREMENT;
		END IF;
	END PROCESS p_phase;

	p_scenario : PROCESS
	BEGIN
		-- Enable
		s_i_N_reset <= '1';
		s_i_enable  <= '1';
		WAIT FOR 64 * PERIOD_FILTER;

		-- Bypass
		s_i_enable <= '0';
		WAIT FOR 64 * PERIOD_FILTER;

		-- Enable again
		s_i_enable <= '1';
		WAIT FOR 64 * PERIOD_FILTER;

		-- Reset for one filter clock, then release
		s_i_N_reset <= '0';
		WAIT FOR PERIOD_FILTER;
		s_i_N_reset <= '1';
		WAIT FOR 64 * PERIOD_FILTER;

		STOP;
	END PROCESS p_scenario;

END behavioral;
