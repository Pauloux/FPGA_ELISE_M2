LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.ENV.ALL;

ENTITY simulation IS
END simulation;

ARCHITECTURE behavioral OF simulation IS

COMPONENT freq_divider IS
    GENERIC (
        FREQ_IN 	: INTEGER := 125_000_000;
        FREQ_OUT 	: INTEGER := 1_000_000
    );
    PORT (
        i_clk 		: IN STD_LOGIC;
    	o_overflow 	: OUT STD_LOGIC := '0'
    );
END COMPONENT;

SIGNAL s_i_clk 		: STD_LOGIC;
SIGNAL s_o_overflow : STD_LOGIC;
	
CONSTANT PERIOD : TIME := 8 ns;	-- 125 MHz

BEGIN

	c_freq_divider : freq_divider
	GENERIC MAP (
		FREQ_IN 	=> 125_000_000,
		FREQ_OUT 	=> 25_000_000
	)
	PORT MAP (
		 i_clk 		=> s_i_clk,
		 o_overflow => s_o_overflow
	);

	p_clock : PROCESS
	BEGIN
		FOR i IN 0 TO 20 LOOP
			s_i_clk <= '0';
			WAIT FOR PERIOD / 2;
			s_i_clk <= '1';
			WAIT FOR PERIOD / 2;
		END LOOP;
		STOP;
	END PROCESS p_clock;

END behavioral;
