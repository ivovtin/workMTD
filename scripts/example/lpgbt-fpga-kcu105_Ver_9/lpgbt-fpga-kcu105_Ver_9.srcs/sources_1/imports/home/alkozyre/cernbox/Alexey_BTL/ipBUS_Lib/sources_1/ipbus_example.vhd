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


-- ipbus_example
--
-- selection of different IPBus slaves without actual function,
-- just for performance evaluation of the IPbus/uhal system
--
-- Kristian Harder, March 2014
-- based on code by Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

LIBRARY work;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_ipbus_example.all;
USE work.prbs_pattern_generator.ALL;

library UNISIM;
use UNISIM.VComponents.all;

--! Use SCA Package to define specific types (vector arrays)
use work.SCA_PKG.all;
--use IEEE.std_logic_unsigned.ALL;



entity ipbus_example is
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		nuke: out std_logic;
		soft_rst: out std_logic;
		userled: out std_logic;
		
	    Tx_clk_i      : in std_logic; 
	    Tx_clk_en     : in std_logic := '1';
		Tx_we_i       : in std_logic := '0';
		Tx_Reset_i    : in std_logic := '0';
		Tx_addr_i     : in STD_LOGIC_VECTOR(11 DOWNTO 0):= (others => '0');
		Tx_data_i     : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		Tx_data_o     : out STD_LOGIC_VECTOR(31 DOWNTO 0);
		Tx_EC_bits_o  : out STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '1');
		
		Rx_clk_i      : in std_logic := '0';
		Rx_clk_en_i   : in std_logic := '0';
		Rx_addr_i     : in STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
		Rx_data_i     : in STD_LOGIC_VECTOR(229 DOWNTO 0) := (others => '0');
		Rx_EC_bits_i  : in STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
		Rx_data_o     : out STD_LOGIC_VECTOR(31 DOWNTO 0):= (others => '0');

		TxRx_Data_SrcRcvr_o : out std_logic := '0';
		
		Tx_IC_bits_o  : out STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '1');
		Rx_IC_bits_i  : in STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
		
	
		-- test output
		EC_Tx_start_o    : out std_logic := '0';
		EC_Rx_received_o : out std_logic := '0'
		
    	
	
	);

end ipbus_example;

architecture rtl of ipbus_example is

       signal ipb_rdata: std_logic_vector(31 downto 0) ;
       signal ipb_wdata: std_logic_vector(31 downto 0);
       signal addr : STD_LOGIC_VECTOR(11 DOWNTO 0);
       signal ipb_write: STD_LOGIC;
    
       signal ipbw: ipb_wbus_array(N_SLAVES - 1 downto 0);
	   signal ipbr: ipb_rbus_array(N_SLAVES - 1 downto 0);
	   signal ctrl, stat: ipb_reg_v(0 downto 0);
	   --signal ipb_strobe: std_logic_vector(0 downto 0);
	   --signal ipb_addr: std_logic_vector(11 downto 0); 

	   signal RxDRAM_addr_s    : std_logic_vector(11 downto 0); 
	   signal TxDRAM_addr_s    : std_logic_vector(11 downto 0);
	   
	   signal Tx_Data_so       : std_logic_vector(31 downto 0)  := (others => '0');
	   signal TxDRAM_data_so   : std_logic_vector(31 downto 0)  := (others => '0');
	   signal PRBS_Gen_Data_s   : std_logic_vector(31 downto 0) := (others => '0');
	   
	   

	   -- Rx parametric counter
	   constant RX_COUNT_MAX : integer := 2**RxDRAM_addr_s'LENGTH;
	   signal RxAddr_Cnt : integer range 0 to RX_COUNT_MAX-1 := 0;
	   
	   -- Tx parametric counter
	   constant TX_COUNT_MAX : integer := 2**TxDRAM_addr_s'LENGTH;
	   signal TxAddr_Cnt : integer range 0 to TX_COUNT_MAX-1 := 0;

	   signal Push_Cycle_s : STD_LOGIC := '0';

	   signal Strb0_s,Strb1_s,Strb2_s, StrbAll_s : STD_LOGIC := '0';
	   signal TrigStrb_s : STD_LOGIC := '0';
	   
	   constant INIT_Cnt_Addr : integer := 0;
	   constant MAX_COUNT_Addr : integer := 0;

	   signal RxReg_data_s      : std_logic_vector(229 downto 0) :=(others => '0'); 
	   signal Rx_data_s         : std_logic_vector(31 downto 0) :=(others => '0'); 
	   signal RxDataCopyCycle_s : STD_LOGIC := '0';
	   signal end_CopyCycle_s   : STD_LOGIC := '0';
	   --signal Rx_we_s           : STD_LOGIC := '0';
	   
	   signal Set_MODE_s        : std_logic_vector(31 downto 0) :=(others => '0'); 
	   signal TxRx_Data_SrcRcvr_s  : STD_LOGIC := '0';
	   signal Tx_Reset_s        : STD_LOGIC := '0'; 
	   
	   signal Rx_Reset_s        : STD_LOGIC := '0';
	  
	   signal PRBS_Checker_EN_s : STD_LOGIC := '0';
	   signal RxDRAM_EN_s       : STD_LOGIC := '0';
	   signal Push_PRBS_Chercker_s  : STD_LOGIC := '0';
	   signal PRBS_Checker_EN_OR_s  : STD_LOGIC := '0';
	   signal PRBS_Checker_Strb_s  : STD_LOGIC := '0';
	   
	   --type PRBS_Array is array (0 to 6) of std_logic_vector(31 downto 0);
	   signal PRBS_rx_pattern_error_cnt_s : ipb_reg_v(6 downto 0) := (others => (others => '0'));
       signal PRBS_rx_pattern_bitwise_error_cnt_s : ipb_reg_v(6 downto 0) := (others => (others => '0'));
       signal PRBS_rx_pattern_error_s  : std_logic_vector(6 downto 0) :=(others => '0'); 
       signal OR_rx_pattern_error_s    : STD_LOGIC := '0';
	   signal Rx_Pattern_Error_Cnt     : integer range 0 to 31 := 0; -- Rx pattern error counter
	   signal Rx_Pattern_Error_Reg_s   : std_logic_vector(31 downto 0) :=(others => '0'); 
 
       signal ErrCntStrb0_s  : STD_LOGIC := '0';
	   signal ErrCntStrb1_s  : STD_LOGIC := '0';
	   signal ErrCntStrbOR_s : STD_LOGIC := '0'; -- expand the signal for transmission to another clock domain
       signal ErrCntStrbES_s : STD_LOGIC := '0';
       signal ErrCntStrbSyncES_s : STD_LOGIC := '0'; --<<<----------<<<
       signal Reg_enable_s   : STD_LOGIC := '0'; 
	   signal ErrCntReg_s    : std_logic_vector(31 downto 0) :=(others => '0');
	   
	   signal FER_RST_Strb0_s    : STD_LOGIC := '0';
	   signal FER_RST_Strb1_s    : STD_LOGIC := '0';
	   signal FER_RST_StrbAll_s  : STD_LOGIC := '0';
       signal FER_RST_TrigStrb_s : STD_LOGIC := '0';
       signal FER_RST_SyncTrigStrb_s : STD_LOGIC := '0';
       signal FER_RST_Rx_ES_s    : STD_LOGIC := '0';
       
       
