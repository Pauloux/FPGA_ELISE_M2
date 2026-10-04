-- Author: Paul ROUSSEAU
-- Date: 17 September 2026
--
-- Description:
-- Driver for the AD9767, a 14-bit DAC
-- Interleaved mode, one (choosable) channel only

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DAC_AD9767 IS
	PORT(
		i_n_reset	: IN STD_LOGIC;
		i_clk : IN STD_LOGIC;
		-- i_channel : 0 -> channel 2, 1 -> channel 1
		i_channel	: IN STD_LOGIC;
		i_data	: IN STD_LOGIC_VECTOR(13 DOWNTO 0);

		o_reset	: OUT STD_LOGIC := '0';
		o_sel	: OUT STD_LOGIC := '0';
		o_clk	: OUT STD_LOGIC := '0';
		o_wrt	: OUT STD_LOGIC := '0';
		o_data	: OUT STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0')
	);
END ENTITY DAC_AD9767;

ARCHITECTURE arch OF DAC_AD9767 IS
	
	SIGNAL s_data	: STD_LOGIC_VECTOR(13 DOWNTO 0);

BEGIN

	-- Clock
	-- Their rising edge must occur on i_clk falling edge. This garantees the
	-- data is stable when a rising edge occurs on o_clk and o_wrt.
	o_clk	<= NOT(i_clk);
	o_wrt	<= NOT(i_clk);

	-- Data
	PROCESS (i_n_reset, i_clk)
	BEGIN
		IF (i_n_reset = '0') THEN
			s_data	<= (OTHERS => '0');
		ELSIF (rising_edge(i_clk)) THEN
			s_data	<= i_data;
		ELSE
			s_data	<= s_data;	-- Latch
		END IF;
	END PROCESS;
	o_data	<= s_data;

	-- Channel selection
	o_sel	<= i_channel;

	-- Not used in interleaved mode
	o_reset	<= '0';

END arch;
