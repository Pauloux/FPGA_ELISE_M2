-- Interleaved mode, channel 1 only

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DAC_AD9767 IS
	PORT(
		i_clk : IN STD_LOGIC;
		i_data	: IN STD_LOGIC_VECTOR(13 DOWNTO 0);

		o_reset	: OUT STD_LOGIC := '0';
		o_sel	: OUT STD_LOGIC := '0';
		o_clk	: OUT STD_LOGIC := '0';
		o_wrt	: OUT STD_LOGIC := '0';
		o_data	: OUT STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0')
	);
END ENTITY DAC_AD9767;

ARCHITECTURE arch OF DAC_AD9767 IS
BEGIN

	-- Clock
	-- Their rising edge must occur on i_clk falling edge
	-- This garantees the data is table when o_clk and o_wrt
	-- are on a rising edge.
	o_clk	<= NOT(i_clk);
	o_wrt	<= NOT(i_clk);

	-- Data
	PROCESS
	BEGIN
		WAIT UNTIL rising_edge(i_clk);
		o_data	<= i_data;
	END PROCESS;

	-- Others
	o_reset	<= '0';
	o_sel	<= '0';	-- Channel 1, different from the datasheet ?

END arch;