--       signal EC_RAM_addr_s    : std_logic_vector(15 downto 0); 
--	   signal EC_Data_out_s    : std_logic_vector(1 downto 0);
	   
	   signal EC_EOF_Reg_s            : std_logic_vector(31 downto 0);
	   signal EC_Frame_addr_s         : std_logic_vector(9 downto 0);
	   signal EC_Frame_cnt            : integer range 0 to 1023 := 0;
	   signal Next_EC_TxFrame_s       : STD_LOGIC := '0';
	   signal Next_EC_TxFrame_En_s    : STD_LOGIC := '0';
	   signal Tx_Frame_s              : STD_LOGIC := '0';
	   
	   signal Rx_received_Trig_s      : STD_LOGIC := '0';
	   signal Rx_received_shaped_s    : STD_LOGIC := '0';
	   signal Tx_received_strb0_s     : STD_LOGIC := '0';
	   signal SCA_frame_TxRx_s        : STD_LOGIC := '0';
	   
      
--       signal Init_Tx_Frame_s : STD_LOGIC := '0';
--       signal Rx_Frame_Correct_s : STD_LOGIC := '0';
--       signal Next_EC_TxFrame_s : STD_LOGIC := '0';
--       signal Next_EC_FrameAddr_s : STD_LOGIC := '0';
--       signal Next_EC_TxFrame_En_s : STD_LOGIC := '0';
--       signal Tx_Frame_s : STD_LOGIC := '0';
--       signal EC_2bits_s    : std_logic_vector(1 downto 0);
--       signal EC_Tx_RAM_2bits_addr_s    : std_logic_vector(5 downto 0);
--       signal EC_Tx_RAM_Frame_addr_s    : std_logic_vector(8 downto 0) :=(others => '0');
--       signal EC_Tx_RAM_Frame_addr_RST_s : STD_LOGIC := '0';
--       signal EC_Fame_beg_s : STD_LOGIC := '0';
--       signal EC_Fame_beg_trig_s : STD_LOGIC := '0';
       
--       signal EC_Rx_RAM_2bits_addr_s    : std_logic_vector(5 downto 0);
--       signal EC_Rx_RAM_Frame_addr_s    : std_logic_vector(8 downto 0) :=(others => '0');
--       signal EC_Rx_RAM_addr_s          : std_logic_vector(15 downto 0);
--       signal EC_Rx_2bits_s             : std_logic_vector(1 downto 0);
--       signal EC_Rx_RAM_we_s            : STD_LOGIC := '0';
       
--       signal EC_Rx_RAM_16bits_addr_s   : std_logic_vector(2 downto 0);
--       signal EC_Rx_RAM16_addr_s        : std_logic_vector(12 downto 0);
--       signal EC_Rx_16bits_s            : std_logic_vector(15 downto 0);
--       signal EC_Rx_RAM_16bits_we_s     : STD_LOGIC := '0';
       
      ----------------------------------------------------------------------------------------------------
      ------------------------------------- EC and IC signals --------------------------------------------
      ----------------------------------------------------------------------------------------------------
        -- initialize IC and EC moduls
       signal reset_sca                    : STD_LOGIC := '0';
  
      --------------------------------- EC signals ----------------------------------- 
       -- SCA frame fields
       signal tx_address_si                  : std_logic_vector(7 downto 0);   --! Command: address field (According to the SCA manual)
       signal tx_transID_si                  : std_logic_vector(7 downto 0);   --! Command: transaction ID field (According to the SCA manual)
       signal tx_channel_si                  : std_logic_vector(7 downto 0);   --! Command: channel field (According to the SCA manual)
       signal tx_command_si                  : std_logic_vector(7 downto 0);   --! Command: command field (According to the SCA manual)
       signal tx_data_si                     : std_logic_vector(31 downto 0);  --! Command: data field (According to the SCA manual)

       signal rx_received_so                 : std_logic_vector(0 downto 0);   --! Reply received flag (pulse)
       signal rx_address_so                  : reg8_arr(0 downto 0);           --! Reply: address field (According to the SCA manual)
       signal rx_control_so                  : reg8_arr(0 downto 0);           --! Reply: control field (According to the SCA manual)
       signal rx_transID_so                  : reg8_arr(0 downto 0);           --! Reply: transaction ID field (According to the SCA manual)
       signal rx_channel_so                  : reg8_arr(0 downto 0);           --! Reply: channel field (According to the SCA manual)
       signal rx_len_so                      : reg8_arr(0 downto 0);           --! Reply: len field (According to the SCA manual)
       signal rx_error_so                    : reg8_arr(0 downto 0);           --! Reply: error field (According to the SCA manual)
       signal rx_data_so                     : reg32_arr(0 downto 0);          --! Reply: data field (According to the SCA manual)

        -- EC line
       signal ec_data_so                     : reg2_arr(0 downto 0);           --! (TX) Array of bits to be mapped to the TX GBT-Frame
       signal ec_data_si                     : reg2_arr(0 downto 0);           --! (RX) Array of bits to be mapped to the RX GBT-Frame

       signal tx_elink_H_so                  : std_logic_vector(31 downto 0);
       signal tx_sca_H_so                    : std_logic_vector(31 downto 0);
       signal tx_sca_D_so                    : std_logic_vector(31 downto 0);
       
       signal rx_we_si                        : STD_LOGIC := '0';
       signal rx_sca_H_si                    : std_logic_vector(31 downto 0);
       signal rx_sca_D_si                    : std_logic_vector(31 downto 0);
        
       -- SCA reset command
       signal ipb_SCA_rst_cmd_strb_s         : STD_LOGIC := '0';
       signal ipb_SCA_rst_cmd_ES_s           : STD_LOGIC := '0';
       signal lpGBT_SCA_rst_cmd_strb0_s      : STD_LOGIC := '0';
       signal lpGBT_SCA_rst_cmd_strb1_s      : STD_LOGIC := '0';
       signal lpGBT_SCA_rst_cmd_s            : STD_LOGIC := '0'; --! Send a reset command to the enabled SCAs
       -- SCA connect command
       signal ipb_SCA_connect_cmd_strb_s     : STD_LOGIC := '0';
       signal ipb_SCA_connect_cmd_ES_s       : STD_LOGIC := '0';
       signal lpGBT_SCA_connect_cmd_strb0_s  : STD_LOGIC := '0';
       signal lpGBT_SCA_connect_cmd_strb1_s  : STD_LOGIC := '0';
       signal lpGBT_SCA_connect_cmd_s        : STD_LOGIC := '0'; --! Send a connect command to the enabled SCAs
       -- SCA start command
       signal ipb_SCA_start_cmd_strb_s       : STD_LOGIC := '0';
       signal ipb_SCA_start_cmd_ES_s         : STD_LOGIC := '0';
       signal lpGBT_SCA_start_cmd_strb0_s    : STD_LOGIC := '0';
       signal lpGBT_SCA_start_cmd_strb1_s    : STD_LOGIC := '0';
       signal lpGBT_SCA_start_cmd_s          : STD_LOGIC := '0';  ---! Send the command set in input to the enabled SCAs
       signal SCA_start_cmd_s                : STD_LOGIC := '0';  ---! lpGBT_SCA_start_cmd_s or start next frame
        
      --------------------------------- IC signals -----------------------------------
       -- IC configuration
       signal GBTx_address_to_gbtic_si       : std_logic_vector(7 downto 0) :=(others => '0');
       signal Register_addr_to_gbtic_si      : std_logic_vector(15 downto 0) :=(others => '0');
       signal nb_to_be_read_to_gbtic_si      : std_logic_vector(15 downto 0) :=(others => '0');
       -- IC control
       signal start_write_to_gbtic_si        : std_logic := '0';
       signal start_read_to_gbtic_si         : std_logic := '0';
       
       signal ipb_IC_read_cmd_strb_s         : std_logic := '0';
       signal lpGBT_IC_read_cmd_strb0_s      : std_logic := '0';
       signal lpGBT_IC_read_cmd_s            : std_logic := '0';
       
       signal ipb_IC_write_cmd_strb_s         : std_logic := '0';
       signal lpGBT_IC_write_cmd_strb0_s      : std_logic := '0';
       signal lpGBT_IC_write_cmd_s            : std_logic := '0';
             	     
       -- IC FIFO control
       signal ipBUS_to_IC_tx_FIFO_Data_s     : std_logic_vector(31 downto 0);
       signal ipBUS_to_IC_tx_Config_s        : std_logic_vector(31 downto 0);
       signal ipBUS_to_IC_tx_NWRead_s        : std_logic_vector(31 downto 0);
       
       signal data_to_gbtic_si               : std_logic_vector(7 downto 0) :=(others => '0');
       signal wr_to_gbtic_Trig_si            : std_logic := '0';
       signal wr_to_gbtic_si                 : std_logic := '0';
       
       signal IC_rx_FIFO_Data_to_ipBUS_s     : std_logic_vector(31 downto 0) :=(others => '0');
       
       signal data_from_gbtic_so             : std_logic_vector(7 downto 0) :=(others => '0');
       signal rd_to_gbtic_Trig_si            : std_logic := '0';
       signal rd_to_gbtic_si                 : std_logic := '0';
       
  
       -- IC Status
       signal ic_rd_gbtx_addr                : std_logic_vector(7 downto 0);
       signal ic_rd_mem_ptr                  : std_logic_vector(15 downto 0);
       signal ic_rd_nb_of_words              : std_logic_vector(15 downto 0);
       signal ic_ready                       : std_logic;
       signal ic_empty                       : std_logic;
       
       signal ipb_IC_read_Status_strb_s      : std_logic;
       signal ipb_IC_read_Status_En_s        : std_logic;
       signal Status_from_IC_Reg_s           : std_logic_vector(31 downto 0);
  
      -- IC lines
       signal ic_data_so                     : std_logic_vector(1 downto 0);  --! (TX) Array of bits to be mapped to the TX GBT-Frame (bits 83/84)
       signal ic_data_si                     : std_logic_vector(1 downto 0) :=(others => '0');  --! (RX) Array of bits to be mapped to the RX GBT-Frame (bits 83/84)

    
