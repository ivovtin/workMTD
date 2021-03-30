

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.ALL;

use work.ipbus.all;
--use work.ipbus_reg_types.all;
--use work.ipbus_decode_ipbus_example.all;
library ipbus_package;
--use ipbus_package.all;
USE work.prbs_pattern_generator.ALL;


library UNISIM;
use UNISIM.VComponents.all;




entity SCA_TB is
--  Port ( );
end SCA_TB;

architecture Behavioral of SCA_TB is

 -- Clock period definitions
   constant ipBUS_CLK_period : time := 32.26 ns;  
   constant lpGBT_CLK_period : time := 3.125 ns; ---3.125 ns; -- 25ns
   constant lpGBT_CLK_EN_period : time := 25 ns;

   component payload is
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
		Rx_we_i               : in std_logic := '0';
		Rx_addr_i             : in STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
		Rx_data_i             : in STD_LOGIC_VECTOR(229 DOWNTO 0) := (others => '0');
		Rx_EC_bits_i          : in STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
		Rx_data_o             : out STD_LOGIC_VECTOR(31 DOWNTO 0):= (others => '0');
		
		TxRx_Data_SrcRcvr_o   : out std_logic := '0'
    );
    end component;

------------------------------------------ signals --------------------------------------    
    signal ipb_clk_s  : std_logic :='0';
    signal ipb_rst_s  : std_logic :='0';
    signal ipb_in_s   : ipb_wbus;
    signal ipb_out_s  : ipb_rbus;
    
    signal clk_aux_s  : std_logic :='0';
	signal rst_aux_s  : std_logic :='0';

    signal Tx_clk_s  : std_logic :='0';
    signal Tx_clk_en_s  : std_logic :='0';
	signal Tx_addr_s : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	signal Tx_data_s : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
	signal Tx_data_so : STD_LOGIC_VECTOR(31 DOWNTO 0);-- := (others => '0');
		
	signal Rx_clk_s  : std_logic :='0';
	signal Rx_clk_en_s  : std_logic :='0';
	signal Rx_we_s   : std_logic :='0';
	signal Rx_addr_s : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	--signal Rx_data_s : STD_LOGIC_VECTOR(229 DOWNTO 0) := (others => '0');
	signal Rx_data_so : STD_LOGIC_VECTOR(31 DOWNTO 0);-- := (others => '0');
	signal Rx_Reset_s : STD_LOGIC_VECTOR(6 DOWNTO 0) := (others => '0');
	
	type PRBS_Array is array (0 to 6) of std_logic_vector(31 downto 0);
	signal PRBS_Gen_Data_s : PRBS_Array := (others => (others => '0'));
    signal Uplink_UserData_s : STD_LOGIC_VECTOR(229 DOWNTO 0) := (others => '0');
    signal Uplink_UserData_Test_s : STD_LOGIC_VECTOR(229 DOWNTO 0) := (others => '0');
    
		
	signal DRAM_addr_so : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');
	signal Push_Tx_Cycle_s  : std_logic :='1';
	signal Reg_so : STD_LOGIC_VECTOR(31 DOWNTO 0);
		
	signal TxRx_Data_SrcRcvr_s  : std_logic :='0';
	signal Inj_Error_in_Line_s  : STD_LOGIC_VECTOR(6 DOWNTO 0) := (others => '0');
	
	signal lpgbtfpga_downlinkEcData_s         : std_logic_vector(1 downto 0);
	signal lpgbtfpga_uplinkEcData_s           : std_logic_vector(1 downto 0);
    
