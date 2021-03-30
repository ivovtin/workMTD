----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.07.2019 20:58:39
-- Design Name: 
-- Module Name: ipbus_bram - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------




-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use IEEE.NUMERIC_STD.ALL;
use work.ipbus.all;
use work.ipbus_trans_decl.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_ipbus_example.all;
use work.ipbus_fabric_sel;

-- BRAM without output register (1 clock latancy)
entity ipbus_bram is
	port(
	   clka : IN STD_LOGIC;
       ipbus_in: in ipb_wbus;
       ipbus_out: out ipb_rbus;
       
       clkb : IN STD_LOGIC;
       addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       inb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       qb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       web_i : IN STD_LOGIC
       
    );
	
end ipbus_bram;

architecture rtl of ipbus_bram is

COMPONENT blk_mem_gen_0 is
    PORT (
       clka : IN STD_LOGIC;
       addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
       
       clkb : IN STD_LOGIC;
       addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       web : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
       );
END COMPONENT;
       signal ack_s   : std_logic;
       signal wea_s   : std_logic;
       signal trig_s  : std_logic;
      


begin

BRAM : blk_mem_gen_0
    PORT MAP (
       clka => clka,
       wea(0) => wea_s,
       addra => ipbus_in.ipb_addr(11 downto 0),
       dina => ipbus_in.ipb_wdata(31 downto 0),
       douta => ipbus_out.ipb_rdata,
       
       clkb => clkb,
       addrb => addrb,
       dinb => inb,
       doutb => qb,
       web(0) => web_i
       );
 	
 	wea_s <= (ipbus_in.ipb_write and ipbus_in.ipb_strobe);
	
 	
 	process(clka)
	begin
        if rising_edge(clka) then
		      ack_s <= ipbus_in.ipb_strobe and not ack_s;
		end if;
		--ipbus_out.ipb_ack <= ack_s;
	end process;
 	
 	ipbus_out.ipb_ack <= ack_s;
	ipbus_out.ipb_err <= '0';
 	   
end rtl;