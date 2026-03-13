------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : maxv_top.vhd
-- Author               : Gilles Curchod
-- Date                 : 28.05.2013
-- Target Devices       : Altera MAXV 5M570ZF256C5
--
-- Context              : Max_V_Board Project : Hardware bring-up
--
------------------------------------------------------------------------------------------
-- Description :
--   Top of the CPLD
------------------------------------------------------------------------------------------
-- Information :
--
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Chnages
-- 0.0   See header  GCD          Initial version
-- 1.0   25.09.2014  EMI          Adaptation to use for CSN lab 
-- 1.1   23.03.2015  KGS          Connection with console reds
-- 1.2   20.03.2018  EMI          Adaptation pour labo ALU 2018
--
------------------------------------------------------------------------------------------
--  Used for:
--    Integration of alu12_top.vhd  15.03.2015
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.maxv_pkg.all;

entity maxv_top is
  port(
    --| Clocks, Reset |-------------------------------------------------------------------
    Clk_Gen_i                : in    std_logic;                      -- CLK_GEN
    Clk_Main_i               : in    std_logic;                      -- CLK_MAIN
    --| Inout devices |-------------------------------------------------------------------
    Con_25p_io               : inout std_logic_vector(25 downto 1);  -- CON_25P_*
    Con_80p_io               : inout std_logic_vector(79 downto 2);  -- CON_80P_*
    Mezzanine_io             : inout std_logic_vector(20 downto 5);  -- MEZZANINE_*
    --| Input devices |-------------------------------------------------------------------
    Encoder_A_i              : in    std_logic;                      -- ENCODER_A
    Encoder_B_i              : in    std_logic;                      -- ENCODER_B
    nButton_i                : in    std_logic_vector( 8 downto 1);  -- NBUTTON_*
    nReset_i                 : in    std_logic;                      -- NRESET
    Switch_i                 : in    std_logic_vector( 7 downto 0);  -- SWITCH_*
    --| Output devices |------------------------------------------------------------------
    nLed_o                   : out   std_logic_vector( 7 downto 0);  -- NLED_*
    Led_RGB_o                : out   std_logic_vector( 2 downto 0);  -- LED_RGB_*
    nSeven_Seg_o             : out   std_logic_vector( 7 downto 0)   -- NDSP_SEG (dp, g downto a)
  );
end maxv_top;

