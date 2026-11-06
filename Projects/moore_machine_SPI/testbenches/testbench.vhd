-- Author: Maxime BELLAUD
-- Date: 5 November 2026
--
-- Description:
-- Testbench for moore_machine_SPI.
-- Button is active low: '0' means pressed.
-- i_done_spi stands in for the converter: it rises at the end of a frame
-- and falls once the machine has left S_SEND.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.ENV.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;

	SIGNAL s_i_clk        : STD_LOGIC := '0';
	SIGNAL s_i_N_start   : STD_LOGIC := '1';
	SIGNAL s_i_done_spi   : STD_LOGIC := '0';
	SIGNAL s_o_enable_spi : STD_LOGIC;
	SIGNAL s_o_N_SS     : STD_LOGIC;

BEGIN

	c_moore : ENTITY work.moore_machine_SPI
		PORT MAP (
			i_clk        => s_i_clk,
			i_N_start   => s_i_N_start,
			i_done_spi   => s_i_done_spi,
			o_enable_spi => s_o_enable_spi,
			o_N_SS     => s_o_N_SS
		);

	p_clock : PROCESS
	BEGIN
		s_i_clk <= '0';
		WAIT FOR PERIOD / 2;
		s_i_clk <= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clock;

	p_scenario : PROCESS
	BEGIN
		-- Idle.
		WAIT FOR 5 * PERIOD;

		-- Button held for a whole frame, then released.
		s_i_N_start <= '0';
		WAIT FOR 20 * PERIOD;
		s_i_done_spi <= '1';
		WAIT FOR 5 * PERIOD;
		s_i_N_start <= '1';
		s_i_done_spi <= '0';
		WAIT FOR 10 * PERIOD;

		-- Button released before the end of the frame.
		s_i_N_start <= '0';
		WAIT FOR 10 * PERIOD;
		s_i_N_start <= '1';
		WAIT FOR 10 * PERIOD;
		s_i_done_spi <= '1';
		WAIT FOR 5 * PERIOD;
		s_i_done_spi <= '0';
		WAIT FOR 10 * PERIOD;

		STOP;
	END PROCESS p_scenario;

END behavioral;
