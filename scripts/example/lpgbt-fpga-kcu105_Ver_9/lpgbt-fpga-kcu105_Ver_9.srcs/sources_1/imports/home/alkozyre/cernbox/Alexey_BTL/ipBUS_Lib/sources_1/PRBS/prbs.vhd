----------------------------------------------------------------------------------
-- Company:         CMS
-- Engineer:        Tugba Karakaya
-- 
-- Create Date:     17:32:29 07/16/2015 
-- Design Name: 
-- Module Name:     prbs generator - Behavioral 
-- Project Name:    GBT-FPGA
-- Target Devices:  FC7
-- Tool versions:   ISE 14.6
-- Description:     One-to-many implemantion of LSFR with using primitive polynomial (7-nomial of degree n=23 in GF(2)) 
--						  as seed.
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Xilinx devices library:
library unisim;
--use unisim.vcomponents.all;
use work.prbs_pattern_generator.all;

entity prbs is
	generic(
		seed     : std_logic_vector; 
		inverter : boolean;
		hbhehf   : boolean													
	);		
	port(
		prbs_o   : out std_logic_vector(seed'high downto 0):= seed;
		clk      : in  std_logic;
		clk_en      : in  std_logic;
		reset    : in  std_logic
	);
end prbs;

architecture Behavioral of prbs is
signal feedback : std_logic_vector(seed'high downto 0):=(others =>'0');
begin
	oneToMany_LSFR : process (clk,reset)
	begin
		if reset = '1' then
			feedback <= seed;
		elsif rising_edge(clk) then
			if(clk_en = '1')then
				if hbhehf = HF then
					feedback <= lsfr_HF(inverter,feedback);
				elsif hbhehf = HBHE then
					feedback <= lsfr_HBHE(feedback);
				end if;	
			end if;
		end if;
	end process;	 
	prbs_o <= feedback; 
end architecture;

--(19 downto 5 => '0', 4 downto 0 => '1');