-------------------------------------------------------
--! @file
--! @author Julian Mendez <julian.mendez@cern.ch> (CERN - EP-ESE-BE)
--! @version 2.0
--! @brief LpGBT-FPGA Top
-------------------------------------------------------

--! Include the IEEE VHDL standard library
library ieee;
use ieee.std_logic_1164.all;

--! Include the LpGBT-FPGA specific package
use work.lpgbtfpga_package.all;

--! Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

entity lpgbtFpga_10g24 is 
   GENERIC (
        FEC                             : integer range 0 to 2                   --! FEC selection can be: FEC5 or FEC12
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
end lpgbtFpga_10g24;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture behavioral of lpgbtFpga_10g24 is
            
    COMPONENT xlx_ku_mgt_10g24                         
       port (
            --=============--
            -- Clocks      --
            --=============--
            MGT_REFCLK_i                 : in  std_logic;
            MGT_FREEDRPCLK_i             : in  std_logic;
            
            MGT_RXUSRCLK_o               : out std_logic;
            MGT_TXUSRCLK_o               : out std_logic;
            
            --=============--
            -- Resets      --
            --=============--
            MGT_TXRESET_i                : in  std_logic;
            MGT_RXRESET_i                : in  std_logic;
            
            --=============--
            -- Control     --
            --=============--
            MGT_RXSlide_i                : in  std_logic;
            
            MGT_ENTXCALIBIN_i            : in  std_logic;
            MGT_TXCALIB_i                : in  std_logic_vector(6 downto 0);
            
            --=============--
            -- Status      --
            --=============--
            MGT_TXREADY_o                : out std_logic;
            MGT_RXREADY_o                : out std_logic;
            
            MGT_TX_ALIGNED_o             : out std_logic;
            MGT_TX_PIPHASE_o             : out std_logic_vector(6 downto 0);         
            --==============--
            -- Data         --
            --==============--
            MGT_USRWORD_i                : in  std_logic_vector(31 downto 0);
            MGT_USRWORD_o                : out std_logic_vector(31 downto 0);
            
            --===============--
            -- Serial intf.  --
            --===============--
            RXn_i                        : in  std_logic;
            RXp_i                        : in  std_logic;
            
            TXn_o                        : out std_logic;
            TXp_o                        : out std_logic   
       );
    END COMPONENT;
    
    COMPONENT LpGBTFPGA_Downlink
       GENERIC(
             -- Expert parameters
             c_multicyleDelay              : integer range 0 to 7 := 3;                          --! Multicycle delay
             c_clockRatio                  : integer := 8;                                       --! Clock ratio is clock_out / 40 (shall be an integer - E.g.: 320/40 = 8)
             c_outputWidth                 : integer                                             --! Transceiver's word size
        );
        port (
             -- Clocks
             clk_i                         : in  std_logic;                                      --! Downlink datapath clock (either 320 or 40MHz)
             clkEn_i                       : in  std_logic;                                      --! Clock enable (1 over 8 when encoding runs @ 320Mhz, '1' @ 40MHz)
             rst_n_i                       : in  std_logic;                                      --! Downlink reset signal (Tx ready from the transceiver)
     
             -- Down link
             userData_i                    : in  std_logic_vector(31 downto 0);                  --! Downlink data (user)
             ECData_i                      : in  std_logic_vector(1 downto 0);                   --! Downlink EC field
             ICData_i                      : in  std_logic_vector(1 downto 0);                   --! Downlink IC field
     
             -- Output
             mgt_word_o                    : out std_logic_vector((c_outputWidth-1) downto 0);   --! Downlink encoded frame (IC + EC + User Data + FEC)
     
             -- Configuration
             interleaverBypass_i           : in  std_logic;                                      --! Bypass downlink interleaver (test purpose only)
             encoderBypass_i               : in  std_logic;                                      --! Bypass downlink FEC (test purpose only)
             scramblerBypass_i             : in  std_logic;                                      --! Bypass downlink scrambler (test purpose only)
     
             -- Status
             rdy_o                         : out std_logic                                       --! Downlink ready status
        );
    END COMPONENT;
    
    COMPONENT LpGBTFPGA_Uplink
       GENERIC(
             -- General configuration
             DATARATE                        : integer range 0 to 2 := DATARATE_5G12;              --! Datarate selection can be: DATARATE_10G24 or DATARATE_5G12
             FEC                             : integer range 0 to 2 := FEC5;                       --! FEC selection can be: FEC5 or FEC12
     
             -- Expert parameters
             c_multicyleDelay                : integer range 0 to 7 := 3;                          --! Multicycle delay
             c_clockRatio                    : integer;                                            --! Clock ratio is mgt_userclk / 40 (shall be an integer)
             c_mgtWordWidth                  : integer;                                            --! Bus size of the input word
             c_allowedFalseHeader            : integer;                                            --! Number of false header allowed to avoid unlock on frame error
             c_allowedFalseHeaderOverN       : integer;                                            --! Number of header checked to know wether the lock is lost or not
             c_requiredTrueHeader            : integer;                                            --! Number of true header required to go in locked state
             c_bitslip_mindly                : integer := 1;                                       --! Number of clock cycle required when asserting the bitslip signal
             c_bitslip_waitdly               : integer := 40                                       --! Number of clock cycle required before being back in a stable state
        );
        PORT (
             -- Clock and reset
             clk_freeRunningClk_i            : in  std_logic;
             uplinkClk_i                     : in  std_logic;                                      --! Input clock (Rx user clock from transceiver)
             uplinkClkOutEn_o                : out std_logic;                                      --! Clock enable to be used in the user's logic
             uplinkRst_n_i                   : in  std_logic;                                      --! Uplink reset signal (Rx ready from the transceiver)
     
             -- Input
             mgt_word_o                      : in  std_logic_vector((c_mgtWordWidth-1) downto 0);  --! Input frame coming from the MGT
     
             -- Data
             userData_o                      : out std_logic_vector(229 downto 0);                 --! User output (decoded data). The payload size varies depending on the
                                                                                                         --! datarate/FEC configuration:
                                                                                                         --!     * *FEC5 / 5.12 Gbps*: 112bit
                                                                                                         --!     * *FEC12 / 5.12 Gbps*: 98bit
                                                                                                         --!     * *FEC5 / 10.24 Gbps*: 230bit
                                                                                                         --!     * *FEC12 / 10.24 Gbps*: 202bit
             EcData_o                        : out std_logic_vector(1 downto 0);                   --! EC field value received from the LpGBT
             IcData_o                        : out std_logic_vector(1 downto 0);                   --! IC field value received from the LpGBT
     
             -- Control
             bypassInterleaver_i             : in  std_logic;                                      --! Bypass uplink interleaver (test purpose only)
             bypassFECEncoder_i              : in  std_logic;                                      --! Bypass uplink FEC (test purpose only)
             bypassScrambler_i               : in  std_logic;                                      --! Bypass uplink scrambler (test purpose only)
     
             -- Transceiver control
             mgt_bitslipCtrl_o               : out std_logic;                                      --! Control the Bitslib/RxSlide port of the Mgt
     
             -- Status
             dataCorrected_o                 : out std_logic_vector(229 downto 0);                 --! Flag allowing to know which bit(s) were toggled by the FEC
             IcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the IC field were toggled by the FEC
             EcCorrected_o                   : out std_logic_vector(1 downto 0);                   --! Flag allowing to know which bit(s) of the EC field  were toggled by the FEC
             rdy_o                           : out std_logic                                       --! Ready signal from the uplink decoder
        );
    END COMPONENT;
    
    signal downlink_mgtword_s               : std_logic_vector(31 downto 0);
    signal uplink_mgtword_s                 : std_logic_vector(31 downto 0);
    signal mgt_rxslide_s                    : std_logic;
    signal mgt_txrdy_s                      : std_logic;
    signal mgt_rxrdy_s                      : std_logic;
    signal clk_mgtRxClk_s                   : std_logic;
        
begin                 --========####   Architecture Body   ####========--
    
    downlink_inst: lpgbtfpga_Downlink    
       GENERIC MAP(    
            -- Expert parameters
            c_multicyleDelay              => 3,
            c_clockRatio                  => 8,
            c_outputWidth                 => 32
       )
       PORT MAP(
            -- Clocks
            clk_i                 => donwlinkClk_i,
            clkEn_i               => downlinkClkEn_i,
            rst_n_i               => mgt_txrdy_s,
    
            -- Down link
            userData_i            => downlinkUserData_i,
            ECData_i              => downlinkEcData_i,
            ICData_i              => downlinkIcData_i,
    
            -- Output
            mgt_word_o            => downlink_mgtword_s,
    
            -- Configuration
            interleaverBypass_i   => downLinkBypassInterleaver_i,
            encoderBypass_i       => downLinkBypassFECEncoder_i,
            scramblerBypass_i     => downLinkBypassScrambler_i,
    
            -- Status
            rdy_o                 => downlinkReady_o
       );

    mgt_inst: xlx_ku_mgt_10g24                         
       port map(
            --=============--
            -- Clocks      --
            --=============--
            MGT_REFCLK_i                 => clk_mgtrefclk_i,
            MGT_FREEDRPCLK_i             => clk_mgtfreedrpclk_i,
            
            MGT_RXUSRCLK_o               => clk_mgtRxClk_s,
            MGT_TXUSRCLK_o               => clk_mgtTxClk_o,
            
            --=============--
            -- Resets      --
            --=============--
            MGT_TXRESET_i                => downlinkRst_i,
            MGT_RXRESET_i                => uplinkRst_i,
            
            --=============--
            -- Control     --
            --=============--
            MGT_RXSlide_i                => mgt_rxslide_s,
            
            MGT_ENTXCALIBIN_i            => '0',
            MGT_TXCALIB_i                => (others => '0'),
            
            --=============--
            -- Status      --
            --=============--
            MGT_TXREADY_o                => mgt_txrdy_s,
            MGT_RXREADY_o                => mgt_rxrdy_s,
            
            MGT_TX_ALIGNED_o             => open,
            MGT_TX_PIPHASE_o             => open,
            --==============--
            -- Data         --
            --==============--
            MGT_USRWORD_i                => downlink_mgtword_s,
            MGT_USRWORD_o                => uplink_mgtword_s,
            
            --===============--
            -- Serial intf.  --
            --===============--
            RXn_i                        => mgt_rxn_i,
            RXp_i                        => mgt_rxp_i,
            
            TXn_o                        => mgt_txn_o,
            TXp_o                        => mgt_txp_o
       );

    uplinkClk_o <= clk_mgtRxClk_s;
    clk_mgtRxClk_o <= clk_mgtRxClk_s;
    
    uplink_inst: lpgbtfpga_Uplink
       GENERIC MAP(
            -- General configuration
            DATARATE                        => DATARATE_10G24,
            FEC                             => FEC,
    
            -- Expert parameters
            c_multicyleDelay                => 3,
            c_clockRatio                    => 8,
            c_mgtWordWidth                  => 32,
            c_allowedFalseHeader            => 5,
            c_allowedFalseHeaderOverN       => 64,
            c_requiredTrueHeader            => 30,
            c_bitslip_mindly                => 1,
            c_bitslip_waitdly               => 40
       )
       PORT MAP(
            -- Clock and reset
            clk_freeRunningClk_i            => clk_mgtfreedrpclk_i,                       
            uplinkClk_i                     => clk_mgtRxClk_s,
            uplinkClkOutEn_o                => uplinkClkEn_o,
            uplinkRst_n_i                   => mgt_rxrdy_s,
    
            -- Input
            mgt_word_o                      => uplink_mgtword_s,
    
            -- Data
            userData_o                      => uplinkUserData_o,
            EcData_o                        => uplinkEcData_o,
            IcData_o                        => uplinkIcData_o,
    
            -- Control
            bypassInterleaver_i             => uplinkBypassInterleaver_i,
            bypassFECEncoder_i              => uplinkBypassFECEncoder_i,
            bypassScrambler_i               => uplinkBypassScrambler_i,
    
            -- Transceiver control
            mgt_bitslipCtrl_o               => mgt_rxslide_s,
    
            -- Status
            dataCorrected_o                 => open,
            IcCorrected_o                   => open,
            EcCorrected_o                   => open,
            rdy_o                           => uplinkReady_o
       );
end behavioral;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--