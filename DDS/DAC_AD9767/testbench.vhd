-- Author: Paul ROUSSEAU
-- Date: 16 September 2026
--
-- Description:
-- Testbench for the DAC_AD9467.vhd file.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;	-- For the STOP command to stop the simulation

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz

	-- Inputs
	SIGNAL s_i_n_reset	: STD_LOGIC	:= '1';
	SIGNAL s_i_clk	: STD_LOGIC	:= '0';
	SIGNAL s_i_channel	: STD_LOGIC	:= '0';
	SIGNAL s_i_data	: STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
	SIGNAL s_i_data_tmp	: UNSIGNED(13 DOWNTO 0)	:= (OTHERS => '0');

	-- Outputs
	SIGNAL s_o_reset	: STD_LOGIC	:= '0';
	SIGNAL s_o_sel	: STD_LOGIC	:= '0';
	SIGNAL s_o_clk	: STD_LOGIC	:= '0';
	SIGNAL s_o_wrt	: STD_LOGIC	:= '0';
	SIGNAL s_o_data	: STD_LOGIC_VECTOR(13 DOWNTO 0)	:= (OTHERS => '0');

BEGIN

	-- DAC_AD9767 instantiation
	c_DAC_AD9767	: ENTITY work.DAC_AD9767
		PORT MAP (
			i_n_reset	=> s_i_n_reset,
			i_clk	=> s_i_clk,
			i_channel	=> s_i_channel,
			i_data	=> s_i_data,
			o_reset	=> s_o_reset,
			o_sel	=> s_o_sel,
			o_clk	=> s_o_clk,
			o_wrt	=> s_o_wrt,
			o_data	=> s_o_data
		);

	-- CLOCK
	p_clock : PROCESS
	BEGIN
		s_i_clk	<= '0';
		WAIT FOR PERIOD / 2;
		s_i_clk	<= '1';
		WAIT FOR PERIOD / 2;
	END PROCESS p_clock;
	
	-- Data. Increase the input data on each clock rising edge
	p_data	: PROCESS
	BEGIN
		WAIT FOR PERIOD / 2;
		WHILE (0 < 1) LOOP	-- Infinite loop
			s_i_data_tmp <= s_i_data_tmp + 1;
			WAIT FOR PERIOD;
		END LOOP;
	END PROCESS p_data;
	s_i_data <= STD_LOGIC_VECTOR(s_i_data_tmp);
	
	p_channel	: PROCESS
	BEGIN
		s_i_channel	<= '0';
		WAIT FOR 5 * PERIOD;
		s_i_channel	<= '1';
		WAIT FOR 5 * PERIOD;
	END PROCESS p_channel;

	-- Asynchronous reset
	p_reset	: PROCESS
	BEGIN
		s_i_n_reset	<= '1';
		WAIT FOR 10 * PERIOD;
		s_i_n_reset	<= '0';
		WAIT FOR 5 * PERIOD;
		s_i_n_reset	<= '1';
		WAIT FOR 10 * PERIOD;
		STOP;
	END PROCESS p_reset;

END behavioral;
