-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief KCU105 Example design top - Includes VIOs and pattern gen/check.
--! modified for the BTL CC tests! OS 
--! FF connections are added 
-------------------------------------------------------

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;

package bus_multiplexer_pkg is
    type conf2b_array is array(natural range <>) of std_logic_vector(1 downto 0);
end package;
    
--! Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bus_multiplexer_pkg.all;
use work.lpgbtfpga_package.all;
use work.ipbus.ALL;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--
entity lpgbtfpga_kcu105_10g24_top is
    port (  
      --===============--     
      -- General reset --     
      --===============--     

      CPU_RESET                                      : in  std_logic;     
      
      --===============--
      -- Clocks scheme --
      --===============--       
      -- MGT(GTX) reference clock:
      ----------------------------
      
      -- Comment: * The MGT reference clock MUST be provided by an external clock generator.
      --
      --          * The MGT reference clock frequency must be 120MHz for the latency-optimized GBT Bank.      
      SMA_MGT_REFCLK_P                               : in  std_logic;
      SMA_MGT_REFCLK_N                               : in  std_logic; 
                  
      -- Fabric clock:
      ----------------     

      USER_CLOCK_P                                   : in  std_logic;
      USER_CLOCK_N                                   : in  std_logic;      
      
      --==========--
      -- MGT(GTX) --
      --==========--                   
      
      -- Serial lanes:
      ----------------
      
      SFP0_TX_P                                      : out std_logic;
      SFP0_TX_N                                      : out std_logic;
      SFP0_RX_P                                      : in  std_logic;
      SFP0_RX_N                                      : in  std_logic; 
      
      -- FF control 
      ---------------
      ff_tx_prsnt_n                                  : in std_logic;
      ff_rx_prsnt_n                                  : in std_logic;
      ff_tx_int_n                                    : in std_logic;
      ff_rx_int_n                                    : in std_logic;
      ff_tx_reset_n                                  : out std_logic;
      ff_rx_reset_n                                  : out std_logic;
      ff_tx_select_n                                 : out std_logic;
      ff_rx_select_n                                 : out std_logic;
          
      -- SFP control:
      ---------------
      
      SFP0_TX_DISABLE                                : out std_logic;    
    
      --====================--
      -- Signals forwarding --
      --====================--
      
      -- SMA output:
      --------------
      USER_SMA_GPIO_P                                : out std_logic;    
      USER_SMA_GPIO_N                                : out std_logic;  
      
      
      eth_clk_p: in std_logic; -- 125MHz MGT clock
	  eth_clk_n: in std_logic;
	  eth_rx_p: in std_logic; -- Ethernet MGT input
	  eth_rx_n: in std_logic;
	  eth_tx_p: out std_logic; -- Ethernet MGT output
	  eth_tx_n: out std_logic;
	  leds: out std_logic_vector(3 downto 0); -- status LEDs
	  dip_sw: in std_logic_vector(3 downto 0) -- switches
      
     
   ); 
