-- Author : BELLAUD Maxime
-- Date : 2 october 2026

-- Low Pass Filter
-- This filter is a FIR filter oder 4 with linear phase. So coefficients are symmetric.

------------------------------------------------
--- Version sans tableau et additionneur simple 
-------------------------------------------------


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

SIGNAL s_signal_memory_0 : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');
SIGNAL s_signal_memory_1 : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');
SIGNAL s_signal_memory_2 : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');
SIGNAL s_signal_memory_3 : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');
SIGNAL s_signal_memory_4 : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');



SIGNAL s_o_signal : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');

BEGIN
PROCESS(i_clk, i_N_reset)
VARIABLE v_scaled_output : UNSIGNED(24 DOWNTO 0) := (OTHERS => '0');

VARIABLE product_0 : UNSIGNED(24 DOWNTO 0) := (OTHERS => '0');
VARIABLE product_1 : UNSIGNED(24 DOWNTO 0) := (OTHERS => '0');
VARIABLE product_2 : UNSIGNED(24 DOWNTO 0) := (OTHERS => '0');


BEGIN
	IF i_N_reset = '0' THEN
		s_signal_memory_0 <= (OTHERS => '0');
		s_signal_memory_1 <= (OTHERS => '0');
		s_signal_memory_2 <= (OTHERS => '0');
		s_signal_memory_3 <= (OTHERS => '0');
		s_signal_memory_4 <= (OTHERS => '0');
		s_o_signal <= (OTHERS => '0');
		v_scaled_output := (OTHERS => '0');
        product_0 := (OTHERS => '0');
        product_1 := (OTHERS => '0');
        product_2 := (OTHERS => '0');
	ELSIF rising_edge(i_clk) THEN
		IF i_enable = '1' THEN
			-- Compute the accumulator

            product_0 := RESIZE(RESIZE((RESIZE(UNSIGNED(i_signal), 15) + RESIZE(s_signal_memory_3, 15)) * B_0, 25),25);
            product_1 := RESIZE(RESIZE((RESIZE(s_signal_memory_0, 15) + RESIZE(s_signal_memory_2, 15)) * B_1, 25),25);
            product_2 := RESIZE(RESIZE(s_signal_memory_1 * B_2, 25),25);

            v_scaled_output := product_0 + product_1;
            v_scaled_output := v_scaled_output + product_2;

			-- Shift the signal memory
			s_signal_memory_0 <= UNSIGNED(i_signal);
			s_signal_memory_1 <= s_signal_memory_0;
			s_signal_memory_2 <= s_signal_memory_1;
			s_signal_memory_3 <= s_signal_memory_2;
			s_signal_memory_4 <= s_signal_memory_3;

			-- Output 
			s_o_signal <= v_scaled_output(SCALE + 13 DOWNTO SCALE);
		
		ELSE 
			s_signal_memory_0 <= s_signal_memory_0;
			s_signal_memory_1 <= s_signal_memory_1;
			s_signal_memory_2 <= s_signal_memory_2;
			s_signal_memory_3 <= s_signal_memory_3;
			s_signal_memory_4 <= s_signal_memory_4;
			s_o_signal <= s_o_signal;
		END IF;
	END IF;
END PROCESS;
o_signal <= STD_LOGIC_VECTOR(s_o_signal);
END arch;

