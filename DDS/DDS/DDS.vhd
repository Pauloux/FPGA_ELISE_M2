-- Author: Paul ROUSSEAU
-- Date: 18 September 2026
--
-- Description:
-- Direct Digital Synthesis (DDS) implementation.
-- Outputs a 14 bits sine wave.

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
		o_data	: OUT STD_LOGIC_VECTOR(13 DOWNTO 0)	:= (OTHERS => '0')
	);
END ENTITY DDS;

ARCHITECTURE arch OF DDS IS

	SIGNAL s_phase	: STD_LOGIC_VECTOR(N-1 DOWNTO 0)	:= (OTHERS => '0');
	SIGNAL s_phase_with_offset	: STD_LOGIC_VECTOR(N-1 DOWNTO 0)	:= (OTHERS => '0');

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
			o_data	=> o_data
		);

END arch;