--    signal GBTx_address               : std_logic_vector(7 downto 0);
--    signal Register_ptr               : std_logic_vector(15 downto 0);
--    signal ic_start_wr                : std_logic;
--    signal ic_wr                      : std_logic;
--    signal ic_data_wr                 : std_logic_vector(7 downto 0);
--    signal ic_start_rd                : std_logic;
--    signal ic_nb_to_be_read_rd        : std_logic_vector(15 downto 0);
--    signal ic_empty_rd                : std_logic;
--    signal ic_rd                      : std_logic;
--    signal ic_data_rd                 : std_logic_vector(7 downto 0);
    
--    signal GBTx_rd_addr               : std_logic_vector(7 downto 0);
--    signal GBTx_rd_mem_ptr            : std_logic_vector(15 downto 0);
--    signal GBTx_rd_mem_size           : std_logic_vector(15 downto 0);
    
  
         
----------------------------- test output ------------------------------      
       -- leds ctrl sections for test outputs
       signal led_s        : std_logic_vector(1 downto 0);
       signal Rx_received_strb0_s      : STD_LOGIC := '0';
       signal Rx_received_strb1_s      : STD_LOGIC := '0';
       signal Rx_Pulse_shaper_s        : STD_LOGIC := '0';
       
       
       signal Rx_Pulse_shaper_strb_s        : STD_LOGIC := '0';

  
begin
   
---------------------------------------------------------------------------------------
----------------------------- ipbus address decode -------------------------------------
		
	fabric: entity work.ipbus_fabric_sel
    generic map(
    	NSLV => N_SLAVES,
    	SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      sel => ipbus_sel_ipbus_example(ipb_in.ipb_addr),
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );

---------------------------------------------------------------------------------------
------------------------------------ SLAVE 0 ------------------------------------------
-- Slave 0: id / rst reg

	slave0: entity work.ipbus_ctrlreg_v
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_CSR),
			ipbus_out => ipbr(N_SLV_CSR),
			d => stat,
			q => ctrl
		);
		
		stat(0) <= X"abcdfe19";
		soft_rst <= ctrl(0)(0);
		nuke <= ctrl(0)(1);
		userled <= ctrl(0)(2);
		

---------------------------------------------------------------------------------------
------------------------------------ SLAVE 1 ------------------------------------------
-- Slave 1: IC Tx Data register

	slave1: entity work.ipbus_reg_v
	    generic map ( N_REG => 1 )
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_IC_TxDATA_REG),
			ipbus_out => ipbr(N_SLV_IC_TxDATA_REG),
			q(0) => ipBUS_to_IC_tx_FIFO_Data_s
			-- q(0) FIFO data
  
		);
		data_to_gbtic_si          <= ipBUS_to_IC_tx_FIFO_Data_s(7 downto 0); -- Tx FIFO data
		
		Write_data_to_IC_FIFO: process(Tx_clk_i)
	          begin
	             if rising_edge(Tx_clk_i) then 
	                  wr_to_gbtic_Trig_si <= ipbr(N_SLV_IC_TxDATA_REG).ipb_ack;
                      wr_to_gbtic_si <= ipbr(N_SLV_IC_TxDATA_REG).ipb_ack and not wr_to_gbtic_Trig_si;
                 end if;
	    end process;
		

---------------------------------------------------------------------------------------
------------------------------------ SLAVE 2 ------------------------------------------
-- Slave 2: IC Tx Configuration register
		slave2: entity work.ipbus_reg_v
	    generic map ( N_REG => 1 )
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_IC_TxConf_REG),
			ipbus_out => ipbr(N_SLV_IC_TxConf_REG),
			q(0) => ipBUS_to_IC_tx_Config_s
    	-- q(0) IC Tx Configuration: I2C slave address 0..7bits, Internal address 23..8bits = 24bits
		);
		GBTx_address_to_gbtic_si  <= ipBUS_to_IC_tx_Config_s(7 downto 0);    -- I2C slave address
        Register_addr_to_gbtic_si <= ipBUS_to_IC_tx_Config_s(23 downto 8);   -- Internal address

