

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package prbs_pattern_generator is


	constant HF   : boolean:=true;
	constant HBHE : boolean:=false;
	constant SEED_31 : natural  :=  31 ;

-- Declare functions
	function set_prbs_tabs(hbhehf_switch : boolean; seed_length: integer) return std_logic_vector;
	function inv_prbs_seed(hbhehf_switch : boolean; seed_length: integer) return boolean;
	function set_initialValue (hbhehf_switch : boolean; seed_length: integer;inverter:boolean)return std_logic_vector;
	function lsfr_HF (inverter : boolean;initial_value: std_logic_vector)return std_logic_vector;
    function lsfr_HBHE(initial_value : std_logic_vector)return std_logic_vector;
	function prbs_pattern_bitwise_err_cnt (PRBS_rx_pattern: std_logic_vector; PRBS_pattern_next:std_logic_vector;seed_length: integer;cnt_lenght: integer)return std_logic_vector;

end prbs_pattern_generator;

package body prbs_pattern_generator is
	
  -- Taps for lfsrHF(). These are based on telecommunication records
  -- shown in the in-line comments.  This information comes from a Xilinx App Note,
  -- XAPP 884, Table 3. The index is the number of bits of the counter.
  function set_prbs_tabs(hbhehf_switch : boolean; seed_length: integer) 
		return std_logic_vector is
		variable tabs : std_logic_vector(seed_length-1 downto 0);
	begin
	if hbhehf_switch = HF then
		case seed_length is
			when 3  => tabs := "110";                                 -- for debug of this code
			when 4  => tabs := "1100";                                -- not standard comm. code but from Wikipedia as a possibility
			when 7  => tabs := "1100000";                             -- not standard but similar to 8b/10b encoded patterns
			when 9  => tabs := "100010000";                           -- ITU-T O.150
			when 11 => tabs := "10100000000";                         -- ITU-T O.150
			when 15 => tabs := "110000000000000";                     -- ITU-T O.150
			when 17 => tabs := "10010000000000000";                   -- OIF-CEI-P-02.0
			when 20 => tabs := "10000000000000000100";                -- ITU-T O.150
			when 23 => tabs := "10000100000000000000000";             -- ITU-T O.150
			when 29 => tabs := "10100000000000000000000000000";       -- ITU-T O.150
			when 31 => tabs := "1001000000000000000000000000000";     -- ITU-T O.150 / OIF-CEI-02.0
			when others => tabs :=(others=>'0');                      -- use all 0's to indicate unknown taps
		end case;
	-- Taps for lfsrHBHE().These are based on the Table 1: Primitive binary polynomials from
   -- URL: http://poincare.matf.bg.ac.rs/~ezivkovm/publications/primpol1.pdf
	elsif hbhehf_switch = HBHE then
		case seed_length is
			when 3  => tabs := "001";
			when 4  => tabs := "0001";
			when 7  => tabs := "0011111";
			when 9  => tabs := "011100110";
			when 11 => tabs := "00101010011";
			when 15 => tabs := "001000011110000";
			when 17 => tabs := "00001000010110010";
			when 20 => tabs := "00101010001000000001";
			when 23 => tabs := "00000010001110000010000";
			when 29 => tabs := "00000001000001100010000000100";
			when 31 => tabs := "0000000000000001010001010000001";
			when others => tabs :=(others=>'1');                    -- use all 1's to indicate unknown taps
		end case;
	end if;
	return tabs;
  end function;
  
  function inv_prbs_seed (hbhehf_switch : boolean; seed_length: integer) 
		return boolean is
		variable inverter : boolean;
	begin
	if hbhehf_switch =  HF then
		case seed_length is
			when 3  => inverter := true;
			when 4  => inverter := false;
			when 7  => inverter := true;
			when 9  => inverter := false;
			when 11 => inverter := false;
			when 15 => inverter := true;
			when 17 => inverter := false;
			when 20 => inverter := false;
			when 23 => inverter := true;
			when 29 => inverter := true;
			when 31 => inverter := true;
			when others => inverter :=(false);
		end case;
