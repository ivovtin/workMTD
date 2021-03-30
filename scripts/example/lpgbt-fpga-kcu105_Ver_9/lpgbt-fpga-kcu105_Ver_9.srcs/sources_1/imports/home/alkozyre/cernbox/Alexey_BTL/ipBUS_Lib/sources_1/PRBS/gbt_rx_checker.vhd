----------------------------------------------------------------------------------
-- Company:         CMS
-- Engineer:        Tugba Karakaya
-- 
-- Create Date:     10:16:32 09/04/2015 
-- Design Name:     H:/My Documents/WORK2/HCAL_ngFEC_fc7/trunk/ngFEC_fc7/fc7/fw/src/ngFEC/GBT_tools/gbt_rx_checker.vhd
-- Module Name:     gbt_rx_checker - Behavioral 
-- Project Name:    fpga_fc7_ngFEC
-- Target Devices:  FC7
-- Tool versions:   ISE 14.6
-- Description:     Comparing the PRBS_rx_pattern and PRBS_pattern_next
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 


-- Revisions  :
-- Date        Ver  Author      Description
-- 2019-09-03	1   Kozyrev		corrected a mistake in the work of error counters 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.prbs_pattern_generator.all;
entity gbt_rx_checker is
generic(
		seed_length     : natural;	
        nobReg          : natural	
	);		
port
    (                                     
		RX_Reset_i                           : IN  STD_LOGIC;
		Start_measurement_i                  : IN  STD_LOGIC;
		RX_Clk_En_i                          : IN  STD_LOGIC;
		RX_clk_i		                     : IN  STD_LOGIC;
		sfp_rx_lost		                     : IN  std_logic;
		sfp_tx_fault	                     : IN  std_logic;
		PRBS_rx_pattern_i                    : IN  std_logic_vector(seed_length-1 downto 0);
		
		PRBS_rx_pattern_error_o              : OUT  std_logic := '0';
		PRBS_rx_pattern_error_cnt_o          : OUT std_logic_vector(nobReg-1 downto 0);
		PRBS_rx_pattern_bitwise_error_cnt_o  : OUT std_logic_vector(nobReg-1 downto 0)
		
	);
end gbt_rx_checker;
architecture Behavioral of gbt_rx_checker is
signal PRBS_rx_pattern_error_cnt           : std_logic_vector(nobReg-1 downto 0):=(others =>'0');
signal PRBS_rx_pattern_bitwise_error_cnt   : std_logic_vector(nobReg-1 downto 0):=(others =>'0');
signal PRBS_pattern_previous               : std_logic_vector(seed_length-1 downto 0):=(others =>'0');
signal PRBS_pattern_prev_prev_s            : std_logic_vector(seed_length-1 downto 0):=(others =>'0');

begin
--wordwise

gbt_rx_error_detection : process (RX_clk_i,RX_Reset_i)
variable PRBS_pattern_next                        : std_logic_vector(seed_length-1 downto 0):=(others =>'0');
	begin
		if RX_Reset_i = '1' then
			PRBS_rx_pattern_error_cnt                <=(others=>'0');
			PRBS_rx_pattern_bitwise_error_cnt        <= (others=>'0');
		elsif rising_edge(RX_clk_i) then
			if(RX_Clk_En_i = '1') then
				if Start_measurement_i  = '1' then
					PRBS_rx_pattern_error_cnt           <= (others=>'0');
					PRBS_rx_pattern_bitwise_error_cnt   <= (others=>'0');
					if sfp_rx_lost = '0' and sfp_tx_fault = '0' then
						PRBS_pattern_previous               <= PRBS_rx_pattern_i;
					else 
						PRBS_pattern_previous               <= PRBS_pattern_previous;
					end if;
				elsif sfp_rx_lost = '0' and sfp_tx_fault = '0' then
					PRBS_pattern_next                   := lsfr_HBHE(PRBS_pattern_previous);--lsfr_HF(inv_prbs_seed(HF,seed_length),PRBS_pattern_previous);
					PRBS_rx_pattern_bitwise_error_cnt   <= PRBS_rx_pattern_bitwise_error_cnt + prbs_pattern_bitwise_err_cnt (PRBS_rx_pattern_i, PRBS_pattern_next,seed_length,nobReg);
					if PRBS_rx_pattern_i = PRBS_pattern_next then
						PRBS_rx_pattern_error_cnt       <= PRBS_rx_pattern_error_cnt; 
						PRBS_pattern_previous           <= PRBS_rx_pattern_i;
						PRBS_rx_pattern_error_o         <= '0';
					else
						PRBS_rx_pattern_error_cnt       <= PRBS_rx_pattern_error_cnt + '1';
						PRBS_pattern_previous           <= PRBS_pattern_next;
						PRBS_rx_pattern_error_o         <= '1';
					end if;	
				else
					PRBS_rx_pattern_error_cnt           <= PRBS_rx_pattern_error_cnt;
					PRBS_rx_pattern_bitwise_error_cnt   <= PRBS_rx_pattern_bitwise_error_cnt;
				end if;	
			end if;
		end if;
	 end process;	
	 PRBS_rx_pattern_bitwise_error_cnt_o            <= PRBS_rx_pattern_bitwise_error_cnt;
	 PRBS_rx_pattern_error_cnt_o                    <= PRBS_rx_pattern_error_cnt;
end Behavioral;

