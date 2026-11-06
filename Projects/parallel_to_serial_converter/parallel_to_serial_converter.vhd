-- Author: Paul ROUSSEAU
-- Date: 5 November 2026
--
-- Description:
-- Parallel to serial converter.
--
-- Parameters:
-- CLK_PRESCALER (INTEGER): divider factor for the clock frequency.
-- PARALLEL_BUS_WIDTH (INTEGER): self-explanatory.
-- 
-- Inputs:
-- i_clk: clock.
-- i_N_reset: reset the converter when driven to 0. Necessary between each
-- 		conversion.
-- i_parallel_data: the parallel data to convert.
--
-- Outputs:
-- o_clk: clock. Its rising edge is synchronized with the o_serial_data update.
-- o_serial_data: the serial data. MSB of i_parallel_data is sent first, and LSB
--		is sent last.
-- o_done: driven to 1 when the conversion is finished.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY parallel_to_serial_converter IS
	GENERIC(
		CLK_PRESCALER	: INTEGER	:= 20;
		PARALLEL_BUS_WIDTH	: INTEGER	:= 16
	);
	PORT(
		-- Inputs
		i_clk	: IN STD_LOGIC;
		i_N_reset	: IN STD_LOGIC;
		i_parallel_data	: IN STD_LOGIC_VECTOR(PARALLEL_BUS_WIDTH-1 DOWNTO 0);

		-- Outputs
		o_clk	: OUT STD_LOGIC;
		o_serial_data	: OUT STD_LOGIC;
		o_done	: OUT STD_LOGIC
	);
END ENTITY parallel_to_serial_converter;

ARCHITECTURE arch OF parallel_to_serial_converter IS

	CONSTANT CLK_IN_FREQ	: INTEGER	:= 125_000_000;
	CONSTANT FREQ_COUNTER_MAX	: INTEGER	:= (CLK_IN_FREQ / CLK_PRESCALER) - 1;
	CONSTANT FREQ_COUNTER_HALFWAY	: INTEGER	:= (CLK_IN_FREQ / CLK_PRESCALER / 2) - 1;
	CONSTANT BIT_COUNTER_MAX	: INTEGER	:= PARALLEL_BUS_WIDTH - 1;

	SIGNAL s_freq_counter	: INTEGER RANGE 0 TO FREQ_COUNTER_MAX	:= 0;
	SIGNAL s_bit_counter	: INTEGER RANGE 0 TO BIT_COUNTER_MAX	:= 0;

	SIGNAL s_o_clk	: STD_LOGIC	:= '1';
	SIGNAL s_o_serial_data	: STD_LOGIC	:= '0';
	SIGNAL s_o_done	: STD_LOGIC	:= '0';

BEGIN

	PROCESS
	BEGIN
		WAIT UNTIL rising_edge(i_clk);
		IF (i_N_reset = '0') THEN
			s_freq_counter	<= 0;
			s_bit_counter	<= 0;
			s_o_clk	<= '1';
			s_o_serial_data	<= '0';
			s_o_done	<= '0';
		ELSE
			IF s_o_done = '0' THEN
				IF s_freq_counter = FREQ_COUNTER_MAX THEN	-- End of period
					s_freq_counter <= 0;
					IF s_bit_counter < BIT_COUNTER_MAX THEN	-- Increment bit counter
						s_bit_counter	<= s_bit_counter + 1;
						s_o_clk	<= '0';
						s_o_serial_data	<= i_parallel_data(BIT_COUNTER_MAX - s_bit_counter);
						s_o_done	<= '0';
					ELSE	-- When s_bit_counter = BIT_COUNTER_MAX (all bit have been sent)
						s_bit_counter	<= s_bit_counter;
						s_o_clk	<= '1';
						s_o_serial_data	<= '0';
						s_o_done	<= '1';
					END IF;
				ELSE
					s_freq_counter	<= s_freq_counter + 1;

					IF s_freq_counter <= FREQ_COUNTER_HALFWAY THEN
						s_bit_counter	<= s_bit_counter;
						s_o_clk	<= '1';
						s_o_serial_data	<= i_parallel_data(BIT_COUNTER_MAX - s_bit_counter);
						s_o_done	<= '0';
					ELSIF s_freq_counter < FREQ_COUNTER_MAX THEN
						s_bit_counter	<= s_bit_counter;
						s_o_clk	<= '0';
						s_o_serial_data	<= i_parallel_data(BIT_COUNTER_MAX - s_bit_counter);
						s_o_done	<= '0';
					END IF;
				END IF;
			ELSE	-- Conversion is finished, waiting for reset
				s_bit_counter	<= s_bit_counter;
				s_o_clk	<= '1';
				s_o_serial_data	<= '0';
				s_o_done	<= '1';
			END IF;
		END IF;
	END PROCESS;

	o_clk	<= s_o_clk;
	o_serial_data	<= s_o_serial_data;
	o_done	<= s_o_done;

END arch;
