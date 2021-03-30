-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
-- Date        : Wed Oct 23 13:06:09 2019
-- Host        : ceacmsfw running 64-bit CentOS Linux release 7.6.1810 (Core)
-- Command     : write_vhdl -force -mode synth_stub
--               /home/software/lpGBT/lpgbt-fpga-kcu105/Vivado/lpgbt-fpga-kcu105-10g24.srcs/sources_1/ip/vio_0/vio_0_stub.vhdl
-- Design      : vio_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku040-ffva1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vio_0 is
  Port ( 
    clk : in STD_LOGIC;
    probe_in0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in2 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    probe_in3 : in STD_LOGIC_VECTOR ( 27 downto 0 );
    probe_in4 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in5 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in6 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_in7 : in STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out2 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out3 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out4 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out5 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out6 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out7 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out8 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out9 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out10 : out STD_LOGIC_VECTOR ( 6 downto 0 );
    probe_out11 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out12 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out13 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out14 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out15 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out16 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out17 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out18 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out19 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out20 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out21 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out22 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out23 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out24 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out25 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out26 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out27 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out28 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out29 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out30 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out31 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out32 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out33 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out34 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out35 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out36 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out37 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out38 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out39 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out40 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out41 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out42 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out43 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out44 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    probe_out45 : out STD_LOGIC_VECTOR ( 0 to 0 );
    probe_out46 : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end vio_0;

architecture stub of vio_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe_in0[0:0],probe_in1[0:0],probe_in2[15:0],probe_in3[27:0],probe_in4[0:0],probe_in5[0:0],probe_in6[0:0],probe_in7[0:0],probe_out0[0:0],probe_out1[0:0],probe_out2[0:0],probe_out3[0:0],probe_out4[0:0],probe_out5[0:0],probe_out6[0:0],probe_out7[0:0],probe_out8[0:0],probe_out9[0:0],probe_out10[6:0],probe_out11[0:0],probe_out12[0:0],probe_out13[1:0],probe_out14[1:0],probe_out15[1:0],probe_out16[1:0],probe_out17[0:0],probe_out18[1:0],probe_out19[1:0],probe_out20[1:0],probe_out21[1:0],probe_out22[1:0],probe_out23[1:0],probe_out24[1:0],probe_out25[1:0],probe_out26[1:0],probe_out27[1:0],probe_out28[1:0],probe_out29[1:0],probe_out30[1:0],probe_out31[1:0],probe_out32[1:0],probe_out33[1:0],probe_out34[1:0],probe_out35[1:0],probe_out36[1:0],probe_out37[1:0],probe_out38[1:0],probe_out39[1:0],probe_out40[1:0],probe_out41[1:0],probe_out42[1:0],probe_out43[1:0],probe_out44[1:0],probe_out45[0:0],probe_out46[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "vio,Vivado 2018.3";
begin
end;
