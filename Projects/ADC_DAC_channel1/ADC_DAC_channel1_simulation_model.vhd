-- SE July 2025
-- simple transfert of ADC to DAC
-- IN1 towards OUT1 at 125 MHz

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADC_DAC_channel1_simulation_model is
Port (
	adc_clk_i	: in STD_LOGIC;
	adc_dat_a_i : in std_logic_vector(13 downto 0);

	led_o : buffer STD_LOGIC_VECTOR (7 downto 0);
	
	--DAC signals
	dac_clk_o : out std_logic;
	dac_rst_o : out std_logic;
	dac_sel_o : out std_logic;
	dac_wrt_o : out std_logic;
	dac_dat_o : out std_logic_vector(13 downto 0)
	
	); 
end ADC_DAC_channel1_simulation_model; 
 
architecture a of ADC_DAC_channel1_simulation_model is
begin
	dac_clk_o <= not adc_clk_i;
	dac_wrt_o <= dac_clk_o;	-- = also "not adc_clk_i"
	dac_rst_o <='0';
	dac_sel_o <='0'; -- output 1 (et non 2), contrairement à datasheet AD9767
	process
	begin
		wait until rising_edge (adc_clk_i);
		dac_dat_o <= adc_dat_a_i ; 
		led_o <=adc_dat_a_i(13 downto 6);
	end process;
 end a;   

