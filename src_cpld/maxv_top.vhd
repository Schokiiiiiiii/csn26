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
--   30.09.2014  EMI  Adaptation for the aff_min_max lab
--
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Changes
-- 0.0   See header  GCD          Initial version
-- 1.0   25.09.2014  EMI          Modified to use for CSN lab 
-- 1.1   01.10.2014  GHR          Adaptation to use with the Aff_Min_Max.tcl
--                                and the board Console-USB2 to test circuit
--
------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
  signal Con_80p_OE_s   : std_logic_vector(Con_80p_io'range);
  signal Mezzanine_DI_s : std_logic_vector(Mezzanine_io'range);
  signal Mezzanine_DO_s : std_logic_vector(Mezzanine_io'range);
  signal Mezzanine_OE_s : std_logic;
  signal Button_s       : std_logic_vector(nButton_i'range);
  signal Led_s          : std_logic_vector(nLed_o'range);
  signal Seven_Seg_s    : std_logic_vector(nSeven_Seg_o'range); -- order: dp, g f e d c b a

  --| Internal signals |------------------------------------------------------------------
  signal cpt_s : unsigned(19 downto 0);
  signal blink_1hz_s : std_logic;
  signal osc_s : std_logic;

  --| Components declaration |------------------------------------------------------------

  component timer_top is
     port( 
        clock_i      : in   std_logic;
        nReset_i     : in   std_logic;
        en_div_i     : in   std_logic;
        Mono_nDiv_i  : in   std_logic;
        run_mono_i : in   std_logic;
        val_i        : in   std_logic_vector(6 downto 0);
        done_o       : out  std_logic
     );
  end component;
  for all : timer_top use entity work.timer_top(timer);
  
  signal done_s : std_logic;
  
begin

  ----------------------------------------------------------------------------------------
  --| INPUTS PROCESSING |-----------------------------------------------------------------
  Reset_s <= not nReset_i;
  Button_s <= not nButton_i;
  
  ----------------------------------------------------------------------------------------
  --| OUTPUT PROCESSING |-----------------------------------------------------------------
  nLed_o <= not Led_s;
  nSeven_Seg_o <= not Seven_Seg_s;

  -- Tri-state declaration for the 80p connector  
  Con_80p_OE_s(40 downto  2) <= (others => '0'); -- used as inputs 
  Con_80p_OE_s(56 downto 41) <= (others => '1'); -- outputs, leds_o
  Con_80p_OE_s(79 downto 57) <= (others => '0'); -- used as inputs 

  tri_state_loop: for I in Con_80p_io'right to Con_80p_io'left generate
    Con_80p_io(I)   <= Con_80p_DO_s(I) when Con_80p_OE_s(I) = '1' else
                       'Z';
  end generate;

  Con_80p_DI_s      <= to_X01(Con_80p_io);

  ----------------------------------------------------------------------------------------
  --| Unused output allocation |-----------------------------------------------------------------
  Led_RGB_o <= (others => '0');
  --Seven_Seg_s(Seven_Seg_s'high-1 downto 0) <= (others => '0');
  Seven_Seg_s(Seven_Seg_s'high) <= blink_1hz_s; -- decimal point blink at 1Hz
  --Led_s <= Button_s; --unused leds connected to button 
  
  ----------------------------------------------------------------------------------------
  --| Components intanciation |-----------------------------------------------------------
  U1: timer_top 
  port map (
     clock_i      => Clk_Main_i,
     nReset_i     => nReset_i,
     en_div_i     => Button_s(1),
     Mono_nDiv_i  => Switch_i(7),
     run_mono_i => Button_s(8),
     val_i        => Switch_i(6downto 0),
     done_o       => done_s
  );

  Led_s(0) <= done_s;
  Con_25p_io(1) <= done_s;  -- mesure avec oscillo sur pin 1
  ----------------------------------------------------------------------------------------
  --| Generation of blink_1hz_s and oscill_s |--------------------------------------------
  process (Clk_Main_i, Reset_s)
  begin
    if Reset_s = '1' then
      cpt_s <= (others => '0');
    elsif rising_edge(Clk_Main_i) then
      cpt_s <= cpt_s +1;
    end if;
  end process;
  
  -- signal for test 
  blink_1hz_s <= cpt_s(cpt_s'high);
  -- signal ocsl_s generation:
  --     use fonction "cpt_s(9) and cpt_s(8) and cpt_s(7)" to have a frequency from 1KHz
  ---    with duty cycle of 12% on/ 75% off (25% on: very small difference!) 
  osc_s <= cpt_s(9) and cpt_s(8) and cpt_s(7); 

  
end struct;

