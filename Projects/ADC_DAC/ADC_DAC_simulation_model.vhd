-- SE oct 2024
-- simple transfert ADC vers DAC
-- pas de PLL donc divise avec compteur
-- aclk à 125/8 MHz et dac_clk à 125/4 MHz
-- cf. timing fig66 AD9767

-- Simulation model modifications by Paul ROUSSEAU, October 2026

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADC_DAC_simulation_model is
Port (
	-- ADC
	adc_clk_i	: IN STD_LOGIC;
	adc_dat_a_i : in std_logic_vector(13 downto 0);
	adc_dat_b_i : in std_logic_vector(13 downto 0);
	
	-- DAC
	dac_clk_o : out std_logic;
	dac_rst_o : out std_logic;
	dac_sel_o : out std_logic;
	dac_wrt_o : out std_logic;
	dac_dat_o : out std_logic_vector(13 downto 0)
	); 
end ADC_DAC_simulation_model; 
 
architecture a of ADC_DAC_simulation_model is
	signal div : integer range 0 to 7;
	signal aclk : std_logic;
	signal dat_a_reg,dat_b_reg : std_logic_vector(13 downto 0);
	
begin

	  process
	  begin
		  wait until rising_edge (adc_clk_i);
			  CASE div is
			  WHEN 0 =>
				div <= 1;
				aclk <='0';
				dac_wrt_o <= '0'; 
				dac_clk_o <= '0';
				dac_sel_o <= '1';
				dac_dat_o <= dat_b_reg;
			  WHEN 1 =>
				div <= 2;
				aclk <='1';
				dac_wrt_o <= '1'; 
				dac_clk_o <= '1';
				dac_sel_o <= '1';
				dac_dat_o <= dat_b_reg;
			  WHEN 2 =>
				div <= 3;
				aclk <='0';
				dac_wrt_o <= '1'; 
				dac_clk_o <= '1';
				dac_sel_o <= '1';
				dac_dat_o <= dat_b_reg;
			  WHEN 3 =>
				div <= 4;
				aclk <='0';
				dac_wrt_o <= '0'; 
				dac_clk_o <= '0';
				dac_sel_o <= '1';
				dac_dat_o <= dat_b_reg;	
			  WHEN 4 =>
				div <= 5;
				aclk <='0';
				dac_wrt_o <= '0'; 
				dac_clk_o <= '0';
				dac_sel_o <= '0';
				dac_dat_o <= dat_a_reg;
			  WHEN 5 =>
				div <= 6;
				aclk <='0';
				dac_wrt_o <= '1'; 
				dac_clk_o <= '1';
				dac_sel_o <= '0';
				dac_dat_o <= dat_a_reg;
			  WHEN 6 =>
				div <= 7;
				aclk <='0';
				dac_wrt_o <= '1'; 
				dac_clk_o <= '1';
				dac_sel_o <= '0';
				dac_dat_o <= dat_a_reg;
			  WHEN OTHERS =>
				div <= 0;
				aclk <='0';
				dac_wrt_o <= '0'; 
				dac_clk_o <= '0';
				dac_sel_o <= '0';
				dac_dat_o <= dat_a_reg;
			END CASE;
			
			if (aclk = '1')	then	--else latch	
				dat_a_reg <= adc_dat_a_i ;
				dat_b_reg <= adc_dat_b_i ;
			else
				dat_a_reg <= dat_a_reg ;
				dat_b_reg <= dat_b_reg ;			
			end if;
	  end process;
	  dac_rst_o <='0';
end a;
