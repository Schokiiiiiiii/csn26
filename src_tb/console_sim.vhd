-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : console_sim.vhd
--
-- Description  : Ce fichier permet l'utilisation de la console generique du REDS.
-- 
-- Auteur       : Gilles Habegger
-- Date         : 20.04.2015
-- 
-- Utilise      : -
-- 
--| Modifications |------------------------------------------------------------
-- Version   	Auteur 	Date              Description
-- 0.0			 	GHR			20.04.2015				Premiere version de console_sim
--  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity console_sim is
  port(
    -- 16 switchs
    S0_sti       : in     std_logic;
    S1_sti       : in     std_logic;
    S2_sti       : in     std_logic;
    S3_sti       : in     std_logic;
    S4_sti       : in     std_logic;
    S5_sti       : in     std_logic;
    S6_sti       : in     std_logic;
    S7_sti       : in     std_logic;
    S8_sti       : in     std_logic;
    S9_sti       : in     std_logic;
    S10_sti      : in     std_logic;
    S11_sti      : in     std_logic;
    S12_sti      : in     std_logic;
    S13_sti      : in     std_logic;
    S14_sti      : in     std_logic;
    S15_sti      : in     std_logic;
    -- 2 valeurs sur 16 bits
    Val_A_sti    : in     std_logic_vector (15 downto 0);
    Val_B_sti    : in     std_logic_vector (15 downto 0);
    -- 16 LEDs
    L0_obs       : out    std_logic;
    L1_obs       : out    std_logic;
    L2_obs       : out    std_logic;
    L3_obs       : out    std_logic;
    L4_obs       : out    std_logic;
    L5_obs       : out    std_logic;
    L6_obs       : out    std_logic;
    L7_obs       : out    std_logic;
    L8_obs       : out    std_logic;
    L9_obs       : out    std_logic;
    L10_obs      : out    std_logic;
    L11_obs      : out    std_logic;
    L12_obs      : out    std_logic;
    L13_obs      : out    std_logic;
    L14_obs      : out    std_logic;
    L15_obs      : out    std_logic;
    -- 2 valeurs hexadecimales
    Hex0_obs     : out    Std_Logic_Vector ( 3 downto 0);
    Hex1_obs     : out    Std_Logic_Vector ( 3 downto 0);
    -- 2 resultats sur 16 bits
    Result_A_obs : out    std_logic_vector (15 downto 0);
    Result_B_obs : out    std_logic_vector (15 downto 0);
    -- 1 affichage 7 segments
    -- seg7_obs(0) -> DP (pas present)
    -- seg7_obs(1) -> G
    -- seg7_obs(2) -> F
    -- seg7_obs(3) -> E
    -- seg7_obs(4) -> D
    -- seg7_obs(5) -> C
    -- seg7_obs(6) -> B
    -- seg7_obs(7) -> A
    seg7_obs     : out    std_logic_vector ( 7 downto 0)
  );

-- Declarations

end console_sim ;

architecture struct of console_sim is
  
   -- Internal signal declarations
   signal clk_s  : Std_Logic := '1';  -- clock for the simulation
   constant PERIODE : time := 100 ns;
   
   component timer_top
     port( 
        clock_i      : in   std_logic;
        nReset_i     : in   std_logic;
        en_div_i     : in   std_logic;
        Mono_nDiv_i  : in   std_logic;
        run_mono_i   : in   std_logic;
        val_i        : in   std_logic_vector(6 downto 0);
        done_o       : out  std_logic
     );
   end component;
   for all : timer_top use entity work.timer_top;

begin

  -- Clock generator for the simulation ---------------------------------------
  process
  begin
    clk_s <= '0', '1' after PERIODE/4, '0' after 3 * PERIODE/4;
    wait for PERIODE;
  end process;


  -- Instance port mappings.
  uut : timer_top port map ( 
    clock_i     => clk_s,
    nReset_i    => S0_sti,
    en_div_i    => S1_sti,
    Mono_nDiv_i => S2_sti,
    run_mono_i  => S3_sti,
    val_i(0)    => Val_A_sti(0),
    val_i(1)    => Val_A_sti(1),
    val_i(2)    => Val_A_sti(2),
    val_i(3)    => Val_A_sti(3),
    val_i(4)    => Val_A_sti(4),
    val_i(5)    => Val_A_sti(5),
    val_i(6)    => Val_A_sti(6),
    done_o      => L0_obs);
end struct;