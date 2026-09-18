-- Author: Paul ROUSSEAU
-- Date: 18 September 2026
--
-- Description:
-- Encapsulation for the DDS.vhd file on the Red Pitaya.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DDS_redpitaya IS
	GENERIC (
		N	: INTEGER	:= 10
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
		dac_dat_o	: OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
	);
END ENTITY DDS_redpitaya;

ARCHITECTURE arch OF DDS_redpitaya IS
	
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
	SIGNAL s_increment	: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_phase_shift	: STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN

	-- Clock
	c_clock_no_buffer	: ENTITY IBUFDS
		PORT MAP(
			I	=> i_clk_p,
			IB	=> i_clk_n,
			O	=> s_clk_no_buffer;
		);
	c_clock	: ENTITY BUFG
		PORT MAP(
			I	=> s_clk_no_buffer,
			O	=> s_clk
		);

	-- DDS instantiation
	c_DDS	: ENTITY work.DDS
		GENERIC MAP(
			N	=> N
		)
		PORT MAP(
			i_clk	=> s_clk,
			i_n_reset	=> Button,
			i_increment	=> s_increment,
			i_phase_shift	=> s_phase_shift,
			o_DAC_reset	=> dac_rst_o,
			o_DAC_sel	=> dac_sel_o,
			o_DAC_clk	=> dac_clk_o,
			o_DAC_wrt	=> dac_wrt_o,
			o_DAC_data	=> dac_dat_o
		);
	
	-- Input wiring
	s_increment(9)	<= GPIO(3);
	s_increment(2 DOWNTO 0)	<= GPIO(2 DOWNTO 0);
	s_increment(8 DOWNTO 3)	<= (OTHERS => '0');

	s_phase_shift(3 DOWNTO 0)	<= SW(3 DOWNTO 0);
	s_phase_shift(9 DOWNTO 4)	<= (OTHERS	=> '0');

END arch;
