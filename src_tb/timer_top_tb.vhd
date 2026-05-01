-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : timer_top_tb.vhd
--
-- Description  : Banc de test automatique (test bench) pour 
--                Timer (struct connection uut avec tester)
-- 
-- Auteur       : Gaëtan Matthey
-- Date         : 04.11.2015
-- Version      : 0.0
-- 
-- Utilise      : Manipulation de laboratoire du cours CSN
--                Banc de test automatique (test bench) 
-- 
--| Modifications |------------------------------------------------------------
-- Version   Auteur Date               Description
-- 
-------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.ALL;
  use ieee.numeric_std.ALL;

entity timer_top_tb is
end timer_top_tb ;

architecture struct of timer_top_tb is

   -- Architecture declarations

   -- Internal signal declarations
   signal done_obs      : std_logic;
   signal clock_sti     : std_logic;
   signal en_div_sti    : std_logic;
   signal Mono_nDiv_sti : std_logic;
   signal run_mono_sti  : std_logic;
   signal val_sti       : std_logic_vector(6 downto 0);
   signal nReset_sti    : std_logic;


   -- Component Declarations
   component timer_top
   port (
      done_o      : out     std_logic;
      clock_i     : in    std_logic;
      en_div_i    : in    std_logic;
      Mono_nDiv_i : in    std_logic;
      run_mono_i  : in    std_logic;
      val_i       : in    std_logic_vector (6 downto 0);
      nReset_i    : in 	  std_logic
   );
   end component;

   component timer_top_tester
   port (
      done_obs      : in     std_logic;
      clock_sti     : out    std_logic;
      en_div_sti    : out    std_logic;
      Mono_nDiv_sti : out    std_logic;
      run_mono_sti  : out    std_logic;
      val_sti       : out    std_logic_vector (6 downto 0);
      nReset_sti    : out 	  std_logic
   );
   end component;

   -- Optional embedded configurations
   for all : timer_top use entity work.timer_top;
   for all : timer_top_tester use entity work.timer_top_tester;


begin

   -- Instance port mappings.
   uut : timer_top
      port map (
         done_o      => done_obs,
         clock_i     => clock_sti,
         en_div_i    => en_div_sti,
         Mono_nDiv_i => Mono_nDiv_sti,
         run_mono_i  => run_mono_sti,
         val_i       => val_sti,
         nReset_i    => nReset_sti
      );
   tst : timer_top_tester
      generic map (
         mode_normal_optionnel => TRUE
      )
      port map (
         done_obs      => done_obs,
         clock_sti     => clock_sti,
         en_div_sti    => en_div_sti,
         Mono_nDiv_sti => Mono_nDiv_sti,
         run_mono_sti  => run_mono_sti,
         val_sti       => val_sti,
         nReset_sti    => nReset_sti
      );

end struct;
