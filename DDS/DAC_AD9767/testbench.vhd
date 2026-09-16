LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

	CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz

	SIGNAL s_i_clk	: STD_LOGIC;
	SIGNAL s_i_data	: STD_LOGIC_VECTOR(13 DOWNTO 0);
	SIGNAL s_i_data_tmp	: UNSIGNED(13 DOWNTO 0);

	SIGNAL s_o_reset	: STD_LOGIC;
	SIGNAL s_o_sel	: STD_LOGIC;
	SIGNAL s_o_clk	: STD_LOGIC;
	SIGNAL s_o_wrt	: STD_LOGIC;
	SIGNAL s_o_data	: STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	c_DAC_AD9767	: ENTITY work.DAC_AD9767
		PORT MAP (
			i_clk	=> s_i_clk,
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
	
	p_data	: PROCESS
	BEGIN
		WAIT FOR PERIOD / 2;
		WHILE (0 < 1) LOOP	-- Infinite loop
			s_i_data_tmp <= s_i_data_tmp + 1;
			WAIT FOR PERIOD;
		END LOOP;
	END PROCESS p_data;

	s_i_data <= STD_LOGIC_VECTOR(s_i_data);

END behavioral;
