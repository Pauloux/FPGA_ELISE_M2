-- Author: Maxime BELLAUD
-- Date: 5 November 2026
--
-- Description:
-- Implementation of a Moore machine to control the DDS.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY moore_machine_SPI IS
	PORT(
		i_clk        : IN  STD_LOGIC;
		i_N_start   : IN  STD_LOGIC; -- WARNING : description use PULL-UP version
		i_done_spi   : IN  STD_LOGIC;
		o_enable_spi : OUT STD_LOGIC := '0';
		o_N_SS     : OUT STD_LOGIC := '1'
	);
END ENTITY;

ARCHITECTURE moore_machine_SPI_arch OF moore_machine_SPI IS

	TYPE t_state IS (S_IDLE, S_START, S_SEND, S_RELEASE);

	SIGNAL s_state : t_state := S_IDLE;

BEGIN

	-- Outputs depend on the current state only.
	PROCESS (s_state)
	BEGIN
		CASE s_state IS
			WHEN S_IDLE =>
				o_N_SS<= '1';
				o_enable_spi <= '0';
			WHEN S_START =>
				o_N_SS<= '0';
				o_enable_spi <= '0';
			WHEN S_SEND =>
				o_N_SS<= '0';
				o_enable_spi <= '1';
			WHEN S_RELEASE =>
				o_N_SS<= '1';
				o_enable_spi <= '0';
			WHEN OTHERS =>
				o_N_SS<= '1';
				o_enable_spi <= '0';
		END CASE;
	END PROCESS;

	PROCESS (i_clk)
	BEGIN
		IF rising_edge(i_clk) THEN
			CASE s_state IS
				WHEN S_IDLE =>
					IF i_N_start = '0' THEN
						s_state <= S_START;
					ELSE
						s_state <= S_IDLE;
					END IF;

				WHEN S_START =>
					s_state <= S_SEND;

				WHEN S_SEND =>
					IF i_N_start = '1' AND i_done_spi = '1' THEN
						s_state <= S_IDLE;
					ELSIF i_N_start = '0' AND i_done_spi = '1' THEN
						s_state <= S_RELEASE;
					ELSE
						s_state <= S_SEND;
					END IF;

				WHEN S_RELEASE =>
					IF i_N_start = '1' THEN
						s_state <= S_IDLE;
					ELSE
						s_state <= S_RELEASE;
					END IF;

				WHEN OTHERS =>
					s_state <= S_IDLE;
			END CASE;
		END IF;
	END PROCESS;

END moore_machine_SPI_arch;