end lpgbtfpga_kcu105_10g24_top;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture behavioral of lpgbtfpga_kcu105_10g24_top is

    -- Components declaration
    COMPONENT lpgbtFpga_10g24 
       GENERIC (
            FEC                             : integer range 0 to 2 := FEC5           --! FEC selection can be: FEC5 or FEC12
       );
       PORT (
            -- Clocks
            donwlinkClk_i                    : in  std_logic;                       --! Downlink datapath clock (either 320 or 40MHz)
            downlinkClkEn_i                  : in  std_logic;                       --! Clock enable (1 over 8 when encoding runs @ 320Mhz, '1' @ 40MHz)
            
            uplinkClk_o                      : out std_logic;                       --! Clock provided by the Rx serdes: in phase with data
            uplinkClkEn_o                    : out std_logic;                       --! Clock enable pulsed when new data is ready
            
            downlinkRst_i                    : in  std_logic;                       --! Reset the downlink path
            uplinkRst_i                      : in  std_logic;                       --! Reset the uplink path
            
            -- Down link
            downlinkUserData_i               : in  std_logic_vector(31 downto 0);   --! Downlink data (user)
            downlinkEcData_i                 : in  std_logic_vector(1 downto 0);    --! Downlink EC field
            downlinkIcData_i                 : in  std_logic_vector(1 downto 0);    --! Downlink IC field
                        
            downLinkBypassInterleaver_i      : in  std_logic;                       --! Bypass downlink interleaver (test purpose only)
            downLinkBypassFECEncoder_i       : in  std_logic;                       --! Bypass downlink FEC (test purpose only)
            downLinkBypassScrambler_i        : in  std_logic;                       --! Bypass downlink scrambler (test purpose only)
            
            downlinkReady_o                  : out std_logic;                       --! Downlink ready status
            
            -- Up link
            uplinkUserData_o                 : out std_logic_vector(229 downto 0);  --! Uplink data (user)
            uplinkEcData_o                   : out std_logic_vector(1 downto 0);    --! Uplink EC field
            uplinkIcData_o                   : out std_logic_vector(1 downto 0);    --! Uplink IC field
                        
            uplinkBypassInterleaver_i        : in  std_logic;                       --! Bypass uplink interleaver (test purpose only)
            uplinkBypassFECEncoder_i         : in  std_logic;                       --! Bypass uplink FEC (test purpose only)
            uplinkBypassScrambler_i          : in  std_logic;                       --! Bypass uplink scrambler (test purpose only)

            uplinkReady_o                    : out std_logic;                       --! Uplink ready status
            
            -- MGT
            clk_mgtrefclk_i                  : in  std_logic;                       --! Transceiver serial clock
            clk_mgtfreedrpclk_i              : in  std_logic;
            
            clk_mgtTxClk_o                   : out std_logic;
            clk_mgtRxClk_o                   : out std_logic;
            
            mgt_rxn_i                        : in  std_logic;
            mgt_rxp_i                        : in  std_logic;
            mgt_txn_o                        : out std_logic;
            mgt_txp_o                        : out std_logic;
            
            mgt_txcaliben_i                  : in  std_logic;
            mgt_txcalib_i                    : in  std_logic_vector(6 downto 0);                      
            mgt_txaligned_o                  : out std_logic;
            mgt_txphase_o                    : out std_logic_vector(6 downto 0)
       ); 
    END COMPONENT;
        
    COMPONENT vio_0
      PORT (
        clk : IN STD_LOGIC;
        probe_in0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_in1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_in2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe_in3 : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
        probe_in4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_in5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_in6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_in7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);                
        probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out2 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out3 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out4 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out5 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out6 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out7 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out8 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out9 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out10 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        probe_out11 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out12 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out13 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out14 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out15 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out16 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out17 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out18 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out19 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out20 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out21 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out22 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out23 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out24 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out25 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out26 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out27 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out28 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out29 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out30 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out31 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out32 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out33 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out34 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out35 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out36 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out37 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out38 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out39 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out40 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out41 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out42 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out43 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out44 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        probe_out45 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out46 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
      );
    END COMPONENT;
          
    COMPONENT lpgbtfpga_patterngen is
      port(
          clk320DnLink_i            : in  std_logic;
          clkEnDnLink_i             : in  std_logic;
    
          generator_rst_i           : in  std_logic;
    
          config_group0_i           : in  std_logic_vector(1 downto 0);
          config_group1_i           : in  std_logic_vector(1 downto 0);
          config_group2_i           : in  std_logic_vector(1 downto 0);
          config_group3_i           : in  std_logic_vector(1 downto 0);
    
          fixed_pattern_i           : in  std_logic_vector(31 downto 0);
    
          downlink_o                : out std_logic_vector(31 downto 0);
    
          eport_gen_rdy_o           : out std_logic_vector(15 downto 0)
      );
    END COMPONENT;
        
    COMPONENT lpgbtfpga_patternchecker
        port (
            reset_checker_i  : in  std_logic;
            ser320_clk_i     : in  std_logic;
            ser320_clkEn_i   : in  std_logic;
    
            data_rate_i      : in  std_logic;
    
            elink_config_i   : in  conf2b_array(27 downto 0);
    
            error_detected_o : out std_logic_vector(27 downto 0);
    
            userDataUpLink_i : in  std_logic_vector(229 downto 0)
        );
    END COMPONENT;
    
    -- Signals:
    
        -- Config
        signal uplinkSelectDataRate_s             : std_logic := '1';
        signal uplinkSelectFEC_s                  : std_logic := '0';
                
        signal downLinkBypassInterleaver_s        : std_logic := '0';
        signal downLinkBypassFECEncoder_s         : std_logic := '0';
        signal downLinkBypassScrambler_s          : std_logic := '0';
        
        signal upLinkScramblerBypass_s            : std_logic := '0';
        signal upLinkFecBypass_s                  : std_logic := '0';
        signal upLinkInterleaverBypass_s          : std_logic := '0';
        
        signal reset_lpgbtfpga_from_jtag          : std_logic := '0';
        
        -- Clocks:
        signal mgtRefClk_from_smaMgtRefClkbuf_s   : std_logic;
        signal mgtRefClk_from_smaMgtRefClkbuf_img_s   : std_logic;
        signal mgtRefClk_from_smaMgtRefClkbuf_img2_s   : std_logic;
        signal mgt_freedrpclk_s                   : std_logic;
        
        signal lpgbtfpga_mgttxclk_s               : std_logic;
        signal lpgbtfpga_mgtrxclk_s               : std_logic;
        
        signal lpgbtfgpa_txclken_s                : std_logic;
        
        -- LpGBT-FPGA                             
        signal lpgbtfpga_downlinkrst_s            : std_logic := '1';
        signal lpgbtfpga_downlinkrdy_s            : std_logic;
        signal lpgbtfpga_uplinkrst_s              : std_logic;
        signal lpgbtfpga_uplinkrdy_s              : std_logic;
        
        signal lpgbtfpga_downlinkUserData_s       : std_logic_vector(31 downto 0);
        signal lpgbtfpga_downlinkEcData_s         : std_logic_vector(1 downto 0);
        signal lpgbtfpga_downlinkIcData_s         : std_logic_vector(1 downto 0);
        
        signal lpgbtfpga_uplinkUserData_s         : std_logic_vector(229 downto 0);
        signal lpgbtfpga_uplinkEcData_s           : std_logic_vector(1 downto 0);
        signal lpgbtfpga_uplinkIcData_s           : std_logic_vector(1 downto 0);
        
        signal lpgbtfpga_uplinkclk_s              : std_logic;
        signal lpgbtfpga_uplinkclken_s            : std_logic;
        
        signal uplinkErrorMaskInject_s            : std_logic_vector(255 downto 0) := (others => '0');
        signal downlinkErrorMaskInject_s          : std_logic_vector(63 downto 0)  := (others => '0');
        signal downlink_forceHeaderErr_s          : std_logic := '0';
        signal uplink_forceHeaderErr_s            : std_logic := '0';
        
        signal lpgbtfpga_mgt_txaligned_s          : std_logic;
        signal lpgbtfpga_mgt_txpiphase_s          : std_logic_vector(6 downto 0);
        signal lpgbtfpga_mgt_txpicalib_s          : std_logic_vector(6 downto 0);
        signal lpgbtfpga_mgt_txcaliben_s          : std_logic;
        
        -- LpGBT-Emul
        signal lpgbtemul_uplinkrst_s              : std_logic := '1';
        signal lpgbtemul_uplinkrdy_s              : std_logic;
        signal lpgbtemul_downlinkrst_s            : std_logic;
        signal lpgbtemul_downlinkrdy_s            : std_logic;
        
        signal lpgbtemul_downlinkUserData_s       : std_logic_vector(31 downto 0);
        signal lpgbtemul_downlinkUserData_g0_s    : std_logic_vector(15 downto 0);
        signal lpgbtemul_downlinkUserData_g1_s    : std_logic_vector(15 downto 0);
        signal lpgbtemul_downlinkEcData_s         : std_logic_vector(1 downto 0);
        signal lpgbtemul_downlinkIcData_s         : std_logic_vector(1 downto 0);

        signal lpgbtemul_downlinkclk_s            : std_logic;
        signal lpgbtemul_downlinkclken_s          : std_logic;
        signal lpgbtemul_uplinkclk_s              : std_logic;
        signal lpgbtemul_uplinkClkEn_s            : std_logic;
        
        signal lpgbtemul_uplinkUserData_s         : std_logic_vector(229 downto 0);
        signal lpgbtemul_uplinkUserData_g0_s      : std_logic_vector(31 downto 0);
        signal lpgbtemul_uplinkUserData_g1_s      : std_logic_vector(31 downto 0);
        signal lpgbtemul_uplinkUserData_g2_s      : std_logic_vector(31 downto 0);
        signal lpgbtemul_uplinkUserData_g3_s      : std_logic_vector(31 downto 0);
        signal lpgbtemul_uplinkUserData_g4_s      : std_logic_vector(31 downto 0);
        signal lpgbtemul_uplinkUserData_g5_s      : std_logic_vector(31 downto 0);
        signal lpgbtemul_uplinkUserData_g6_s      : std_logic_vector(31 downto 0);
        signal lpgbtemul_uplinkIcData_s           : std_logic_vector(1 downto 0);
        signal lpgbtemul_uplinkEcData_s           : std_logic_vector(1 downto 0);
        
        signal lpgbtemul_mgtRdy_s                 : std_logic;
            
        -- Serial                                 
        signal downlinkSerial_s                   : std_logic;
        signal uplinkSerial_s                     : std_logic;
        
        -- Gen / Checker
        signal uplink_error_s                     : std_logic;
        signal downlink_error_s                   : std_logic;
        signal downlink_txFlag_s                  : std_logic;
        signal downlink_rxFlag_s                  : std_logic;
        signal upLinkDataSel_s                    : std_logic;
        

        
        signal generator_rst_s                    : std_logic;
        signal downconfig_g0_s                    : std_logic_vector(1 downto 0);
        signal downconfig_g1_s                    : std_logic_vector(1 downto 0);
        signal downconfig_g2_s                    : std_logic_vector(1 downto 0);
        signal downconfig_g3_s                    : std_logic_vector(1 downto 0);        
        signal downlink_gen_rdy_s                 : std_logic_vector(15 downto 0);
    
        signal upelink_config_s                   : conf2b_array(27 downto 0);
        signal uperror_detected_s                 : std_logic_vector(27 downto 0);
        signal reset_upchecker_s                  : std_logic;
        
        
         -- ipBUS signals
    signal clk_ipb, rst_ipb, clk_aux, rst_aux, nuke, soft_rst, userled: std_logic;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal ipb_out: ipb_wbus;
	signal ipb_in: ipb_rbus;
	signal TxRx_Data_SrcRcvr_s                    : std_logic := '0';
	

	-- lighters
    signal Light_UpLink_Cnt    : unsigned (31 downto 0);
    signal Light_DownLink_Cnt  : unsigned (31 downto 0);
	signal Light_UpLink_Cnt_s  : std_logic_vector(31 downto 0);
	signal Light_DownLink_Cnt_s: std_logic_vector(31 downto 0);
	
	signal EC_Tx_start_frame_s : std_logic := '0';
	signal EC_Rx_recive_frame_s: std_logic := '0';
	
	---------------- test signals --------------
	
	signal SFP0_TX_P_s         : std_logic;
    signal SFP0_TX_N_s         : std_logic;
    signal SFP0_RX_P_s         : std_logic;
    signal SFP0_RX_N_s         : std_logic; 

	
