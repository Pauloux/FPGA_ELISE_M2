-- Author: Maxime BELLAUD
-- Date: 24 September 2026
--
-- Description:
-- Encapsulation for the DDS_interleaved.vhd file on the Red Pitaya.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DDS_interleaved_redpitaya IS
	GENERIC (
		PHASE_WIDTH	: INTEGER	:= 10
	);
	PORT(
		-- Clock
		adc_clk_p_i, adc_clk_n_i	: IN STD_LOGIC;
		-- Reset
		Button	: IN STD_LOGIC;
		-- Increment value : 1 MSB and 3 LSB
		GPIO	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- Phase shift : 4 MSB
		SW	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);

		-- DAC
		dac_rst_o	: OUT STD_LOGIC;
		dac_sel_o	: OUT STD_LOGIC;
		dac_clk_o	: OUT STD_LOGIC;
		dac_wrt_o	: OUT STD_LOGIC;
		dac_dat_o	: OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
	);
END ENTITY DDS_interleaved_redpitaya;

ARCHITECTURE arch OF DDS_interleaved_redpitaya IS
	
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
	SIGNAL s_increment	: STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_phase_shift	: STD_LOGIC_VECTOR(PHASE_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_channel	: STD_LOGIC := '0';
	SIGNAL s_enable	: STD_LOGIC := '1';
	SIGNAL s_dac_value	: STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');

BEGIN

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


	-- DDS instantiation
	c_DDS_interleaved	: ENTITY work.DDS_interleaved
		GENERIC MAP(
			PHASE_WIDTH	=> PHASE_WIDTH
		)
		PORT MAP(
			i_clk	=> s_clk,
			i_n_reset	=> Button,
			i_increment	=> s_increment,
			i_phase_shift	=> s_phase_shift,
			i_enable => '1',
			o_data	=> s_dac_value
		);

	-- DAC AD9767 instantiation
	c_DAC_AD9767	: ENTITY work.DAC_AD9767
		PORT MAP(
			i_n_reset	=> Button,
			i_clk	=> s_clk,
			i_channel	=> s_channel,
			i_data	=> s_dac_value,
			o_reset	=> dac_rst_o,
			o_sel	=> dac_sel_o,
			o_clk	=> dac_clk_o,
			o_wrt	=> dac_wrt_o,
			o_data	=> dac_dat_o
		);
	
	-- Input wiring
	s_channel	<= GPIO(3);

	s_increment(PHASE_WIDTH-1)	<= GPIO(2);
	s_increment(1 DOWNTO 0)	<= GPIO(1 DOWNTO 0);
	s_increment(PHASE_WIDTH-2 DOWNTO 2)	<= (OTHERS => '0');

	s_phase_shift(PHASE_WIDTH-1 DOWNTO PHASE_WIDTH-4)	<= SW(3 DOWNTO 0);
	s_phase_shift(PHASE_WIDTH-5 DOWNTO 0)	<= (OTHERS	=> '0');

END arch;
