-- Address decode logic for ipbus fabric
-- 
-- This file has been AUTOGENERATED from the address table - do not hand edit
-- 
-- We assume the synthesis tool is clever enough to recognise exclusive conditions
-- in the if statement.
-- 
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package ipbus_decode_ipbus_example is

 constant IPBUS_SEL_WIDTH: positive := 23; -- Should be enough for now?
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_ipbus_example(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically  generated VHDL the Thu May  3 15:36:57 2018 
  constant N_SLV_CSR                   : integer := 0;
  constant N_SLV_IC_TxDATA_REG         : integer := 1;
  constant N_SLV_IC_TxConf_REG         : integer := 2;
  constant N_SLV_IC_TxNWRead_REG       : integer := 3;
  constant N_SLV_TxBRAM                : integer := 4;
  constant N_SLV_RxBRAM                : integer := 5;
  constant N_SLV_SCA_H_RxRAM           : integer := 6;
  constant N_SLV_CTRL_MODE_REG         : integer := 7;
  constant N_SLV_lpGBT_ERR_CNT         : integer := 8; -- read FEC counter
  constant N_SLV_lpGBT_ERR_CNT_RD_RST  : integer := 9; -- read and reset FEC counter
  constant N_SLV_EC_EOF_REG            : integer := 10; -- EC end of frame register
  constant N_SLV_SCA_D_RxRAM           : integer := 11; -- 
  constant N_SLV_Elnk_H_TxRAM          : integer := 12; -- 
  constant N_SLV_SCA_H_TxRAM           : integer := 13; -- 
  constant N_SLV_SCA_D_TxRAM           : integer := 14; -- 
  constant N_SLV_SCA_reset_cmd         : integer := 15; -- 
  constant N_SLV_SCA_connect_cmd       : integer := 16; -- 
  constant N_SLV_SCA_start_cmd         : integer := 17; -- 
  
  constant N_SLV_IC_RxDATA_REG         : integer := 18;
  
  constant N_SLV_IC_Status_REG         : integer := 19;
  constant N_SLV_IC_Tx_start_write     : integer := 20;
  constant N_SLV_IC_Tx_start_read      : integer := 21;
  
  constant N_SLAVES                    : integer := 22;
-- END automatically generated VHDL

    
end ipbus_decode_ipbus_example;

package body ipbus_decode_ipbus_example is

  function ipbus_sel_ipbus_example(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically  generated VHDL the Thu May  3 15:36:57 2018 
    if    std_match(addr, "----------------0000---------001") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_CSR, IPBUS_SEL_WIDTH)); -- csr / base 0x00000000 / mask 0x00003002
      
    elsif std_match(addr, "----------------0001--------0001") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_IC_TxDATA_REG, IPBUS_SEL_WIDTH)); -- reg / base 0x00001001 / mask 0x00003002
    elsif std_match(addr, "----------------0001--------0000") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_IC_TxConf_REG, IPBUS_SEL_WIDTH)); -- reg / base 0x00001000 / mask 0x00003002
    elsif std_match(addr, "----------------0001--------0010") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_IC_TxNWRead_REG, IPBUS_SEL_WIDTH)); -- reg / base 0x00001002 / mask 0x00003002
    
    elsif std_match(addr, "----------------0100------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_TxBRAM, IPBUS_SEL_WIDTH)); -- Txbram / base 0x00004000 / mask 0x00007000
    elsif std_match(addr, "----------------0101------------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_RxBRAM, IPBUS_SEL_WIDTH)); -- Rxbram / base 0x00005000 / mask 0x00007000
    
    elsif std_match(addr, "----------------011001----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_SCA_H_RxRAM, IPBUS_SEL_WIDTH)); -- EC frame RxRAM to lpGBT TrID+CH+Len+CMD/ base 0x00006400 / mask 0x00007007
    
    elsif std_match(addr, "----------------0000---------011") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_CTRL_MODE_REG, IPBUS_SEL_WIDTH)); -- change work mode the lpGBT link / base 0x00000003 / mask 0x00007007 
    elsif std_match(addr, "----------------0000---------100") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_lpGBT_ERR_CNT, IPBUS_SEL_WIDTH)); -- PRBS checker number of error on lpGBT link (FER counter) / base 0x00000004 / mask 0x00007007 
    elsif std_match(addr, "----------------0000---------101") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_lpGBT_ERR_CNT_RD_RST, IPBUS_SEL_WIDTH)); -- read and reset FER counter / base 0x00000005 / mask 0x00007007
    elsif std_match(addr, "----------------0000---------110") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_EC_EOF_REG, IPBUS_SEL_WIDTH)); -- EC EOF register / base 0x00000006 / mask 0x00007007
    
    elsif std_match(addr, "----------------011010----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_SCA_D_RxRAM, IPBUS_SEL_WIDTH)); -- EC frame RxRAM from lpGBT Data32/ base 0x00006800  
    
    elsif std_match(addr, "----------------100000----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_Elnk_H_TxRAM, IPBUS_SEL_WIDTH)); -- EC frame TxRAM from lpGBT Address+Controll/ base 0x00008000  mask 0x00007007
    elsif std_match(addr, "----------------100001----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_SCA_H_TxRAM, IPBUS_SEL_WIDTH)); -- EC frame TxRAM from lpGBT TrID+CH+Len+CMD/ base 0x00008400  mask 0x00007007
    elsif std_match(addr, "----------------100010----------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_SCA_D_TxRAM, IPBUS_SEL_WIDTH)); -- EC frame TxRAM from lpGBT Data32 / base 0x00008800  mask 0x00007007
    
    elsif std_match(addr, "----------------100011-------001") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_SCA_reset_cmd, IPBUS_SEL_WIDTH)); -- H8C01 
    elsif std_match(addr, "----------------100011-------010") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_SCA_connect_cmd, IPBUS_SEL_WIDTH)); -- H8C02 -- 1000110000000010
    elsif std_match(addr, "----------------100011-------011") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_SCA_start_cmd, IPBUS_SEL_WIDTH)); -- H8C03 
      
    elsif std_match(addr, "----------------0001--------0101") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_IC_RxDATA_REG, IPBUS_SEL_WIDTH)); -- reg / base 0x00001005 / mask 0x00003002
    
    elsif std_match(addr, "----------------0001--------0100") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_IC_Status_REG, IPBUS_SEL_WIDTH)); -- reg / base 0x00001004 / mask 0x00003002
    elsif std_match(addr, "----------------0001--------1001") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_IC_Tx_start_write, IPBUS_SEL_WIDTH)); -- reg / base 0x00001009 / mask 0x00003002
    elsif std_match(addr, "----------------0001--------1000") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_IC_Tx_start_read, IPBUS_SEL_WIDTH)); -- reg / base 0x00001008 / mask 0x00003002
---0001000000001000
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_ipbus_example;

end ipbus_decode_ipbus_example;