begin                 --========####   Architecture Body   ####========-- 

    -- Reset controll    
    SFP0_TX_DISABLE           <= '0';
    
    -- Clocks
    
    -- MGT(GTX) reference clock:
    ----------------------------   
    -- Comment: * The MGT reference clock MUST be provided by an external clock generator.
    --          * The MGT reference clock frequency must be 320MHz for the latency-optimized GBT Bank. 
    smaMgtRefClkIbufdsGtxe2: ibufds_gte3
      generic map(
        REFCLK_EN_TX_PATH           => '0',
        REFCLK_HROW_CK_SEL          => (others => '0'),
        REFCLK_ICNTL_RX             => (others => '0')
      )
      port map (
        O                                           => mgtRefClk_from_smaMgtRefClkbuf_s,
        ODIV2                                       => mgtRefClk_from_smaMgtRefClkbuf_img_s,
        CEB                                         => '0',
        I                                           => SMA_MGT_REFCLK_P,
        IB                                          => SMA_MGT_REFCLK_N
      );

    mgtclk_img_bufg: BUFG_GT 
        port map(
            I      => mgtRefClk_from_smaMgtRefClkbuf_img_s,
            O      => mgtRefClk_from_smaMgtRefClkbuf_img2_s,
            CE     => '1',
            DIV    => (others => '0'),
            CLR    => '0',
            CLRMASK => '0',
            CEMASK  => '0'
        );
        
    userClockIbufgds: ibufgds
      generic map (
         IBUF_LOW_PWR                                => FALSE,      
         IOSTANDARD                                  => "LVDS_25")
      port map (     
         O                                           => mgt_freedrpclk_s,   
         I                                           => USER_CLOCK_P,  
         IB                                          => USER_CLOCK_N 
      );
            
    txClkEn_proc: process(lpgbtfpga_downlinkrst_s, lpgbtfpga_mgttxclk_s)
        variable cnter : integer range 0 to 8;
    begin
        if lpgbtfpga_downlinkrst_s = '1' then
            cnter := 0;
            lpgbtfgpa_txclken_s   <= '0';
        
        elsif rising_edge(lpgbtfpga_mgttxclk_s) then
            cnter := cnter + 1;
            
            if cnter = 8 then
                cnter := 0;                              
            end if;
                        
            lpgbtfgpa_txclken_s   <= '0';
            if cnter = 0 then
                lpgbtfgpa_txclken_s   <= '1';  
            end if;
        
        end if;
        
    end process;
          
    -- Data stimulis
   -- lpgbtfpga_downlinkEcData_s     <= (others => '1');
   --lpgbtfpga_downlinkIcData_s     <= (others => '1');
       
    -- LpGBT FPGA
    lpgbtFpga_top_inst: lpgbtFpga_10g24 
       generic map (
            FEC                             => FEC5
       )
       port map (
            -- Clocks
            donwlinkClk_i                    => lpgbtfpga_mgttxclk_s,
            downlinkClkEn_i                  => lpgbtfgpa_txclken_s,

            uplinkClk_o                      => lpgbtfpga_uplinkclk_s,
            uplinkClkEn_o                    => lpgbtfpga_uplinkclken_s,

            downlinkRst_i                    => lpgbtfpga_downlinkrst_s,
            uplinkRst_i                      => lpgbtfpga_uplinkrst_s,

            -- Down link
            downlinkUserData_i               => lpgbtfpga_downlinkUserData_s,
            downlinkEcData_i                 => lpgbtfpga_downlinkEcData_s,
            downlinkIcData_i                 => lpgbtfpga_downlinkIcData_s,

            downLinkBypassInterleaver_i      => downLinkBypassInterleaver_s,
            downLinkBypassFECEncoder_i       => downLinkBypassFECEncoder_s,
            downLinkBypassScrambler_i        => downLinkBypassScrambler_s,

            downlinkReady_o                  => lpgbtfpga_downlinkrdy_s,

            -- Up link
            uplinkUserData_o                 => lpgbtfpga_uplinkUserData_s,
            uplinkEcData_o                   => lpgbtfpga_uplinkEcData_s,
            uplinkIcData_o                   => lpgbtfpga_uplinkIcData_s,

            uplinkBypassInterleaver_i        => upLinkInterleaverBypass_s,
            uplinkBypassFECEncoder_i         => upLinkFecBypass_s,
            uplinkBypassScrambler_i          => upLinkScramblerBypass_s,
            
            uplinkReady_o                    => lpgbtfpga_uplinkrdy_s,

            -- MGT
            clk_mgtrefclk_i                  => mgtRefClk_from_smaMgtRefClkbuf_s,
            clk_mgtfreedrpclk_i              => mgt_freedrpclk_s,
            
            clk_mgtTxClk_o                   => lpgbtfpga_mgttxclk_s,
            clk_mgtRxClk_o                   => lpgbtfpga_mgtrxclk_s,
            
            mgt_rxn_i                        => SFP0_RX_N,
            mgt_rxp_i                        => SFP0_RX_P,
            mgt_txn_o                        => SFP0_TX_N,
            mgt_txp_o                        => SFP0_TX_P,
            
            -- HPTD IP
            mgt_txcaliben_i                  => lpgbtfpga_mgt_txcaliben_s,
            mgt_txcalib_i                    => lpgbtfpga_mgt_txpicalib_s,                    
            mgt_txaligned_o                  => lpgbtfpga_mgt_txaligned_s,
            mgt_txphase_o                    => lpgbtfpga_mgt_txpiphase_s
       );
       
       SFP0_TX_N                        <= SFP0_TX_N_s;
       SFP0_TX_P                        <= SFP0_TX_P_s;
       
    -- Data pattern generator / checker (PRBS7)
    lpgbtfpga_patterngen_inst: lpgbtfpga_patterngen
        port map(
            --clk40Mhz_Tx_i      : in  std_logic;
            clk320DnLink_i            => lpgbtfpga_mgttxclk_s,
            clkEnDnLink_i             => lpgbtfgpa_txclken_s,

            generator_rst_i           => generator_rst_s,

            -- Group configurations:
            --    "11": 320Mbps
            --    "10": 160Mbps
            --    "01": 80Mbps
            --    "00": Fixed pattern
            config_group0_i           => downconfig_g0_s,
            config_group1_i           => downconfig_g1_s,
            config_group2_i           => downconfig_g2_s,
            config_group3_i           => downconfig_g3_s,

            downlink_o                => lpgbtfpga_downlinkUserData_s,

            fixed_pattern_i           => x"12345678",

            eport_gen_rdy_o           => downlink_gen_rdy_s
        );

    lpgbtfpga_patternchecker_inst: lpgbtfpga_patternchecker
        port map(
            reset_checker_i  => reset_upchecker_s,
            ser320_clk_i     => lpgbtfpga_uplinkclk_s,
            ser320_clkEn_i   => lpgbtfpga_uplinkclken_s,
    
            data_rate_i      => '1', -- This is for BTL gen uplinkSelectDataRate_s,
    
            elink_config_i   => upelink_config_s,
    
            error_detected_o => uperror_detected_s,
    
            userDataUpLink_i => lpgbtfpga_uplinkUserData_s
        );

    vio_debug_inst : vio_0
      PORT MAP (
        clk => mgt_freedrpclk_s,
        probe_in0(0)  => lpgbtfpga_downlinkrdy_s,
        probe_in1(0)  => lpgbtfpga_uplinkrdy_s,
        probe_in2     => downlink_gen_rdy_s,
        probe_in3     => uperror_detected_s,
        probe_in4(0)  => ff_tx_prsnt_n,
        probe_in5(0)  => ff_rx_prsnt_n,
        probe_in6(0)  => ff_tx_int_n,
        probe_in7(0)  => ff_rx_int_n,        
        probe_out0(0) => lpgbtfpga_downlinkrst_s,
        probe_out1(0) => lpgbtfpga_uplinkrst_s,
        probe_out2(0) => downLinkBypassInterleaver_s,
        probe_out3(0) => downLinkBypassFECEncoder_s,
        probe_out4(0) => downLinkBypassScrambler_s,
        probe_out5(0) => ff_tx_select_n,
        probe_out6(0) => ff_rx_select_n,
        probe_out7(0) => upLinkInterleaverBypass_s,
        probe_out8(0) => upLinkFecBypass_s,
        probe_out9(0) => upLinkScramblerBypass_s,
        probe_out10   => lpgbtfpga_mgt_txpicalib_s,
        probe_out11(0)=> lpgbtfpga_mgt_txcaliben_s,
        probe_out12(0)=> generator_rst_s,
        probe_out13   => downconfig_g0_s,
        probe_out14   => downconfig_g1_s,
        probe_out15   => downconfig_g2_s,
        probe_out16   => downconfig_g3_s,
        probe_out17(0)=> reset_upchecker_s,
        probe_out18   => upelink_config_s(0),
        probe_out19   => upelink_config_s(1),
        probe_out20   => upelink_config_s(2),
        probe_out21   => upelink_config_s(3),
        probe_out22   => upelink_config_s(4),
        probe_out23   => upelink_config_s(5),
        probe_out24   => upelink_config_s(6),
        probe_out25   => upelink_config_s(7),
        probe_out26   => upelink_config_s(8),
        probe_out27   => upelink_config_s(9),
        probe_out28   => upelink_config_s(10),
        probe_out29   => upelink_config_s(11),
        probe_out30   => upelink_config_s(12),
        probe_out31   => upelink_config_s(13),
        probe_out32   => upelink_config_s(14),
        probe_out33   => upelink_config_s(15),
        probe_out34   => upelink_config_s(16),
        probe_out35   => upelink_config_s(17),
        probe_out36   => upelink_config_s(18),
        probe_out37   => upelink_config_s(20),
        probe_out38   => upelink_config_s(21),
        probe_out39   => upelink_config_s(22),
        probe_out40   => upelink_config_s(23),
        probe_out41   => upelink_config_s(24),
        probe_out42   => upelink_config_s(25),
        probe_out43   => upelink_config_s(26),
        probe_out44   => upelink_config_s(27),
        probe_out45(0) => ff_tx_reset_n,
        probe_out46(0) => ff_rx_reset_n      
      );
      
      USER_SMA_GPIO_P <= lpgbtfgpa_txclken_s;
      USER_SMA_GPIO_N <= lpgbtfpga_mgttxclk_s;
      
      
    -- ipBUS path      
      	infra: entity work.kcu105_basex_infra
		generic map(
			CLK_AUX_FREQ => 40.0
		)
		port map(
			--sysclk_p => USER_CLOCK_P,--sysclk_p,
			--sysclk_n => USER_CLOCK_N,--sysclk_n,
			sysclk_i  => mgt_freedrpclk_s,
			eth_clk_p => eth_clk_p,
			eth_clk_n => eth_clk_n,
			eth_tx_p => eth_tx_p,
			eth_tx_n => eth_tx_n,
			eth_rx_p => eth_rx_p,
			eth_rx_n => eth_rx_n,
			sfp_los => '0',
			clk_ipb_o => clk_ipb,
			rst_ipb_o => rst_ipb,
			clk_aux_o => clk_aux,
			rst_aux_o => rst_aux,
			nuke => nuke,
			soft_rst => soft_rst,
			leds => open,--leds(1 downto 0),
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			ipb_in => ipb_in,
			ipb_out => ipb_out
		);
		
