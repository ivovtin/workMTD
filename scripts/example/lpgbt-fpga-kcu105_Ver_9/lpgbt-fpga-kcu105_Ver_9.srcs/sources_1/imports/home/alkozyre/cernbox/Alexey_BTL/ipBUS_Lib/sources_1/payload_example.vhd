---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


-- payload_simple_example
--
-- selection of different IPBus slaves without actual function,
-- just for performance evaluation of the IPbus/uhal system
--
-- Alessandro Thea, September 2018

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity payload is
    port(
        ipb_clk: in std_logic;
        ipb_rst: in std_logic;
        ipb_in: in ipb_wbus;
        ipb_out: out ipb_rbus;
        clk: in std_logic;
        rst: in std_logic;
        nuke: out std_logic;
        soft_rst: out std_logic;
        userled: out std_logic;
        
        Tx_clk_i              : in std_logic := '0';
        Tx_clk_en_i           : in std_logic := '1';
		Tx_we_i               : in std_logic := '0';
		Tx_addr_i             : in STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
		Tx_data_i             : in STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
		Tx_data_o             : out STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
		Tx_EC_bits_o          : out STD_LOGIC_VECTOR(1 DOWNTO 0);
		
		Rx_clk_i              : in std_logic := '0';
		Rx_clk_en_i           : in std_logic := '0';
		Rx_addr_i             : in STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
		Rx_data_i             : in STD_LOGIC_VECTOR(229 DOWNTO 0) := (others => '0');
		Rx_EC_bits_i          : in STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
		Rx_data_o             : out STD_LOGIC_VECTOR(31 DOWNTO 0):= (others => '0');
		
		Tx_IC_bits_o          : out STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '1');
		Rx_IC_bits_i          : in STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
		
		TxRx_Data_SrcRcvr_o   : out std_logic := '0';
		
		EC_Tx_start_frame_o   : out std_logic := '0';
		EC_Rx_recive_frame_o  : out std_logic := '0'
    );

end payload;

architecture rtl of payload is

     --signal PRBS_rx_pattern_error_cnt_s : ipb_reg_v(6 downto 0);
      
begin

    example: entity work.ipbus_example
        port map(
            ipb_clk => ipb_clk,
            ipb_rst => ipb_rst,
            ipb_in => ipb_in,
            ipb_out => ipb_out,
            nuke => nuke,
            soft_rst => soft_rst,
            userled => userled,
            
            Tx_clk_i      => Tx_clk_i,
            Tx_clk_en     => Tx_clk_en_i,
            Tx_addr_i     => Tx_addr_i,
            Tx_data_i     => Tx_data_i,
            Tx_we_i       => Tx_we_i,
            Tx_data_o     => Tx_data_o,
            
            Rx_clk_i      => Rx_clk_i,
            Rx_addr_i     => Rx_addr_i,
            Rx_data_i     => Rx_data_i,
            Rx_clk_en_i   => Rx_clk_en_i,
            Rx_EC_bits_i  => Rx_EC_bits_i,
            Rx_data_o     => Rx_data_o,
              
           -- Push_Tx_Cycle_o      => Push_Tx_Cycle_o,
            TxRx_Data_SrcRcvr_o  => TxRx_Data_SrcRcvr_o,
            Tx_EC_bits_o     => Tx_EC_bits_o,
            
            Tx_IC_bits_o  => Tx_IC_bits_o,
		    Rx_IC_bits_i  => Rx_IC_bits_i,
            
            EC_Tx_start_o    => EC_Tx_start_frame_o,
		    EC_Rx_received_o => EC_Rx_recive_frame_o

        );

end rtl;
