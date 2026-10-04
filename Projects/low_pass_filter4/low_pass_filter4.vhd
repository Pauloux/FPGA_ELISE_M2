-- Author : BELLAUD Maxime
-- Date : 2 october 2026

-- Low Pass Filter
-- This filter is a FIR filter oder 4 so with 5 coefficients.
-- The filter is a low pass filter with a cutoff frequency of 0.5 MHz.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY low_pass_filter4 IS 
	GENERIC(
		SCALE : INTEGER := 9;
		N_0 : UNSIGNED(7 DOWNTO 0) := "00010010";
		N_1 : UNSIGNED(7 DOWNTO 0) := "01111011";
		N_2 : UNSIGNED(7 DOWNTO 0) := "11100110";
		N_3 : UNSIGNED(7 DOWNTO 0) := "01111011";
		N_4 : UNSIGNED(7 DOWNTO 0) := "00010010"
	);
	
	PORT(
		i_clk		:	IN	STD_LOGIC;
		i_N_reset	:	IN	STD_LOGIC;
		i_signal	:	IN 	UNSIGNED(13 DOWNTO 0);
		o_signal    :   OUT UNSIGNED(13 DOWNTO 0) := (OTHERS => '0')
	);
END ENTITY low_pass_filter4;


ARCHITECTURE arch OF low_pass_filter4 IS

TYPE t_signal_memory IS ARRAY (0 TO 4) OF UNSIGNED(13 DOWNTO 0);
SIGNAL s_signal_memory : t_signal_memory := (OTHERS => (OTHERS => '0'));

TYPE t_coeffs IS ARRAY (0 TO 4) OF UNSIGNED(7 DOWNTO 0);
CONSTANT c_coeffs : t_coeffs := (N_0, N_1, N_2, N_3, N_4);

BEGIN
PROCESS(i_clk, i_N_reset)
VARIABLE v_scaled_output : UNSIGNED(24 DOWNTO 0) := (OTHERS => '0');
BEGIN
	IF i_N_reset = '0' THEN
		s_signal_memory <= (OTHERS => (OTHERS => '0'));
		o_signal <= (OTHERS => '0');
		v_scaled_output := (OTHERS => '0');
	ELSIF rising_edge(i_clk) THEN
		-- Compute the accumulator
		v_scaled_output := RESIZE(i_signal * c_coeffs(0), v_scaled_output'LENGTH);
		for k in 0 to 3 loop
			v_scaled_output := v_scaled_output + RESIZE(s_signal_memory(k) * c_coeffs(k + 1), v_scaled_output'LENGTH);
		end loop;

		-- Shift the signal memory
		s_signal_memory(0) <= i_signal;
		for k in 0 to 3 loop
			s_signal_memory(k + 1) <= s_signal_memory(k);
		end loop;

		-- Output 
		o_signal <= v_scaled_output(SCALE + 13 DOWNTO SCALE);
	END IF;
END PROCESS;
END arch;