------------------------- LED section ---------------------------------------
    leds(0) <= EC_Tx_start_frame_s;
    leds(1) <= EC_Rx_recive_frame_s;
    
    Illuminator_UpLink:process(lpgbtfpga_uplinkclk_s) 
	  begin
              if rising_edge(lpgbtfpga_uplinkclk_s)  then
                	    Light_UpLink_Cnt <= Light_UpLink_Cnt + 1;
		      end if;
	end process;
	Light_UpLink_Cnt_s <= std_logic_vector(Light_UpLink_Cnt);
    leds(2) <= Light_UpLink_Cnt_s(27);
    
    Illuminator_DownLink:process(lpgbtfpga_mgttxclk_s)
	  begin
              if rising_edge(lpgbtfpga_mgttxclk_s)  then
                	    Light_DownLink_Cnt <= Light_DownLink_Cnt + 1;
		      end if;
	end process;
	Light_DownLink_Cnt_s <= std_logic_vector(Light_DownLink_Cnt);
    leds(3) <= Light_DownLink_Cnt_s(27);
------------------------------------------------------------------------------
	
		
	mac_addr <= X"020ddba11513"; -- 02.0d.db.a1.15.13
	ip_addr <= X"c0a8c811";      -- 192.168.200.17

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	payload: entity work.payload
		port map(
			ipb_clk => clk_ipb,
			ipb_rst => rst_ipb,
			ipb_in => ipb_out,
			ipb_out => ipb_in,
			clk => clk_aux,
			rst => rst_aux,
			nuke => nuke,
			soft_rst => soft_rst,
			userled => userled,
			
			Tx_clk_i      => lpgbtfpga_mgttxclk_s,
			Tx_clk_en_i   => lpgbtfgpa_txclken_s,
            Tx_addr_i     => (others => '0'),
            Tx_data_i     => (others => '0'),
            Tx_we_i       => '0',
            Tx_data_o     => open,
 
            Rx_clk_i      => lpgbtfpga_uplinkclk_s,--lpgbtfpga_uplinkclk_s, --lpgbtfpga_mgttxclk_s,--
            Rx_clk_en_i   => lpgbtfpga_uplinkclken_s,--lpgbtfpga_uplinkclken_s, -- lpgbtfgpa_txclken_s,--
            Rx_data_i     => lpgbtfpga_uplinkUserData_s,
            Rx_data_o     => open,
            
            Tx_EC_bits_o  => lpgbtfpga_downlinkEcData_s,
            Rx_EC_bits_i  => lpgbtfpga_uplinkEcData_s,--lpgbtfpga_uplinkEcData_s,--lpgbtfpga_downlinkEcData_s
            
            Tx_IC_bits_o  => lpgbtfpga_downlinkIcData_s,
		    Rx_IC_bits_i  => lpgbtfpga_uplinkIcData_s,--lpgbtfpga_uplinkIcData_s,
            
            TxRx_Data_SrcRcvr_o => TxRx_Data_SrcRcvr_s,
            
            -- test output
            EC_Tx_start_frame_o  => EC_Tx_start_frame_s,
		    EC_Rx_recive_frame_o => EC_Rx_recive_frame_s
		);
		
end behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--