begin


    PayLD : payload
    port map ( 
        ipb_clk  => ipb_clk_s,
        ipb_rst  => ipb_rst_s,
        ipb_in   => ipb_in_s,
        ipb_out  => ipb_out_s,
        nuke     => open,
        soft_rst => open,
        userled  => open,  
        clk      => clk_aux_s,
	    rst      => rst_aux_s,
        
        Tx_clk_i      => Tx_clk_s,
        Tx_clk_en_i   => Tx_clk_en_s,
        Tx_addr_i     => Tx_addr_s,
        Tx_data_i     => Tx_data_s,
        Tx_we_i       => '0',
        Tx_data_o     => Tx_data_so,
        Tx_EC_bits_o  => lpgbtfpga_downlinkEcData_s,
        
       
        Rx_clk_i      => Rx_clk_s,
--            RxDRAM_addr_i     => DRAM_addr_i,
        Rx_data_i     => Uplink_UserData_s,--Uplink_UserData_Test_s,--Uplink_UserData_s,
        Rx_EC_bits_i  => lpgbtfpga_downlinkEcData_s,
        Rx_we_i       => Rx_clk_en_s,--Rx_we_s,
        Rx_data_o     => Rx_data_so,
        
        TxRx_Data_SrcRcvr_o => TxRx_Data_SrcRcvr_s
        
     );

-- data coming from the Rx line are the ADC values
-- simulate ADC data using PRBS generators
-- Generate seven PRBS generators
    prbs_Gen: 
        for I in 0 to 6 generate
            prbs: entity work.prbs  
                generic map(seed => set_initialValue(HBHE,SEED_31,inv_prbs_seed(HBHE,SEED_31)),inverter=>inv_prbs_seed(HBHE,SEED_31),hbhehf=>HBHE)
	               port map (
                                    prbs_o => PRBS_Gen_Data_s(i)(31 downto 1),
                                    clk    => Rx_clk_s,
                                    clk_en => Rx_clk_en_s,
                                    reset  => Rx_Reset_s(I)
                            );
            PRBS_Gen_Data_s(i)(0) <= '1';
            --Uplink_UserData_s((i+1)*32-1 downto 32*i) <= PRBS_Gen_Data_s(i);
    -- PRBS_Gen_Data_s consist of 31 MSB bits from PRBS generator + 1 constant bit = 32 bits
    end generate prbs_Gen;
    Uplink_UserData_s(229 downto 224) <= (others => '1');
    
    Uplink_UserData_Test_s(229 downto 4) <= (others => '0');
    Uplink_UserData_Test_s(3 downto 0) <= (others => '1');    
  
   -- Inject error to data (bit 1 is inverted from the current state) 
     Uplink_UserData_with_Error_Gen:
     for I in 0 to 6 generate
            Uplink_UserData_s((i+1)*32-1 downto 32*i+1) <= PRBS_Gen_Data_s(i)(31 downto 2) & (Inj_Error_in_Line_s(i) xor PRBS_Gen_Data_s(i)(1));
    end generate Uplink_UserData_with_Error_Gen;

---------------------------------------------------------------------------------------------------
----------------------------------------- simulation section -------------------------------------- 
---------------------------------------------------------------------------------------------------    
       -- clock generation with 31MHz
    process 
        begin
            ipb_clk_s <= '0';
            wait for ipBUS_CLK_period/2; --16.13ns;
            ipb_clk_s <= '1';
            wait for ipBUS_CLK_period/2; --16.13ns;
        end process;
    
   -- clock generation with 320MHz
    process  -- Tx
       begin
            Tx_clk_s <= '1';
            wait for lpGBT_CLK_period/2;
            Tx_clk_s <= '0';
            wait for lpGBT_CLK_period/2;
       end process;
       
       process -- Rx
       begin 
            Rx_clk_s <= '1';
            wait for lpGBT_CLK_period/2;
            Rx_clk_s <= '0';
            wait for lpGBT_CLK_period/2;
       end process;
 
 --  clock enable 
     process -- Tx
       begin
            Tx_clk_en_s <= '0';
            wait for lpGBT_CLK_EN_period-lpGBT_CLK_period;
            Tx_clk_en_s <= '1';
            wait for lpGBT_CLK_period;
     end process;  
     
  --  clock enable 
     process -- Rx
       begin
            Rx_clk_en_s <= '0';
            wait for lpGBT_CLK_EN_period-lpGBT_CLK_period;
            Rx_clk_en_s <= '1';
            wait for lpGBT_CLK_period;
     end process; 
       
     -- reset generation for first two cycles      
   process 
       begin
            ipb_rst_s <= '1';
            wait for ipBUS_CLK_period*2;
            ipb_rst_s <= '0';
            wait;
   end process;
   
   
    process 
       begin
