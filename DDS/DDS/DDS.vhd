-- Author: Paul ROUSSEAU
-- Date: 17 September 2026
--
-- Description:
-- Direct Digital Synthesis (DDS) implementation.
-- Uses the AD9767 14-bit ADC to generate the signal.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DDS IS
	GENERIC (
		N	: INTEGER	:= 10
	);
	PORT(
		i_clk	: IN STD_LOGIC;
		i_n_reset	: IN STD_LOGIC;
		i_increment	: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		i_phase_shift	: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);

		-- DAC
		o_DAC_reset	: OUT STD_LOGIC := '0';
		o_DAC_sel	: OUT STD_LOGIC := '0';
		o_DAC_clk	: OUT STD_LOGIC := '0';
		o_DAC_wrt	: OUT STD_LOGIC := '0';
		o_DAC_data	: OUT STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0')
	);
END ENTITY DDS;

ARCHITECTURE arch OF DDS IS

	SIGNAL s_phase	: STD_LOGIC_VECTOR(N-1 DOWNTO 0)	:= (OTHERS => '0');
	SIGNAL s_phase_with_offset	: STD_LOGIC_VECTOR(N-1 DOWNTO 0)	:= (OTHERS => '0');

	SIGNAL s_DAC_value	: STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	-- Phase accumulator instantiation
	c_phase_accumulator	: ENTITY work.phase_accumulator
		GENERIC MAP(
			N	=> N
		)
		PORT MAP(
			i_clk	=> i_clk,
			i_n_reset	=> i_n_reset,
			i_w	=> i_increment,
			o_phase	=> s_phase
		);
	
	-- Apply phase shift
	s_phase_with_offset	<= STD_LOGIC_VECTOR(UNSIGNED(s_phase) + UNSIGNED(i_phase_shift));

	-- LUT sinus instantiation
	c_LUT_sinus	: ENTITY work.LUT_sinus
		GENERIC MAP(
			N	=> N
		)
		PORT MAP(
			i_phase	=> s_phase_with_offset,
			o_data	=> s_DAC_value
		);

	-- DAC AD9767 instantiation
	c_DAC_AD9767	: ENTITY work.DAC_AD9767
		PORT MAP(
			i_n_reset	=> i_n_reset,
			i_clk	=> i_clk,
			i_data	=> s_DAC_value,
			o_reset	=> o_DAC_reset,
			o_sel	=> o_DAC_sel,
			o_clk	=> o_DAC_clk,
			o_wrt	=> o_DAC_wrt,
			o_data	=> o_DAC_data
		);

END arch;