architecture struct of maxv_top is


  --| Intermediate signals |--------------------------------------------------------------
  signal Reset_s          : std_logic;
  
  signal Con_25p_DI_s   : std_logic_vector(Con_25p_io'range);
  signal Con_25p_DO_s   : std_logic_vector(Con_25p_io'range);
  signal Con_25p_OE_s   : std_logic;
  signal Con_80p_DI_s   : std_logic_vector(Con_80p_io'range);
  signal Con_80p_DO_s   : std_logic_vector(Con_80p_io'range);
  signal Con_80p_nOE_s   : std_logic_vector(Con_80p_io'range);
  signal Mezzanine_DI_s : std_logic_vector(Mezzanine_io'range);
  signal Mezzanine_DO_s : std_logic_vector(Mezzanine_io'range);
  signal Mezzanine_nOE_s : std_logic;
  signal Button_s       : std_logic_vector(nButton_i'range);
  signal Led_s          : std_logic_vector(nLed_o'range);
  signal Seven_Seg_s    : std_logic_vector(nSeven_Seg_o'range); -- order: dp, g f e d c b a

  --| Internal signals |------------------------------------------------------------------
  constant VAL_N : natural range 1 to 16 := 8; --integration avec 12 bits
  signal Cpt_s : unsigned(19 downto 0);
  signal tmp_s : std_logic_vector(11 downto 0);
  --| Components declaration |------------------------------------------------------------

  component alu_nbits_top is
    generic( N : positive range 1 to 16 := 4);
     port(
       opcode_i      : in  std_logic_vector(2 downto 0);   
       na_i          : in  std_logic_vector(N-1 downto 0);
       nb_i          : in  std_logic_vector(N-1 downto 0);
       result_o      : out std_logic_vector(N-1 downto 0);
       z_o           : out std_logic;
       dep_nsgn_o    : out std_logic;
       dep_sgn_o     : out std_logic
     );
  end component;
    for all : alu_nbits_top use entity work.alu_nbits_top(Struct);
  
begin

  ----------------------------------------------------------------------------------------
  --| INPUTS PROCESSING |-----------------------------------------------------------------
  Reset_s <= not nReset_i;
  Button_s <= not nButton_i;
  
  ----------------------------------------------------------------------------------------
  --| OUTPUT PROCESSING |-----------------------------------------------------------------
  nLed_o <= not Led_s;
  nSeven_Seg_o <= not Seven_Seg_s;
  
  ----------------------------------------------------------------------------------------
  --| Unused output allocation |-----------------------------------------------------------------
  Led_RGB_o <= (others => '0');
  Seven_Seg_s(Seven_Seg_s'high-1 downto 0) <= (others => '0');
  Seven_Seg_s(Seven_Seg_s'high) <= Cpt_s(Cpt_s'high); -- decimal point blink at 1Hz
  
  ----------------------------------------------------------------------------------------
  --| Components intanciation |-----------------------------------------------------------
  U1: alu_nbits_top 
    generic map ( N => VAL_N)
    port map (opcode_i           => Switch_i(2 downto 0),
              na_i               => Con_80p_DI_s(41+(VAL_N-1) downto 41), --    Val_A(VAL_N-1 ... 0)
              nb_i               => Con_80p_DI_s(57+(VAL_N-1) downto 57), --    Val_B(VAL_N-1 ... 0)
              result_o           => Con_80p_DO_s(9+(VAL_N-1) downto 9), -- Result_A(VAL_N-1 ... 0)
              z_o                => Con_80p_DO_s(2),  --led_0
              dep_nsgn_o         => Con_80p_DO_s(3),  --led_1
              dep_sgn_o          => Con_80p_DO_s(4)   --led_2              
    );
  
  -----------------------------------------------------------------------------
  --| Management of the connector 80 pole |------------------------------------
  
  --  --Configuration port 80 poles pour la Console_REDS_logisim
  --   # - Pin(s) 08 downto 02 as inputs # Leds           | 80pConnPort1
  --   # - Pin(s) 16 downto 09 as inputs # Result_A( 7:0) | 80pConnPort2
  --   # - Pin(s) 24 downto 17 as inputs # Result_A(15:8) | 80pConnPort3
  --   # - Pin(s) 32 downto 25 as inputs # Result_B( 7:0) | 80pConnPort4
  --   # - Pin(s) 40 downto 33 as inputs # Result_B(15:8) | 80pConnPort5
  --   # - Pin(s) 48 downto 41 as outputs # Val_A(7:0)    | 80pConnPort6
  --   # - Pin(s) 56 downto 49 as outputs # Val_A(15:8)   | 80pConnPort7
  --   # - Pin(s) 64 downto 57 as outputs # Val_B(7:0)    | 80pConnPort8
  --   # - Pin(s) 72 downto 65 as outputs # Val_B(15:8)   | 80pConnPort9

  -- define direction for 80 poles
  --    '0' = out,   '1' = in 
  Con_80p_nOE_s(79 downto 73) <= (others => '1'); -- unused
  Con_80p_nOE_s(72 downto 41) <= (others => '1'); -- Val_A, Val_B
  Con_80p_nOE_s(40 downto 25) <= (others => '0'); -- Result_B
  Con_80p_nOE_s(24 downto  9) <= (others => '0'); -- Result_A
  Con_80p_nOE_s( 8 downto  2) <= (others => '0'); -- leds sur console tcl  
  
  --debug
  Led_s(0) <=  Con_80p_DO_s(2); --zero
  Led_s(1) <=  Con_80p_DO_s(3); --depassement non-signe
  Led_s(2) <=  Con_80p_DO_s(4); --depassement signe
  Led_s(7 downto 3) <=  (others => '0'); --eteindre autres leds


  
  -- description of the tristate port for 80 pole 
  con_80pole_tristate : for i in 2 to 79 generate
    -- 80P Connector (79 downto 2)-- pins 1 and 80 are not connected to FPGA (connected to GND)
    Con_80p_io(i)    <=  Con_80p_DO_s(i)  when Con_80p_nOE_s(i) = '0'  else
                                'Z';
    Con_80p_DI_s(i)  <=  Con_80p_io(i);
  end generate;


  ----------------------------------------------------------------------------------------
  --| Signal blink at 1Hz |------------------------------------------------------------------
  process (Clk_Main_i, Reset_s)
  begin
    if Reset_s = '1' then
      Cpt_s <= (others => '0');
    elsif rising_edge(Clk_Main_i) then
      Cpt_s <= Cpt_s +1;
    end if;
  end process;
  
  
  
end struct;

