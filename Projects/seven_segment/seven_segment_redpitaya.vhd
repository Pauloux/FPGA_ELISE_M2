LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY seven_segment_redpitaya IS
	PORT( 
		SW 	    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		gfedcba : OUT STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '1')
	);
END seven_segment_redpitaya;

ARCHITECTURE arch OF seven_segment_redpitaya IS

	COMPONENT seven_segment IS 
		PORT (
			i_digit 	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			o_gfedcba 	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '1');
		);
	END COMPONENT;

BEGIN 

	c_seven_segment : seven_segment 
	PORT MAP(
		i_digit 	=> SW,
		o_gfedcba 	=> gfedcba
	);	

END arch;

