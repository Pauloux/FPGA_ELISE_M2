LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz

	SIGNAL s_adc_clk_i	: STD_LOGIC;
	SIGNAL s_adc_dat_a_i: STD_LOGIC_VECTOR(13 DOWNTO 0);
	SIGNAL s_adc_dat_b_i: STD_LOGIC_VECTOR(13 DOWNTO 0);

	SIGNAL s_dac_clk_o	: STD_LOGIC;
	SIGNAL s_dac_rst_o	: STD_LOGIC;
	SIGNAL s_dac_sel_o	: STD_LOGIC;
	SIGNAL s_dac_wrt_o	: STD_LOGIC;
	SIGNAL s_dac_dat_o	: STD_LOGIC_VECTOR(13 DOWNTO 0);

	-- UNSIGNED for incrementation
	SIGNAL s_adc_dat_a	: UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_adc_dat_b	: UNSIGNED(13 DOWNTO 0) := (OTHERS => '1');

BEGIN

	c_ADC_DAC_simulation_model	: ENTITY work.ADC_DAC_simulation_model
		PORT MAP(
			adc_clk_i	=> s_adc_clk_i,
			adc_dat_a_i	=> s_adc_dat_a_i,
			adc_dat_b_i	=> s_adc_dat_b_i,
			dac_clk_o	=> s_dac_clk_o,
			dac_rst_o	=> s_dac_rst_o,
			dac_sel_o	=> s_dac_sel_o,
			dac_wrt_o	=> s_dac_wrt_o,
			dac_dat_o	=> s_dac_dat_o
		);

	-- Clock
	p_clock : PROCESS
	BEGIN
		s_adc_clk_i	<= '0';
		WAIT FOR PERIOD / 2;
		s_adc_clk_i	<= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clock;
	
	-- Data, channel a
	p_data_a	: PROCESS
	BEGIN
		WAIT FOR PERIOD / 2;
		WHILE (0 < 1) LOOP	-- Infinite loop
			s_adc_dat_a <= s_adc_dat_a + 1;
			WAIT FOR PERIOD;
		END LOOP;
	END PROCESS p_data_a;
	s_adc_dat_a_i <= STD_LOGIC_VECTOR(s_adc_dat_a);

	-- Data, channel b
	p_data_b	: PROCESS
	BEGIN
		WAIT FOR PERIOD / 2;
		WHILE (0 < 1) LOOP	-- Infinite loop
			s_adc_dat_b <= s_adc_dat_b - 1;
			WAIT FOR PERIOD;
		END LOOP;
	END PROCESS p_data_b;
	s_adc_dat_b_i <= STD_LOGIC_VECTOR(s_adc_dat_b);

END behavioral;