---------------------------------------------------------------------------------------
------------------------------------ SLAVE 3 ------------------------------------------	
-- Slave 3: IC Tx Configuration register: Number of words/bytes to be read (only for read transactions)
		slave3: entity work.ipbus_reg_v
	    generic map ( N_REG => 1 )
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_IC_TxNWRead_REG),
			ipbus_out => ipbr(N_SLV_IC_TxNWRead_REG),
			q(0) => ipBUS_to_IC_tx_NWRead_s
    	-- q(0) IC Tx Configuration2: Number of words/bytes to be read (only for read transactions)
		);
		nb_to_be_read_to_gbtic_si  <= ipBUS_to_IC_tx_NWRead_s(15 downto 0);    -- Number of words/bytes to be read (only for read transactions)


---------------------------------------------------------------------------------------
------------------------------------ SLAVE 4 ------------------------------------------		
 --Slave 4: TxBRAM	
	slave4: entity work.ipbus_bram 
	   PORT MAP (
           clka      => ipb_clk,
           ipbus_in  => ipbw(N_SLV_TxBRAM),
           ipbus_out => ipbr(N_SLV_TxBRAM),
           
           clkb     => Tx_clk_i,
           addrb    => Tx_addr_i,
           inb      => Tx_data_i,
           web_i    => Tx_we_i,
           qb       => TxDRAM_data_so --Tx_data_o
        );	
    Tx_data_o <= Tx_Data_so;

    -- PRBS generator
    prbs: entity work.prbs  
       generic map(seed => set_initialValue(HBHE,SEED_31,inv_prbs_seed(HBHE,SEED_31)),inverter=>inv_prbs_seed(HBHE,SEED_31),hbhehf=>HBHE)
	      port map (
                    prbs_o => PRBS_Gen_Data_s(31 downto 1),
                    clk    => Tx_clk_i,
                    clk_en => Tx_clk_en,
                    reset  => Tx_Reset_s
                    );
    PRBS_Gen_Data_s(0) <= '1';
    -- PRBS_Gen_Data_s consist of 31 MSB bits from PRBS generator + 1 constant bit = 32 bits

