library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.ALL;

use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_ipbus_example.all;
library ipbus_package;
use ipbus_package.all;
USE work.prbs_pattern_generator.ALL;


library UNISIM;
use UNISIM.VComponents.all;




entity SCA_work_TB is
--  Port ( );
end SCA_work_TB;

architecture Behavioral of SCA_work_TB is

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
	
	signal lpgbtfpga_downlinkIcData_s         : std_logic_vector(1 downto 0);
	
    
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
        Rx_clk_en_i   => Rx_clk_en_s,--Rx_we_s,
        Rx_data_o     => Rx_data_so,
        
        Tx_IC_bits_o  => lpgbtfpga_downlinkIcData_s,
	    Rx_IC_bits_i  => lpgbtfpga_downlinkIcData_s,
        
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



----------------- first frame init -----------------------
   -- write elink Header (address & control fields)          
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008000";
            ipb_in_s.ipb_wdata <= X"22AA0002";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 

-- write SCA Header ( Tr.ID & CH & Lenght & CMD fields)          
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008400";
            ipb_in_s.ipb_wdata <= X"04030201";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 

-- write SCA Data ( data fields)          
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008800";
            ipb_in_s.ipb_wdata <= X"4D3C2B1A";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
            
            
 ----------------- second frame init -----------------------
   -- write elink Header (address & control fields)          
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008001";
            ipb_in_s.ipb_wdata <= X"22AA0001";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 

-- write SCA Header ( Tr.ID & CH & Lenght & CMD fields)          
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008401";
            ipb_in_s.ipb_wdata <= X"A0030B05";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 

-- write SCA Data ( data fields)          
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008801";
            ipb_in_s.ipb_wdata <= X"12345678";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';            
----------------- SCA control commands -----------------------   
-- write SCA reset commands          
            wait for ipBUS_CLK_period*4;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008C01";
            ipb_in_s.ipb_wdata <= X"00000001";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';          
            
---- write SCA connect commands          
--            wait for ipBUS_CLK_period*4;
--            wait until rising_edge(ipb_clk_s);
--            ipb_in_s.ipb_addr <= X"00008C02";
--            ipb_in_s.ipb_wdata <= X"00000001";
--            ipb_in_s.ipb_strobe <= '1';
--            ipb_in_s.ipb_write <= '1'; 
--            wait for (ipBUS_CLK_period);
--            ipb_in_s.ipb_strobe <= '0';
--            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
--            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
--            ipb_in_s.ipb_strobe <= '0';
--            ipb_in_s.ipb_write <= '0';  
                     
 -- write SCA start commands          
            wait for ipBUS_CLK_period*25;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008C03";
            ipb_in_s.ipb_wdata <= X"00000001";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';   
            
            
  ------------------------- write IC Tx frame ---------------------          
          -- write IC Tx Configuration: I2C slave address 0..7bits, Internal address 23..8bits = 24bits          
            wait for ipBUS_CLK_period*4;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00001000";
            ipb_in_s.ipb_wdata <= X"00ABCD05";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';  
            
         -- write IC Tx Configuration: Number of words/bytes to be read (only for read transactions)           
            wait for ipBUS_CLK_period*4;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001002";
            ipb_in_s.ipb_wdata <= X"00000001";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';  
            
         -- write IC Tx Data           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001001";
            ipb_in_s.ipb_wdata <= X"00000011";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
         -- write IC Tx Data           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001001";
            ipb_in_s.ipb_wdata <= X"00000022";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
         -- write IC Tx Data           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001001";
            ipb_in_s.ipb_wdata <= X"00000033";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
          -- write IC Tx Data           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001001";
            ipb_in_s.ipb_wdata <= X"00000044";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
          -- write IC Tx Data           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001001";
            ipb_in_s.ipb_wdata <= X"00000055";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
            
             -- start IC write commands          
            wait for ipBUS_CLK_period*2; --2
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00001009";
            ipb_in_s.ipb_wdata <= X"00000001";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';   

------------------------- read SCA first frame ---------------------
-- read SCA Header ( Tr.ID & CH & Error & Lenght fields)            
            wait for ipBUS_CLK_period*50;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00006400";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
 
 -- read SCA Data ( Data fields)            
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00006800";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';           
            
 
  -- write SCA start commands          
            wait for ipBUS_CLK_period*5;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00008C03";
            ipb_in_s.ipb_wdata <= X"00000001";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';   
 
 ------------------------- read SCA second frame ---------------------
-- read SCA Header ( Tr.ID & CH & Error & Lenght fields)            
            wait for ipBUS_CLK_period*50;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00006401";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
 
 -- read SCA Data ( Data fields)            
            wait for ipBUS_CLK_period*3;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00006801";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';  
            
 -- write EC End of frame register-pointer  write = 0 frames Tx            
            wait for ipBUS_CLK_period*100;
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
--            -- write SCA reset commands          
--            wait for ipBUS_CLK_period*4;
--            wait until rising_edge(ipb_clk_s);
--            ipb_in_s.ipb_addr <= X"00008C01";
--            ipb_in_s.ipb_wdata <= X"00000001";
--            ipb_in_s.ipb_strobe <= '1';
--            ipb_in_s.ipb_write <= '1'; 
--            wait for (ipBUS_CLK_period);
--            ipb_in_s.ipb_strobe <= '0';
--            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
--            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
--            ipb_in_s.ipb_strobe <= '0';
--            ipb_in_s.ipb_write <= '0';       

 -- read IC rxFIFO 
            -- 1 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            -- 2 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0'; 
            -- 3 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            -- 4 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            -- 5 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';     
            -- 6 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';     
            -- 7 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';     
            -- 8 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';   
            
                        -- 9 word           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001005";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';              
  
  
            -- write IC Tx Data           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001001";
            ipb_in_s.ipb_wdata <= X"00000066";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';           
  -- start IC write commands          
            wait for ipBUS_CLK_period*4; --2
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00001008";
            ipb_in_s.ipb_wdata <= X"00000001";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';                                        
            
            
            -- write IC Tx Data           
            wait for ipBUS_CLK_period*50;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001001";
            ipb_in_s.ipb_wdata <= X"00000077";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
          -- write IC Tx Data           
            wait for ipBUS_CLK_period*2;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001001";
            ipb_in_s.ipb_wdata <= X"00000088";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0'; 
            
             -- start IC write commands          
            wait for ipBUS_CLK_period*2; --2
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= X"00001009";
            ipb_in_s.ipb_wdata <= X"00000001";
            ipb_in_s.ipb_strobe <= '1';
            ipb_in_s.ipb_write <= '1'; 
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            ipb_in_s.ipb_write <= '0';
   
                                    -- Read IC status           
            wait for ipBUS_CLK_period*4;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001004";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
            
                                               -- Read IC status           
            wait for ipBUS_CLK_period*50;
            wait until rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr  <= X"00001004";--std_logic_vector(to_unsigned(32768,32));
            ipb_in_s.ipb_wdata <= X"00000000";--std_logic_vector(to_unsigned(2852389634,32));
            ipb_in_s.ipb_strobe <= '1';
            wait for (ipBUS_CLK_period);
            ipb_in_s.ipb_strobe <= '0';
            wait until ipb_out_s.ipb_ack = '1' and rising_edge(ipb_clk_s);
            ipb_in_s.ipb_addr <= std_logic_vector(to_unsigned(0,32));
            ipb_in_s.ipb_strobe <= '0';
             
              
            wait;
   end process;
end Behavioral;

