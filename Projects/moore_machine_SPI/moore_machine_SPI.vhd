-- Author: Maxime BELLAUD
-- Date: 5 November 2026
--
-- Description:
-- Implementation of a Moore machine to control the DDS.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY moore_machine_SPI IS
	GENERIC(
		N   :   INTEGER    :=  16
	);

	PORT(
		i_clk   :   IN  STD_LOGIC;
		i_button:   IN  STD_LOGIC; -- WARNING : description use PULL-UP version
		i_W     :   IN  STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		o_FSYNC :   OUT STD_LOGIC   :=  '1';
		o_SCLK  :   OUT STD_LOGIC   :=  '1';
		o_SDATA :   OUT STD_LOGIC   :=  '0'
	);
END ENTITY;

ARCHITECTURE moore_machine_SPI_arch OF moore_machine_SPI IS

	TYPE t_state IS (S_IDLE, S_START, S_SEND, S_RELEASE);

	SIGNAL s_state      : t_state   := S_IDLE;
	SIGNAL s_enable_spi : STD_LOGIC := '0';
	SIGNAL s_done_spi   : STD_LOGIC := '0';

BEGIN

--------------------------------------------------------------------------
    c_parallel_to_serial_converter: ENTITY work.parallel_to_serial_converter
	GENERIC MAP(
        CLK_PRESCALER=>6_250_000,
		PARALLEL_BUS_WIDTH => N
	)
	PORT MAP(
		-- Inputs
		i_clk=> i_clk,
		i_N_reset=> s_enable_spi,
		i_parallel_data	=> i_W,

		-- Outputs
		o_clk=>o_SCLK,
		o_serial_data=>o_SDATA,
		o_done=> s_done_spi
	);
---------------------------------------------------------------------

	-- Outputs depend on the current state only.
	PROCESS (s_state)
	BEGIN
		CASE s_state IS
			WHEN S_IDLE =>
				o_FSYNC <= '1';
				s_enable_spi <= '0';
			WHEN S_START =>
				o_FSYNC <= '0';
				s_enable_spi <= '0';
			WHEN S_SEND =>
				o_FSYNC <= '0';
				s_enable_spi <= '1';
			WHEN S_RELEASE =>
				o_FSYNC <= '1';
				s_enable_spi <= '0';
			WHEN OTHERS =>
				o_FSYNC <= '1';
				s_enable_spi <= '0';
		END CASE;
	END PROCESS;

	PROCESS (i_clk)
	BEGIN
		IF rising_edge(i_clk) THEN
			CASE s_state IS
				WHEN S_IDLE =>
					IF i_button = '0' THEN
						s_state <= S_START;
					ELSE
						s_state <= S_IDLE;
					END IF;

				WHEN S_START =>
					s_state <= S_SEND;

				WHEN S_SEND =>
					IF i_button = '1' AND s_done_spi = '1' THEN
						s_state <= S_IDLE;
					ELSIF i_button = '0' AND s_done_spi = '1' THEN
						s_state <= S_RELEASE;
					ELSE
						s_state <= S_SEND;
					END IF;

				WHEN S_RELEASE =>
					IF i_button = '1' THEN
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