---------------------------------------------------------------------------------------        
------------------------------------ SLAVE 5 ------------------------------------------
--Slave 5: RxBRAM	
	slave5: entity work.ipbus_bram 
	   PORT MAP (
           clka => ipb_clk,
           ipbus_in => ipbw(N_SLV_RxBRAM),
           ipbus_out => ipbr(N_SLV_RxBRAM),
           
           clkb     => Rx_clk_i,
           addrb    => RxDRAM_addr_s,
           inb      => Rx_data_s,
           web_i    => RxDRAM_EN_s, --RxDataCopyCycle_s, --Rx_we_s,
           qb       => Rx_data_o
        );
    
    -- 230bit -> 7x32bit converter   
    process(Rx_clk_i)
	  begin
		      if rising_edge(Rx_clk_i) then
		         PRBS_Checker_Strb_s <= Rx_clk_en_i;
		         if Rx_clk_en_i = '1' then 
		              RxReg_data_s <= Rx_data_i; 
		              RxDataCopyCycle_s <= '1';  
		         end if; 
		         if end_CopyCycle_s = '1' then
		              RxDataCopyCycle_s <= '0';
		         end if;                                                            
		      end if;
		      
		      if rising_edge(Rx_clk_i)  then
                 if RxDataCopyCycle_s = '1' then 
		              RxAddr_Cnt <= RxAddr_Cnt + 1;
                                            else
		              RxAddr_Cnt <= INIT_Cnt_Addr;  
 		         end if;  
		      end if;	  

	          --if Addr_Cnt = (to_unsigned(7, RxDRAM_addr_s'LENGTH)) then
	          if RxAddr_Cnt = INIT_Cnt_Addr + 7 then
		              end_CopyCycle_s <= '1'; 
		                                                           else
		              end_CopyCycle_s <= '0';                                             
	          end if;
	          
	          case RxAddr_Cnt is
                    when 0      => Rx_data_s <= RxReg_data_s(31 downto 0);
                    when 1      => Rx_data_s <= RxReg_data_s(63 downto 32);
                    when 2      => Rx_data_s <= RxReg_data_s(95 downto 64);
                    when 3      => Rx_data_s <= RxReg_data_s(127 downto 96);
                    when 4      => Rx_data_s <= RxReg_data_s(159 downto 128);
                    when 5      => Rx_data_s <= RxReg_data_s(191 downto 160);
                    when 6      => Rx_data_s <= RxReg_data_s(223 downto 192);
                    when others => Rx_data_s <= (others => '0');
              end case;
            
            -- Rx Reciver MUX
              if TxRx_Data_SrcRcvr_s = '1' then
                    PRBS_Checker_EN_s <= PRBS_Checker_Strb_s;   
              else
                    PRBS_Checker_EN_s <= '0'; 
                    RxDRAM_EN_s <= RxDataCopyCycle_s;                        
--                    if RxDataCopyCycle_s = '1' then 
--                        RxDRAM_EN_s <= '1';
--                                               else
--                        RxDRAM_EN_s <= '0';  
--                    end if;                
              end if;
              -- count Rx pattern errors
              if rising_edge(Rx_clk_i)  then
                 if OR_rx_pattern_error_s = '1' and PRBS_Checker_EN_OR_s = '1' then 
		              Rx_Pattern_Error_Cnt <= Rx_Pattern_Error_Cnt + 1;
   		         end if;  
   		         if FER_RST_Rx_ES_s = '1' then ----------------------------------------------------------------------
		              Rx_Pattern_Error_Cnt <= 0;
		         end if;
 		         Rx_Pattern_Error_Reg_s <= std_logic_vector(to_unsigned(Rx_Pattern_Error_Cnt, 32));
		      end if;
--		      for I in 0 to 6 loop 	  
--                  OR_rx_pattern_error_s <= OR_rx_pattern_error_s or PRBS_rx_pattern_error_s(I);
--              end loop;
              OR_rx_pattern_error_s <= PRBS_rx_pattern_error_s(0) or PRBS_rx_pattern_error_s(1) or PRBS_rx_pattern_error_s(2) or PRBS_rx_pattern_error_s(3) or PRBS_rx_pattern_error_s(4) or PRBS_rx_pattern_error_s(5) or PRBS_rx_pattern_error_s(6);
	end process;
	RxDRAM_addr_s <= std_logic_vector(to_unsigned(RxAddr_Cnt, RxDRAM_addr_s'LENGTH));

	
 --lpGBT_rx_checker	
   PRBS_Checkers_Generate: 
        for I in 0 to 6 generate
            lpGBT_rx_checker: entity work.gbt_rx_checker
		      generic map(seed_length => 31,nobReg => 32)	
		      port map(                                  
			             RX_Reset_i                          => Rx_Reset_s,
			             Start_measurement_i                 => Push_PRBS_Chercker_s,
			             RX_Clk_En_i                         => PRBS_Checker_EN_OR_s, -- PRBS_Checker_EN_s
			             RX_clk_i							 => Rx_clk_i,
			             sfp_rx_lost		                 => '0',
			             sfp_tx_fault	                     => '0',
			             PRBS_rx_pattern_i                   => RxReg_data_s((I+1)*32-1 downto I*32+1), 
			             PRBS_rx_pattern_error_o             => PRBS_rx_pattern_error_s(I),
			             PRBS_rx_pattern_error_cnt_o         => PRBS_rx_pattern_error_cnt_s(I),
			             PRBS_rx_pattern_bitwise_error_cnt_o => PRBS_rx_pattern_bitwise_error_cnt_s(I)
		              );
		              
        end generate PRBS_Checkers_Generate;         
		PRBS_Checker_EN_OR_s <= (PRBS_Checker_EN_s or Push_PRBS_Chercker_s);
	

---------------------------------------------------------------------------------------
------------------------------------ SLAVE 7 ------------------------------------------
-- Slave 7: change mode register
	slave7: entity work.ipbus_reg_v
		generic map ( N_REG => 1 )
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_CTRL_MODE_REG),
			ipbus_out => ipbr(N_SLV_CTRL_MODE_REG),
			q(0) => Set_MODE_s
		);
		TxRx_Data_SrcRcvr_o <= TxRx_Data_SrcRcvr_s;--Set_MODE_s(0);
        Init_PRBS_Gen: process(Tx_clk_i)
	          begin
	             if rising_edge(Tx_clk_i) then          
		            if Tx_clk_en = '1' then 
		              TxRx_Data_SrcRcvr_s <= Set_MODE_s(0);
		            end if; 
                 end if;
		         Tx_Reset_s <= Set_MODE_s(0) and not TxRx_Data_SrcRcvr_s;
	    end process;

       -- MUX Switch_source
       Tx_Data_so <= PRBS_Gen_Data_s when (TxRx_Data_SrcRcvr_s = '1') else
                     TxDRAM_data_so; 
	    
	    Init_PRBS_Checker: process(Rx_clk_i)
	          begin
	             if rising_edge(Rx_clk_i) then          
		              Push_PRBS_Chercker_s <= Set_MODE_s(0) and not TxRx_Data_SrcRcvr_s;
                 end if;
	    end process;

---------------------------------------------------------------------------------------
------------------------------------ SLAVE 8,9 ------------------------------------------
  --Slave 8,9: (read) or (read and reset) FER counter
  slave8: process(ipb_clk, Rx_clk_i)
	          begin
	              if rising_edge(ipb_clk) then
	                 -- read strobe
	                  ErrCntStrb0_s  <= ipbw(N_SLV_lpGBT_ERR_CNT).ipb_strobe;
	                  ErrCntStrb1_s  <= ErrCntStrb0_s;
	                  ErrCntStrbOR_s <= ErrCntStrb0_s or ipbw(N_SLV_lpGBT_ERR_CNT).ipb_strobe; -- expand the signal for transmission to another clock domain
	                 -- read and reset strobe  
	                  FER_RST_Strb0_s   <= ipbw(N_SLV_lpGBT_ERR_CNT_RD_RST).ipb_strobe;
	                  FER_RST_Strb1_s   <= FER_RST_Strb0_s;
	                  FER_RST_StrbAll_s <= FER_RST_Strb0_s or ipbw(N_SLV_lpGBT_ERR_CNT_RD_RST).ipb_strobe; -- expand the signal for transmission to another clock domain
      	          end if;
	              if rising_edge(Rx_clk_i) then  
	                          ErrCntStrbES_s <= ErrCntStrbOR_s;
	                          ErrCntStrbSyncES_s <= ErrCntStrbES_s;
		                      --Reg_enable_s <= ErrCntStrbOR_s and not ErrCntStrbES_s;
		                      Reg_enable_s <= ErrCntStrbES_s and not ErrCntStrbSyncES_s;
		                      --Reg_enable_s <= ErrCntStrbES_s and not Reg_enable_s;
		                      
		                      FER_RST_TrigStrb_s <= FER_RST_StrbAll_s;
		                      FER_RST_SyncTrigStrb_s <= FER_RST_TrigStrb_s;
		                      --FER_RST_Rx_ES_s <= FER_RST_StrbAll_s and not FER_RST_TrigStrb_s;
		                      FER_RST_Rx_ES_s <= FER_RST_TrigStrb_s and not FER_RST_SyncTrigStrb_s;
		                       
		                      if Reg_enable_s = '1' or FER_RST_Rx_ES_s = '1' then
		                          ErrCntReg_s <= Rx_Pattern_Error_Reg_s;
		                      end if;
		          end if;
                  -- answer to ipBUS
                   -- read answer 
		          if rising_edge(ipb_clk) then  
		              ipbr(N_SLV_lpGBT_ERR_CNT).ipb_ack <= ErrCntStrb0_s and not ipbr(N_SLV_lpGBT_ERR_CNT).ipb_ack;--ErrCntStrb1_s;               
		          end if;
                  ipbr(N_SLV_lpGBT_ERR_CNT).ipb_rdata <= ErrCntReg_s;  
                  ipbr(N_SLV_lpGBT_ERR_CNT).ipb_err <= '0'; 
                   -- read and reset answer 
                  if rising_edge(ipb_clk) then  
		              ipbr(N_SLV_lpGBT_ERR_CNT_RD_RST).ipb_ack <= FER_RST_Strb0_s and not ipbr(N_SLV_lpGBT_ERR_CNT_RD_RST).ipb_ack;--FER_RST_Strb1_s;               
		          end if;
                  ipbr(N_SLV_lpGBT_ERR_CNT_RD_RST).ipb_rdata <= ErrCntReg_s;  
                  ipbr(N_SLV_lpGBT_ERR_CNT_RD_RST).ipb_err <= '0'; 
      	     end process;

---------------------------------------------------------------------------------------
------------------------------------ SLAVE 10 ------------------------------------------
-- Slave 10: EC End of frame register-pointer
	slave10: entity work.ipbus_reg_v
		generic map ( N_REG => 1 )
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_EC_EOF_REG),
			ipbus_out => ipbr(N_SLV_EC_EOF_REG),
			q(0)  => EC_EOF_Reg_s
		);
	
	 EC_rx_done_shaper: process(Rx_clk_i,Rx_clk_en_i)
	          begin
	             if rising_edge(Rx_clk_i) then 
	                  if Rx_clk_en_i = '1' then        
		                Rx_received_Trig_s <= rx_received_so(0) ;
		                Rx_received_shaped_s  <= (Rx_received_Trig_s or rx_received_so(0)) and SCA_frame_TxRx_s;
		              end if;
                 end if;
	    end process;	
	    
	 EC_Tx_start_shaper: process(Tx_clk_i,Tx_clk_en)
	          begin
	             if rising_edge(Tx_clk_i) then 
	                  if Tx_clk_en = '1' then        
		                Tx_received_strb0_s <= Rx_received_shaped_s ;
		                Next_EC_TxFrame_s   <= Rx_received_shaped_s and not Tx_received_strb0_s;
		              end if;
		              if SCA_start_cmd_s = '1' then SCA_frame_TxRx_s <= '1'; end if;
                      if Next_EC_TxFrame_s = '1'     then SCA_frame_TxRx_s <= '0'; end if;
                 end if;
	    end process;
	
	EC_next_frame: process(Rx_clk_i,Rx_clk_en_i)
	          begin
	             if rising_edge(Rx_clk_i) then 
	                  if Rx_clk_en_i = '1' then   
	                    if rx_received_so(0) = '1' and SCA_frame_TxRx_s = '1' then 
	                       EC_Frame_cnt <= EC_Frame_cnt + 1; 
	                    end if;
		              end if;
		              if EC_Frame_addr_s >= EC_EOF_Reg_s(9 downto 0) then EC_Frame_cnt <= 0; end if;
 		              if EC_EOF_Reg_s = std_logic_vector(to_unsigned(0, 32)) 
 		                         then Next_EC_TxFrame_En_s <= '0';
 		                         else Next_EC_TxFrame_En_s <= '1';     
 		              end if; 
 		              Tx_Frame_s <= Next_EC_TxFrame_s and Next_EC_TxFrame_En_s ;
                 end if;
                 EC_Frame_addr_s <= std_logic_vector(to_unsigned(EC_Frame_cnt, 10)); 
	    end process;    
	    SCA_start_cmd_s <= lpGBT_SCA_start_cmd_s or Tx_Frame_s;
	    -- EC_Frame_addr_s -- frame number 
	    -- Tx_Frame_s      -- start next frame after recived answer from SCA
	    

