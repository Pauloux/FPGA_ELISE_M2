LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY freq_divider IS
	GENERIC (
		FREQ_IN : INTEGER := 125_000_000;
		FREQ_OUT : INTEGER := 1_000_000
	);
	PORT (
		i_clk : IN STD_LOGIC;
		o_overflow : OUT STD_LOGIC := '0'
	);
END ENTITY freq_divider;

ARCHITECTURE behavioral OF freq_divider IS

CONSTANT MAX_COUNT : INTEGER := (FREQ_IN / FREQ_OUT);

SIGNAL s_count : INTEGER RANGE 0 TO MAX_COUNT := 0;
	
BEGIN

	PROCESS
	BEGIN
		WAIT UNTIL rising_edge(i_clk);
		IF s_count < (MAX_COUNT - 1) THEN
			s_count <= s_count + 1;
			o_overflow <= '0';
		ELSE	-- s_count = MAX_COUNT
			s_count <= 0;
			o_overflow <= '1';
		END IF;
	END PROCESS;
END ARCHITECTURE behavioral;

