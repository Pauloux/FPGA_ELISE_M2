-- Author : Paul ROUSSEAU
-- Date : 2 october 2026

-- Description:
-- Encapsulation for the Low_Pass_Filter.vhd.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Low_Pass_Filter_redpitaya IS 
	PORT(
		-- Clock
		adc_clk_p_i, adc_clk_n_i	: IN STD_LOGIC;
		-- Reset
		Button	: IN STD_LOGIC;

		-- ADC
		adc_dat_a_i	: IN STD_LOGIC_VECTOR(13 DOWNTO 0);

		-- DAC
		dac_rst_o	: OUT STD_LOGIC;
		dac_sel_o	: OUT STD_LOGIC;
		dac_clk_o	: OUT STD_LOGIC;
		dac_wrt_o	: OUT STD_LOGIC;
		dac_dat_o	: OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
	);
END ENTITY Low_Pass_Filter_redpitaya;

ARCHITECTURE arch OF Low_Pass_Filter_redpitaya IS
	
	-- Constants
	CONSTANT CLK_FREQUENCY	: INTEGER	:= 125_000_000;
	CONSTANT SAMPLING_FREQUENCY	: INTEGER	:= 15_625_000;

	-- Clock
	SIGNAL s_clk_no_buffer	: STD_LOGIC;
	SIGNAL s_clk	: STD_LOGIC;

	COMPONENT IBUFDS IS 
		PORT(
			I, IB	: IN STD_LOGIC;
			O	: OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT BUFG IS 
		PORT(
			I : IN STD_LOGIC;
			O : OUT STD_LOGIC
		);
	END COMPONENT;

	-- Signals
	SIGNAL s_sampling_clock	: STD_LOGIC;
	SIGNAL s_filter_output	: STD_LOGIC_VECTOR(13 DOWNTO 0)	:= (OTHERS => '0');

	SIGNAL s_tmp_i	: UNSIGNED(13 DOWNTO 0);
	SIGNAL s_tmp_o	: UNSIGNED(13 DOWNTO 0);

BEGIN
	s_tmp_i	<= UNSIGNED(adc_dat_a_i);
	s_filter_output	<= STD_LOGIC_VECTOR(s_tmp_o);

	-- Clock
	c_clock_no_buffer	: IBUFDS
		PORT MAP(
			I	=> adc_clk_p_i,
			IB	=> adc_clk_n_i,
			O	=> s_clk_no_buffer
		);
	c_clock	: BUFG
		PORT MAP(
			I	=> s_clk_no_buffer,
			O	=> s_clk
		);

	-- Frequency divider instantiation
	c_freq_divider	: ENTITY work.freq_divider
		GENERIC MAP(
			FREQ_IN	=> CLK_FREQUENCY,
			FREQ_OUT	=> SAMPLING_FREQUENCY
		)
		PORT MAP(
			i_clk	=> s_clk,
			o_overflow	=> s_sampling_clock
		);
	
	-- Low pass filter instantiation
	c_Low_Pass_Filter	: ENTITY work.Low_Pass_Filter
		PORT MAP(
			i_clk	=> s_sampling_clock,
			i_N_reset	=> Button,
			i_signal	=> s_tmp_i,
			o_signal	=> s_tmp_o
		);

	-- DAC AD9767 instantiation
	c_DAC_AD9767	: ENTITY work.DAC_AD9767
		PORT MAP(
			i_n_reset	=> Button,
			i_clk	=> s_clk,
			i_channel	=> '0',
			i_data	=> s_filter_output,
			o_reset	=> dac_rst_o,
			o_sel	=> dac_sel_o,
			o_clk	=> dac_clk_o,
			o_wrt	=> dac_wrt_o,
			o_data	=> dac_dat_o
		);

END arch;
