-- Author : BELLAUD Maxime
-- Date : 2 october 2026

-- Low Pass Filter
-- This filter is a FIR filter oder 4 with linear phase. So coefficients are symmetric.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY low_pass_filter4 IS 
	GENERIC(
		SCALE : INTEGER := 9;
		B_0 : UNSIGNED(7 DOWNTO 0) := "00010010";
		B_1 : UNSIGNED(7 DOWNTO 0) := "01111011";
		B_2 : UNSIGNED(7 DOWNTO 0) := "11100110"
	);
	
	PORT(
		i_clk		:	IN	STD_LOGIC;
		i_N_reset	:	IN	STD_LOGIC;
		i_enable	:	IN	STD_LOGIC;
		i_signal	:	IN 	STD_LOGIC_VECTOR(13 DOWNTO 0);
		o_signal    :   OUT STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0')
	);
END ENTITY low_pass_filter4;


ARCHITECTURE arch OF low_pass_filter4 IS

TYPE t_signal_memory IS ARRAY (0 TO 4) OF UNSIGNED(13 DOWNTO 0);
SIGNAL s_signal_memory : t_signal_memory := (OTHERS => (OTHERS => '0'));

TYPE t_coeffs IS ARRAY (0 TO 2) OF UNSIGNED(7 DOWNTO 0);
CONSTANT c_coeffs : t_coeffs := (B_0, B_1, B_2);

SIGNAL s_o_signal : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');

BEGIN
PROCESS(i_clk, i_N_reset)
VARIABLE v_scaled_output : UNSIGNED(24 DOWNTO 0) := (OTHERS => '0');
BEGIN
	IF i_N_reset = '0' THEN
		s_signal_memory <= (OTHERS => (OTHERS => '0'));
		s_o_signal <= (OTHERS => '0');
		v_scaled_output := (OTHERS => '0');
	ELSIF rising_edge(i_clk) THEN
		IF i_enable = '1' THEN
			-- Compute the accumulator

			v_scaled_output := RESIZE(
				RESIZE((RESIZE(UNSIGNED(i_signal), 15) + RESIZE(s_signal_memory(3), 15)) * c_coeffs(0), 25)
				+ RESIZE((RESIZE(s_signal_memory(0), 15) + RESIZE(s_signal_memory(2), 15)) * c_coeffs(1), 25)
				+ RESIZE(s_signal_memory(1) * c_coeffs(2), 25),
				v_scaled_output'LENGTH);


			-- Shift the signal memory
			s_signal_memory(0) <= UNSIGNED(i_signal);
			for k in 0 to 3 loop
				s_signal_memory(k + 1) <= s_signal_memory(k);
			end loop;

			-- Output 
			s_o_signal <= v_scaled_output(SCALE + 13 DOWNTO SCALE);
		
		ELSE 
			s_signal_memory <= s_signal_memory;
			s_o_signal <= s_o_signal;
		END IF;
	END IF;
END PROCESS;
o_signal <= STD_LOGIC_VECTOR(s_o_signal);
END arch;