---------------------------------------------------------------------------------------
------------------------------------- SCA ---------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
------------------------------------ SLAVE 6 -----------------------------------------
     -- Slave 6: EC Rx SCA Header RAM ( Tr.ID & CH & Lenght & CMD fields)
	slave6: entity work.ipBUS_EC_bram 
	   PORT MAP (
           clka      => ipb_clk,
           ipbus_in  => ipbw(N_SLV_SCA_H_RxRAM),
           ipbus_out => ipbr(N_SLV_SCA_H_RxRAM),
           
           clkb     => Rx_clk_i,
           addrb(9 downto 0)   => EC_Frame_addr_s,
           addrb(11 downto 10) => (others => '0'),
           inb      => rx_sca_H_si,
           web_i    => rx_we_si,
           qb       => open 
        );
        rx_we_si <= (rx_received_so(0) and Rx_clk_en_i);
        rx_sca_H_si(7 downto 0)   <= rx_transID_so(0);
        rx_sca_H_si(15 downto 8)  <= rx_channel_so(0);
        rx_sca_H_si(23 downto 16) <= rx_len_so(0);
        rx_sca_H_si(31 downto 24) <= rx_error_so(0);
        
------------------------------------ SLAVE 11 ------------------------------------------
     -- Slave 11: EC Tx SCA Data RAM ( Data fields)
	slave11: entity work.ipBUS_EC_bram 
	   PORT MAP (
           clka      => ipb_clk,
           ipbus_in  => ipbw(N_SLV_SCA_D_RxRAM),
           ipbus_out => ipbr(N_SLV_SCA_D_RxRAM),
           
           clkb     => Tx_clk_i,
           addrb(9 downto 0)   => EC_Frame_addr_s,
           addrb(11 downto 10) => (others => '0'),
           inb      => rx_sca_D_si,
           web_i    => rx_we_si,
           qb       => open 
        );
        rx_sca_D_si <= rx_data_so(0);
       
        
------------------------------------ SLAVE 12 -----------------------------------------
     -- Slave 12: EC Tx ELink Header RAM (address & control fields)
	slave12: entity work.ipBUS_EC_bram 
	   PORT MAP (
           clka      => ipb_clk,
           ipbus_in  => ipbw(N_SLV_Elnk_H_TxRAM),
           ipbus_out => ipbr(N_SLV_Elnk_H_TxRAM),
           
           clkb     => Tx_clk_i,
           addrb(9 downto 0)   => EC_Frame_addr_s,
           addrb(11 downto 10) => (others => '0'),
           inb      => (others => '0'),
           web_i    => '0',
           qb       => tx_elink_H_so
        );	
        tx_address_si <= tx_elink_H_so(7 downto 0);
---------------------------------------------------------------------------------------
------------------------------------ SLAVE 13 ------------------------------------------
     -- Slave 13: EC Tx SCA Header RAM ( Tr.ID & CH & Lenght & CMD fields)
	slave13: entity work.ipBUS_EC_bram 
	   PORT MAP (
           clka      => ipb_clk,
           ipbus_in  => ipbw(N_SLV_SCA_H_TxRAM),
           ipbus_out => ipbr(N_SLV_SCA_H_TxRAM),
           
           clkb     => Tx_clk_i,
           addrb(9 downto 0)   => EC_Frame_addr_s,
           addrb(11 downto 10) => (others => '0'),
           inb      => (others => '0'),
           web_i    => '0',
           qb       => tx_sca_H_so 
        );
        tx_transID_si <= tx_sca_H_so(7 downto 0);
        tx_channel_si <= tx_sca_H_so(15 downto 8);
        tx_command_si <= tx_sca_H_so(31 downto 24);	
        
---------------------------------------------------------------------------------------
------------------------------------ SLAVE 14 ------------------------------------------
     -- Slave 14: EC Tx SCA Data RAM ( Data fields)
	slave14: entity work.ipBUS_EC_bram 
	   PORT MAP (
           clka      => ipb_clk,
           ipbus_in  => ipbw(N_SLV_SCA_D_TxRAM),
           ipbus_out => ipbr(N_SLV_SCA_D_TxRAM),
           
           clkb     => Tx_clk_i,
           addrb(9 downto 0)   => EC_Frame_addr_s,
           addrb(11 downto 10) => (others => '0'),
           inb      => (others => '0'),
           web_i    => '0',
           qb       => tx_sca_D_so 
        );
        tx_data_si <= tx_sca_D_so;
        
