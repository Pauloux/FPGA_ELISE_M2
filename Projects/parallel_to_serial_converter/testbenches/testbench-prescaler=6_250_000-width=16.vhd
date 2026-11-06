-- Author: Paul ROUSSEAU
-- Date: 5 November 2026
--
-- Description:
-- Testbench for the parallel_to_serial_converter.vhd file with the following
-- parameters :
-- CLK_PRESCALER = 6_250_000 (FREQ / 20)
-- PARALLEL_BUS_WIDTH = 16

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD	: TIME	:= 8 ns;	-- 125 MHz
	CONSTANT FREQ	: INTEGER	:= 125_000_000;
	CONSTANT CLK_PRESCALER	: INTEGER	:= 6_250_000;	-- 20 periods
	CONSTANT PARALLEL_BUS_WIDTH	: INTEGER	:= 16;

	-- Inputs
	SIGNAL s_i_clk	: STD_LOGIC	:= '0';
	SIGNAL s_i_N_reset	: STD_LOGIC	:= '1';
	SIGNAL s_i_parallel_data	: STD_LOGIC_VECTOR(PARALLEL_BUS_WIDTH-1 DOWNTO 0)	:= (OTHERS => '0');

	-- Outputs
	SIGNAL s_o_clk	: STD_LOGIC	:= '0';
	SIGNAL s_o_serial_data	: STD_LOGIC	:= '0';
	SIGNAL s_o_done	: STD_LOGIC	:= '0';

BEGIN

	-- parallel_to_serial_converter instantiation
	c_parallel_to_serial_converter	: ENTITY work.parallel_to_serial_converter
	GENERIC MAP(
		CLK_PRESCALER	=> CLK_PRESCALER,
		PARALLEL_BUS_WIDTH	=> PARALLEL_BUS_WIDTH
	)
	PORT MAP(
		i_clk	=> s_i_clk,
		i_N_reset	=>	s_i_N_reset,
		i_parallel_data	=> s_i_parallel_data,
		o_clk	=> s_o_clk,
		o_serial_data	=> s_o_serial_data,
		o_done	=> s_o_done
	);

	-- Clock
	p_clk	: PROCESS
	BEGIN
		s_i_clk	<= '0';
		WAIT FOR PERIOD / 2;
		s_i_clk	<= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clk;

	-- Scenarios
	p_scenarios	: PROCESS
	BEGIN
		-- Random data
		s_i_N_reset	<= '1';
		s_i_parallel_data	<= "1101001011100011";
		WAIT FOR 20 * PERIOD * (FREQ / CLK_PRESCALER);
		s_i_N_reset	<= '0';
		WAIT FOR 20 * PERIOD;	-- See what happens when the component is not reset when it is done

		-- Only 0
		s_i_N_reset	<= '1';
		s_i_parallel_data	<= "0000000000000000";
		WAIT FOR PARALLEL_BUS_WIDTH * PERIOD * (FREQ / CLK_PRESCALER);
		s_i_N_reset	<= '0';
		WAIT FOR PERIOD;

		-- Only 1
		s_i_N_reset	<= '1';
		s_i_parallel_data	<= "1111111111111111";
		WAIT FOR PARALLEL_BUS_WIDTH * PERIOD * (FREQ / CLK_PRESCALER);
		s_i_N_reset	<= '0';
		WAIT FOR PERIOD;

		-- Alternating 0 and 1
		s_i_N_reset	<= '1';
		s_i_parallel_data	<= "0101010101010101";
		WAIT FOR PARALLEL_BUS_WIDTH * PERIOD * (FREQ / CLK_PRESCALER);
		s_i_N_reset	<= '0';
		WAIT FOR PERIOD;

		-- Reset in the middle of a conversion
		s_i_N_reset	<= '1';
		s_i_parallel_data	<= "1010101010101010";
		WAIT FOR (PARALLEL_BUS_WIDTH / 2 * PERIOD * (FREQ / CLK_PRESCALER)) + (4 * PERIOD);	-- Not enough time for the full conversion
		s_i_N_reset	<= '0';
		WAIT FOR PERIOD;	-- Wait and start a new conversion
		s_i_N_reset	<= '1';
		s_i_parallel_data	<= "1010101010101010";
		WAIT FOR PARALLEL_BUS_WIDTH * PERIOD * (FREQ / CLK_PRESCALER);
		s_i_N_reset	<= '0';
		WAIT FOR PERIOD;

		STOP;
	END PROCESS;

END behavioral;
