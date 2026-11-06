-- Author: Maxime BELLAUD
-- Date: 5 November 2026
--
-- Description:
-- Testbench for moore_machine_SPI.
-- Button is active low: '0' means pressed.
-- The holds are long enough for 16 bits once the SPI entity is connected.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.ENV.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;

	SIGNAL s_i_clk    : STD_LOGIC := '0';
	SIGNAL s_i_button : STD_LOGIC := '1';
	SIGNAL s_i_w      : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"2200";
	SIGNAL s_o_fsync  : STD_LOGIC;
	SIGNAL s_o_sclk   : STD_LOGIC;
	SIGNAL s_o_sdata  : STD_LOGIC;

BEGIN

	c_moore : ENTITY work.moore_machine_SPI
		GENERIC MAP (
			N => 16
		)
		PORT MAP (
			i_clk    => s_i_clk,
			i_button => s_i_button,
			i_W      => s_i_w,
			o_FSYNC  => s_o_fsync,
			o_SCLK   => s_o_sclk,
			o_SDATA  => s_o_sdata
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
		s_i_button <= '0';
		WAIT FOR 500 * PERIOD;
		s_i_button <= '1';
		WAIT FOR 20 * PERIOD;

		-- Button released before the end of the frame.
		s_i_button <= '0';
		WAIT FOR 10 * PERIOD;
		s_i_button <= '1';
		WAIT FOR 500 * PERIOD;

		STOP;
	END PROCESS p_scenario;

END behavioral;
