-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : timer_top.vhd
--
-- Description  : 
-- 
-- Auteur       : Etienne Messerli
-- Date         : 28.10.2015
-- Version      : 0.0
-- 
-- Utilise      : Manipulation Timer pour cours CSN
-- 
--| Modifications |------------------------------------------------------------
-- Ver   Auteur Date               Description
-- 0.0    EMI   29.09.2014   version intiale, entite du timer_top
-- 1.0    GAA   04.11.2015   Solution timer_top 
-- 1.1    GAA   03.12.2015   Correct. détection fin de comptage pour monostable.
--         Le signal Done_o passait à '1' un tick trop tôt. Ajout de det_0_s pour 
--         la détection de fin en mode monostable et det_1_s pour le mode diviseur
-- 2.0    EMI   11.11.2016   Nouvelle version du monostable.
--                           signal run_mono doit rester actif (voir enonce 2016)
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity timer_top is
   port( 
      clock_i      : in   std_logic;
      nReset_i     : in   std_logic;
      Mono_nDiv_i  : in   std_logic;
      en_div_i     : in   std_logic;
      run_mono_i   : in   std_logic;
      val_i        : in   std_logic_vector(6 downto 0);
      done_o       : out  std_logic
   );
end timer_top ;

architecture timer of timer_top is
  signal reset_s  	: std_logic;
  signal cpt_pres_s : unsigned(6 downto 0);
  signal cpt_fut_s  : unsigned(6 downto 0);

  -- TO COMPLETE

begin

  -- TO COMPLETE

end timer;