---------------------------------------------------------------------------------------
------------------------------------ SCA ctrl ------------------------------------------
--   --! Instantiation of the SCA_top component
--   sca_inst: entity work.sca_top
--        generic map(
--            g_SCA_COUNT         => 1
            
--        )
--        port map(
--            tx_clk_i            => Tx_clk_i,
--            tx_clk_en           => Tx_clk_en,

--            rx_clk_i            => Rx_clk_i,
--            rx_clk_en           => Rx_clk_en_i,

--            rx_reset_i          => lpGBT_SCA_rst_cmd_strb1_s,--lpGBT_SCA_start_cmd_strb1_s,--rx_reset_i,
--            tx_reset_i          => lpGBT_SCA_rst_cmd_strb1_s,--lpGBT_SCA_start_cmd_strb1_s,--'0',--tx_reset_i,

--            enable_i            => "1",--sca_enable_i,
--            start_reset_cmd_i   => lpGBT_SCA_rst_cmd_s,--start_reset_cmd_si,
--            start_connect_cmd_i => lpGBT_SCA_connect_cmd_s,--start_connect_cmd_si,
--            start_command_i     => SCA_start_cmd_s,--lpGBT_SCA_start_cmd_s ,--start_command_si,
--            inject_crc_error    => '0',--inject_crc_error,

--            tx_address_i        => tx_address_si,
--            tx_transID_i        => tx_transID_si,
--            tx_channel_i        => tx_channel_si,
--            tx_len_i            => x"04", -- tx_len_i, -- Fixed (BUG)
--            tx_command_i        => tx_command_si,
--            tx_data_i           => tx_data_si,

--            rx_received_o       => rx_received_so,
--            rx_address_o        => rx_address_so,
--            rx_control_o        => rx_control_so,
--            rx_transID_o        => rx_transID_so,
--            rx_channel_o        => rx_channel_so,
--            rx_len_o            => rx_len_so,
--            rx_error_o          => rx_error_so,
--            rx_data_o           => rx_data_so,

--            tx_data_o           => ec_data_so,
--            rx_data_i           => ec_data_si

--        );

        
        
        
        
  lpGBTsc_inst: entity work.gbtsc_top
        generic map(
        -- IC configuration
            g_IC_FIFO_DEPTH     => 12,
            g_ToLpGBT           => 1,
        -- EC configuration
            g_SCA_COUNT         => 1
        )
        port map(
       -- Clock & reset
            tx_clk_i                => Tx_clk_i,
            tx_clk_en               => Tx_clk_en,
       
            rx_clk_i                => Rx_clk_i,
            rx_clk_en               => Rx_clk_en_i,
       
            rx_reset_i              => reset_sca,
            tx_reset_i              => reset_sca,
       
       -- IC configuration        
            tx_GBTx_address_i       => GBTx_address_to_gbtic_si,
            tx_register_addr_i      => Register_addr_to_gbtic_si,
            tx_nb_to_be_read_i      => nb_to_be_read_to_gbtic_si,
            
            parity_err_mask_i       => X"00",
       
       -- IC Status
            tx_ready_o              => ic_ready,
            rx_empty_o              => ic_empty,
       
            --rx_gbtx_addr_o          => ic_rd_gbtx_addr,
            --rx_mem_ptr_o            => ic_rd_mem_ptr,
            --rx_nb_of_words_o        => ic_rd_nb_of_words,
           
       -- IC FIFO control
            wr_clk_i                => Tx_clk_i, -- ??????????????????????????????????????
            rd_clk_i                => Rx_clk_i,
            
            tx_wr_i                 => wr_to_gbtic_si,
            tx_data_to_gbtx_i       => data_to_gbtic_si,
       
            rx_rd_i                 => rd_to_gbtic_si,
            rx_data_from_gbtx_o     => data_from_gbtic_so,
       
       -- IC control
            tx_start_write_i        => start_write_to_gbtic_si,
            tx_start_read_i         => start_read_to_gbtic_si,
           
       -- SCA control
            sca_enable_i            => "1",
            start_reset_cmd_i       => lpGBT_SCA_rst_cmd_s,
            start_connect_cmd_i     => lpGBT_SCA_connect_cmd_s,
            start_command_i         => SCA_start_cmd_s,
            inject_crc_error        => '0',
       
       -- SCA command
            tx_address_i            => tx_address_si,
            tx_transID_i            => tx_transID_si,
            tx_channel_i            => tx_channel_si,
            tx_command_i            => tx_command_si,
            tx_data_i               => tx_data_si,
 
            rx_received_o           => rx_received_so,
            rx_address_o            => rx_address_so,
            rx_control_o            => rx_control_so,
            rx_transID_o            => rx_transID_so,
            rx_channel_o            => rx_channel_so,
            rx_len_o                => rx_len_so,
            rx_error_o              => rx_error_so,
            rx_data_o               => rx_data_so,
       
       -- EC line
            ec_data_o               => ec_data_so,
            ec_data_i               => ec_data_si,
       
       -- IC lines
            ic_data_o               => ic_data_so,
            ic_data_i               => ic_data_si
        );
        Tx_EC_bits_o  <= ec_data_so(0);
        ec_data_si(0) <= Rx_EC_bits_i;
        reset_sca     <= lpGBT_SCA_rst_cmd_strb1_s;
        
        Tx_IC_bits_o <= ic_data_so;
		ic_data_si   <= Rx_IC_bits_i;
   
--------------------------------------- Slave 15,16,17 ------------------------------------------------	
 --Slave 15,16,17: SCA control commands
  slave15: process(ipb_clk, Tx_clk_i)
	          begin
	              if rising_edge(ipb_clk) then
	                 -- SCA reset command
	                  ipb_SCA_rst_cmd_strb_s  <= ipbw(N_SLV_SCA_reset_cmd).ipb_strobe;
	                  ipb_SCA_rst_cmd_ES_s <= ipb_SCA_rst_cmd_strb_s;-- or ipbw(N_SLV_SCA_reset_cmd).ipb_strobe; -- expand the signal for transmission to another clock domain
	                 -- SCA connect command  
	                  ipb_SCA_connect_cmd_strb_s  <= ipbw(N_SLV_SCA_connect_cmd).ipb_strobe;
	                  ipb_SCA_connect_cmd_ES_s <= ipb_SCA_connect_cmd_strb_s;-- or ipbw(N_SLV_SCA_connect_cmd).ipb_strobe; -- expand the signal for transmission to another clock domain
      	          	 -- SCA start command  
	                  ipb_SCA_start_cmd_strb_s  <= ipbw(N_SLV_SCA_start_cmd).ipb_strobe;
	                  ipb_SCA_start_cmd_ES_s <= ipb_SCA_start_cmd_strb_s;
      	          end if;
	              if rising_edge(Tx_clk_i) then  
	                         -- SCA reset command
	                          lpGBT_SCA_rst_cmd_strb0_s <= ipb_SCA_rst_cmd_ES_s;
	                          lpGBT_SCA_rst_cmd_strb1_s <= ipbw(N_SLV_SCA_reset_cmd).ipb_strobe;--lpGBT_SCA_rst_cmd_strb0_s;
		                      lpGBT_SCA_rst_cmd_s <= lpGBT_SCA_rst_cmd_strb0_s;-- and not lpGBT_SCA_rst_cmd_strb1_s;
		                     -- SCA connect command
	                          lpGBT_SCA_connect_cmd_strb0_s <= ipb_SCA_connect_cmd_ES_s;
	                          lpGBT_SCA_connect_cmd_strb1_s <= ipbw(N_SLV_SCA_connect_cmd).ipb_strobe;--lpGBT_SCA_connect_cmd_strb0_s;
		                      lpGBT_SCA_connect_cmd_s <= lpGBT_SCA_connect_cmd_strb0_s;-- and not lpGBT_SCA_connect_cmd_strb1_s;
		                     -- SCA start command
	                          lpGBT_SCA_start_cmd_strb0_s <= ipb_SCA_start_cmd_ES_s;
	                          lpGBT_SCA_start_cmd_strb1_s <= ipbw(N_SLV_SCA_start_cmd).ipb_strobe;--lpGBT_SCA_start_cmd_strb0_s;
		                      lpGBT_SCA_start_cmd_s <= lpGBT_SCA_start_cmd_strb0_s;--lpGBT_SCA_start_cmd_strb0_s and not lpGBT_SCA_start_cmd_strb1_s;   
		          end if;
                -- answer to ipBUS
                  -- SCA reset command
		          if rising_edge(ipb_clk) then  
		              ipbr(N_SLV_SCA_reset_cmd).ipb_ack <= ipb_SCA_rst_cmd_strb_s;              
		          end if;
                  ipbr(N_SLV_SCA_reset_cmd).ipb_rdata <= (others => '0');  
                  ipbr(N_SLV_SCA_reset_cmd).ipb_err <= '0'; 
                  -- SCA connect command
		          if rising_edge(ipb_clk) then  
		              ipbr(N_SLV_SCA_connect_cmd).ipb_ack <= ipb_SCA_connect_cmd_strb_s;              
		          end if;
                  ipbr(N_SLV_SCA_connect_cmd).ipb_rdata <= (others => '0');  
                  ipbr(N_SLV_SCA_connect_cmd).ipb_err <= '0'; 
                  -- SCA start command
		          if rising_edge(ipb_clk) then  
		              ipbr(N_SLV_SCA_start_cmd).ipb_ack <= ipb_SCA_start_cmd_strb_s;              
		          end if;
                  ipbr(N_SLV_SCA_start_cmd).ipb_rdata <= (others => '0');  
                  ipbr(N_SLV_SCA_start_cmd).ipb_err <= '0'; 
                  
      	     end process;                
 
 
 ---------------------------------------------------------------------------------------