----------------------------------- Initial section -----------------------------------
-- initial setting of input signal states
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_wdata <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_write <= '0';
            
            -- initialize PRBS generators
            for I in 0 to 6 loop 
                wait until rising_edge(Rx_clk_en_s);
                Rx_Reset_s(I) <= '1';
                wait until rising_edge(Rx_clk_s);
                Rx_Reset_s(I) <= '0';
            end loop;
            
----------------------------------- General section -----------------------------------
----------------- first frame init -----------------------
   -- write word 1 EC_Frame_DRAM           
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(24576,32));
            ipb_in_s.ipb_wdata <= X"0123010D";--std_logic_vector(to_unsigned(587268478,32));
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
    -- write word 2 EC_Frame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(24577,32));
            ipb_in_s.ipb_wdata <= X"02010404";--std_logic_vector(to_unsigned(17236993,32)); 01070401
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
    -- write word 3 EC_Frame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(24578,32));
            ipb_in_s.ipb_wdata <= X"00000403";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
            
            
 ----------------- second frame init -----------------------           
    -- write word 1 EC_Frame_DRAM           
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(24580,32));
            ipb_in_s.ipb_wdata <= X"026931DD";--std_logic_vector(to_unsigned(587268478,32));
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
    -- write word 2 EC_Frame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(24581,32));
            ipb_in_s.ipb_wdata <= X"32510202";--std_logic_vector(to_unsigned(17236993,32)); 01070401
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
    -- write word 3 EC_Frame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(24582,32));
            ipb_in_s.ipb_wdata <= X"00000403";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
            
 --------------------------------------------------------------------------------------------     
             
 -- write EC End of frame register-pointer  write = 2 frames Tx            
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(6,32));
            ipb_in_s.ipb_wdata <= std_logic_vector(to_unsigned(2,32));
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
            
            
----------------- Read Rx frame -----------------------
----------------- first frame read -----------------------           
    -- read word 1 EC_RxFrame_DRAM  
            wait for 2000ns;         
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28672,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
     -- read word 2 EC_RxFrame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28673,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
     -- read word 3 EC_RxFrame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28674,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            
            
 ----------------- second frame read -----------------------           
    -- read word 1 EC_RxFrame_DRAM  
            wait for 300ns;         
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28676,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
     -- read word 2 EC_RxFrame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28677,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
     -- read word 3 EC_RxFrame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28678,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            
 --------------------------------------------------------------------------------------------     
             
 -- write EC End of frame register-pointer  write = 0 frames Tx  STOP Tx          
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(6,32));
            ipb_in_s.ipb_wdata <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';   
            
----------------- Read Rx frame -----------------------
----------------- first frame read -----------------------           
    -- read word 1 EC_RxFrame_DRAM  
            wait for 1000ns;         
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28672,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
     -- read word 2 EC_RxFrame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28673,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
     -- read word 3 EC_RxFrame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28674,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            
            
 ----------------- second frame read -----------------------           
    -- read word 1 EC_RxFrame_DRAM  
            wait for 100ns;         
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28676,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
     -- read word 2 EC_RxFrame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28677,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
     -- read word 3 EC_RxFrame_DRAM           
            wait for ipBUS_CLK_period*1;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(28678,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            
            
 --------------------------------------------------------------------------------------------     
             
 -- write EC End of frame register-pointer  write = 2 frames Tx 
            wait for 4000ns;           
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(6,32));
            ipb_in_s.ipb_wdata <= std_logic_vector(to_unsigned(2,32));
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
                     
                       
            wait;
   end process;
end Behavioral;


