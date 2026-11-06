-- Author: Paul ROUSSEAU
-- Date: 6 November 2026
--
-- Description:
-- Encapsulation to communicate with the AD9834 (DDS) using the Red Pitaya.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DDS_AD9834_redpitaya IS
	PORT(
		-- Inputs --
		-- Clock
		adc_clk_p_i, adc_clk_n_i	: IN STD_LOGIC;
		-- Send button
		Button	: IN STD_LOGIC;
		-- 2 LSB = word to send selection; 2 MSB = part of the selected word to display
		SW	: IN STD_LOGIC_VECTOR(3 DOWNTO 0);

		-- Outputs --
		-- SPI:
		-- bit 0 (LSB) = SDATA; bit 1 = SCLK; bit 2 = FSYNC; bit 3 (MSB) = RESET
		GPIO	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		-- 7-segment display
		gfedcba : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		-- Leds
		led_o	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY DDS_AD9834_redpitaya;

ARCHITECTURE arch OF DDS_AD9834_redpitaya IS

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

	-- Constants
	CONSTANT CLK_PRESCALER	: INTEGER	:= 20;
	CONSTANT PARALLEL_BUS_WIDTH	: INTEGER	:= 16;

	CONSTANT WORD_0	: STD_LOGIC_VECTOR	:= X"2200";
	CONSTANT WORD_1	: STD_LOGIC_VECTOR	:= X"0000";
	CONSTANT WORD_2	: STD_LOGIC_VECTOR	:= X"00FF";
	CONSTANT WORD_3	: STD_LOGIC_VECTOR	:= X"FFFF";

	-- Signals
	SIGNAL s_N_reset_parallel_to_serial_converter	: STD_LOGIC	:= '1';
	SIGNAL s_word_to_send	: STD_LOGIC_VECTOR(PARALLEL_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL s_done	: STD_LOGIC	:= '0';
	SIGNAL s_seven_segment_digit	: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
	-- Clock buffer instantiation
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

	-- parallel_to_serial_converter instantiation
	c_parallel_to_serial_converter	: ENTITY work.parallel_to_serial_converter
	GENERIC MAP(
		CLK_PRESCALER	=> CLK_PRESCALER,
		PARALLEL_BUS_WIDTH	=> PARALLEL_BUS_WIDTH
	)
	PORT MAP(
		i_clk	=> s_clk,
		i_N_reset	=> s_N_reset_parallel_to_serial_converter,
		i_parallel_data	=> s_word_to_send,
		o_clk	=> GPIO(1),
		o_serial_data	=> GPIO(0),
		o_done	=> s_done
	);

	-- moore_machine_SPI instantiation
	c_moore_machine_SPI	: ENTITY work.moore_machine_SPI
	PORT MAP(
		i_clk	=> s_clk,
		i_N_start	=> Button,
		i_done_spi	=> s_done,
		o_enable_spi	=> s_N_reset_parallel_to_serial_converter,
		o_N_SS	=> GPIO(2)
	);

	-- seven_segment instantiation
	c_seven_segment	: ENTITY work.seven_segment
	PORT MAP(
		i_digit	=> s_seven_segment_digit,
		o_gfedcba	=> gfedcba
	);

	-- Word selection
	WITH SW(1 DOWNTO 0) SELECT
		s_word_to_send <=	WORD_0	WHEN "00",
							WORD_1	WHEN "01",
							WORD_2	WHEN "10",
							WORD_3	WHEN OTHERS;
	
	-- Word selection : 7-segment display
	WITH SW(3 DOWNTO 2) SELECT
		s_seven_segment_digit <=	s_word_to_send(3 DOWNTO 0) WHEN "00",
									s_word_to_send(7 DOWNTO 4) WHEN "01",
									s_word_to_send(11 DOWNTO 8) WHEN "10",
									s_word_to_send(15 DOWNTO 12) WHEN OTHERS;

	-- Word selection : LED
	WITH SW(3 DOWNTO 2) SELECT
		led_o <=	s_word_to_send(7 DOWNTO 0) WHEN "00",
					s_word_to_send(7 DOWNTO 0) WHEN "01",
					s_word_to_send(15 DOWNTO 8) WHEN "10",
					s_word_to_send(15 DOWNTO 8) WHEN OTHERS;

END arch;