------------------------------------ SLAVE 18 ------------------------------------------
-- Slave 18: IC Rx Data register
        Read_data_from_rxIC_FIFO: process(Rx_clk_i, ipb_clk)
	          begin
	             if rising_edge(Rx_clk_i) then 
	                  rd_to_gbtic_Trig_si <= ipbw(N_SLV_IC_RxDATA_REG).ipb_strobe;
                      rd_to_gbtic_si <= ipbw(N_SLV_IC_RxDATA_REG).ipb_strobe and not rd_to_gbtic_Trig_si;
                      if rd_to_gbtic_si = '1' then
                           IC_rx_FIFO_Data_to_ipBUS_s(7 downto 0) <= data_from_gbtic_so;
                           IC_rx_FIFO_Data_to_ipBUS_s(31 downto 8) <= (others => '0');
                      end if;
                 end if;
                 
                 if rising_edge(ipb_clk) then 
                      ipbr(N_SLV_IC_RxDATA_REG).ipb_ack <= ipbw(N_SLV_IC_RxDATA_REG).ipb_strobe;
                      ipbr(N_SLV_IC_RxDATA_REG).ipb_rdata <= IC_rx_FIFO_Data_to_ipBUS_s;
                      ipbr(N_SLV_IC_RxDATA_REG).ipb_err <= '0'; 
                 end if;
	    end process;

---------------------------------------------------------------------------------------
------------------------------------ SLAVE 19 ------------------------------------------
-- Slave 19: IC Status register
        Read_Status_from_IC: process(Rx_clk_i, ipb_clk)
	          begin
	              -- IC Read Status
	             if rising_edge(Rx_clk_i) then 
	                 ipb_IC_read_Status_strb_s  <= ipbw(N_SLV_IC_Status_REG).ipb_strobe;
	                 ipb_IC_read_Status_En_s <= ipbw(N_SLV_IC_Status_REG).ipb_strobe and not ipb_IC_read_Status_strb_s;
                     if ipb_IC_read_Status_En_s = '1' then
                         Status_from_IC_Reg_s(0) <= ic_ready;
                         Status_from_IC_Reg_s(1) <= ic_empty; 
                         Status_from_IC_Reg_s(31 downto 2) <= (others => '0');
                     end if;  
                 end if;
	          
	             if rising_edge(ipb_clk) then 
                      ipbr(N_SLV_IC_Status_REG).ipb_ack <= ipbw(N_SLV_IC_Status_REG).ipb_strobe;
                      ipbr(N_SLV_IC_Status_REG).ipb_rdata <= Status_from_IC_Reg_s;--(others => '0');
                      ipbr(N_SLV_IC_Status_REG).ipb_err <= '0'; 
                 end if;
	    end process;

-----------------------------------------------------------------------------------------------------
--------------------------------------- Slave 201,21 ------------------------------------------------	
 --Slave 20,21: IC control commands: Read, Write
  slave20_21: process(ipb_clk, Tx_clk_i)
	          begin
	              if rising_edge(ipb_clk) then
	                 -- IC Read command
	                  ipb_IC_read_cmd_strb_s  <= ipbw(N_SLV_IC_Tx_start_read).ipb_strobe;
	                 -- IC Write command
	                  ipb_IC_write_cmd_strb_s  <= ipbw(N_SLV_IC_Tx_start_write).ipb_strobe;
      	          end if;
	              if rising_edge(Tx_clk_i) then  
	                         -- IC Read command
	                          lpGBT_IC_read_cmd_strb0_s <= ipb_IC_read_cmd_strb_s;
		                      lpGBT_IC_read_cmd_s <= ipb_IC_read_cmd_strb_s and not lpGBT_IC_read_cmd_strb0_s; --lpGBT_IC_read_cmd_strb0_s
		                      start_read_to_gbtic_si <= lpGBT_IC_read_cmd_s;
		                     -- IC Write command
	                          lpGBT_IC_write_cmd_strb0_s <= ipb_IC_write_cmd_strb_s;
		                      lpGBT_IC_write_cmd_s <= ipb_IC_write_cmd_strb_s and not lpGBT_IC_write_cmd_strb0_s;--lpGBT_IC_write_cmd_strb0_s;
		                      start_write_to_gbtic_si <= lpGBT_IC_write_cmd_s;
		                      
		          end if;
                -- answer to ipBUS
                  -- IC Read command
		          if rising_edge(ipb_clk) then  
		              ipbr(N_SLV_IC_Tx_start_read).ipb_ack <= ipb_IC_read_cmd_strb_s;              
		          end if;
                  ipbr(N_SLV_IC_Tx_start_read).ipb_rdata <= (others => '0');  
                  ipbr(N_SLV_IC_Tx_start_read).ipb_err <= '0'; 
                   -- IC Write command
		          if rising_edge(ipb_clk) then  
		              ipbr(N_SLV_IC_Tx_start_write).ipb_ack <= ipb_IC_write_cmd_strb_s;              
		          end if;
                  ipbr(N_SLV_IC_Tx_start_write).ipb_rdata <= (others => '0');  
                  ipbr(N_SLV_IC_Tx_start_write).ipb_err <= '0';         
      	     end process;
 
---------------------------------------------------------------------------------------	 
---------------------------------------------------------------------------------------
------------------------------------------- test outputs --------------------------------------
TxLed: entity work.led_stretcher
		generic map(
			WIDTH => 1
		)
		port map(
			clk => ipb_clk,
			d(0) => lpGBT_SCA_start_cmd_s,
			q(0) => led_s(0)
		);
		
RxLed: entity work.led_stretcher
		generic map(
			WIDTH => 1
		)
		port map(
			clk => ipb_clk,
			d(0) => rx_received_so(0),
			q(0) => led_s(1)
		);
Pulse_shaper: process(Rx_clk_i,Rx_clk_en_i)
	          begin
	             if rising_edge(Rx_clk_i) then 
	                  if Rx_clk_en_i = '1' then        
		                Rx_received_strb0_s <= rx_received_so(0);
		                Rx_received_strb1_s <= Rx_received_strb0_s;
		                Rx_Pulse_shaper_s  <= Rx_received_strb0_s or Rx_received_strb1_s or rx_received_so(0);
		              end if;
                 end if;
	    end process;

        EC_Tx_start_o    <= led_s(0);--lpGBT_SCA_start_cmd_s;
		EC_Rx_received_o <= led_s(1);--rx_received_so(0);
       

end rtl;