--	elsif hbhehf_switch = HBHE then
--		case seed_length is
--			when others => inverter := false;
--		end case;
	end if;
	return inverter;
	end function;
	
	function set_initialValue (hbhehf_switch : boolean; seed_length: integer;inverter:boolean) 
		return std_logic_vector is
		variable initial_value : std_logic_vector(seed_length-1 downto 0);
	begin
	if hbhehf_switch =  HF then
			if inverter then
				initial_value:=(others=>'0');
			else
				initial_value:=(others=>'1');
			end if;	
	elsif hbhehf_switch = HBHE then
			initial_value := set_prbs_tabs(HBHE,seed_length); --seed;
	end if;
	return initial_value;
	end function;
  -- the lsfr_HF() function was loosely based on a synthesizable module 
  -- found in the book HDL Chip Design by Douglas J. Smith
  -- in Chapter 7, pg 185.
  --
  -- Pass in the current value of the lfsr counter and the output is the next
  -- value. If initializing the counter, pass in all '0's. This is an invalid
  -- value for lfsr counters since it prevents the counter from advancing
  -- (output is all '0's).  However, use of all '0's indicates that the reset
  -- value is wanted.  If inv is false, the reset pattern is all '1's. If inv
  -- is true, the reset pattern is all '0's since the input is inverted first,
  -- creating all '1's.
  function lsfr_HF (inverter : boolean;initial_value: std_logic_vector) 
		return std_logic_vector is
		variable feedback : std_logic_vector(initial_value'high downto 0);
		variable taps     : std_logic_vector(initial_value'high downto 0);
   	variable fb       : std_logic:='0';
		variable fbinv    : std_logic:='1';
		
	begin
	taps     := set_prbs_tabs(HF,initial_value'length);
	feedback := initial_value;
	for i in initial_value'high downto 0
	loop
		if taps(i) = '1' then
			if inverter then 
				fbinv    := fbinv xnor feedback(i+initial_value'low); 
				fb       := fbinv;
			else
				fb := fb xor feedback(i+initial_value'low);
			end if;	
		end if;
   end loop;
	feedback:= feedback(initial_value'high-1 downto initial_value'low)&fb;
	return feedback;
  end function;
  -- the lsfr_HBHE() function is based on a Galois or one-to-many Implemenation.
  --URL: http://www.markharvey.info/fpga/lfsr/lfsr.html
  -- The most-significant bit is feedback directly into the least significant bit, and is also individually XORed with the chosen taps.
  --  If initializing the counter, pass the seed which is also same as the taps.
   function lsfr_HBHE (initial_value: std_logic_vector) 
		return std_logic_vector is
		variable feedback   : std_logic_vector(initial_value'high downto 0);
		variable taps     : std_logic_vector(initial_value'high downto 0);
	
	begin
	taps     := set_prbs_tabs(HBHE,initial_value'length);
	feedback := initial_value;
	for i in initial_value'high-1 downto 0 
	loop 
		if taps(i) = '1' then
			feedback(i) := feedback(i) xor feedback(initial_value'high);
		else
			feedback(i) := feedback(i);
		end if;
	end loop;
	feedback:= feedback(initial_value'high-1 downto initial_value'low) & feedback(initial_value'high);
	return feedback;
  end function;
  
    -------------------------------------------------------------------------------------------------------------------
  function prbs_pattern_bitwise_err_cnt (PRBS_rx_pattern: std_logic_vector; PRBS_pattern_next:std_logic_vector;seed_length: integer;cnt_lenght: integer) 
      return std_logic_vector is
		variable prbs_error_detection                 : std_logic_vector(seed_length-1 downto 0):= (others=>'0');
		variable prbs_bitwise_error_detection_cnt     : std_logic_vector(cnt_lenght-1 downto 0):=(others=>'0');
	
	begin
	 prbs_error_detection := PRBS_rx_pattern xor PRBS_pattern_next;
	 for i in prbs_error_detection'high downto prbs_error_detection'low 
	 loop
			if prbs_error_detection(i) = '1' then
				prbs_bitwise_error_detection_cnt := prbs_bitwise_error_detection_cnt + '1';
			else
				prbs_bitwise_error_detection_cnt := prbs_bitwise_error_detection_cnt;
			end if;
	 end loop;
	return prbs_bitwise_error_detection_cnt;
  end function;  
  
end prbs_pattern_generator;