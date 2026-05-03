-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : timer_top.vhd
--
-- Description  :
--
-- Auteur       : Fabien Léger & Antoine Leresche
-- Date         : 01.05.2026
-- Version      : 4.0
--
-- Utilise      : Manipulation Timer pour cours CSN
--
--| Modifications |------------------------------------------------------------
-- Ver   Auteur Date               Description
-- 0.0    EMI   29.09.2014   version intiale, entite du timer_top
-- 1.0    GAA   04.11.2015   Solution timer_top
-- 1.1    GAA   03.12.2015   Correct. détection fin de comptage pour monostable.
--                           Le signal Done_o passait à '1' un tick trop tôt.
--                           Ajout de det_0_s pour la détection de fin en mode
--                           monostable et det_1_s pour le mode diviseur
-- 2.0    EMI   11.11.2016   Nouvelle version du monostable.
--                           signal run_mono doit rester actif (voir enonce 2016)
-- 3.0    ALE   29.04.2026   Ajout du décodeur d'états futur et du registre
-- 4.0    FLR   01.05.2026   Ajout du décodeur de sorties et réagancement code
-- 5.0    FLR   02.05.2026   Fix du code après modification table des fct sync
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
  -- signaux registre
  signal reset_s         : std_logic;
  signal cpt_pres_s      : unsigned(6 downto 0);
  signal cpt_fut_s       : unsigned(6 downto 0);

  -- signaux décodeur d'états futurs
  signal to_decr_s, decr_out_s  : unsigned(6 downto 0); -- val ou cpt_pres à décrémenter par la suite
  signal dec_div_s, dec_mono_s: unsigned(6 downto 0);

  -- signaux décodeur de sorties
  signal eq_zero_s       : std_logic;
begin

    -- adaptation de polarité
    reset_s <= not nReset_i;

    -- décrémentation selon val ou cpt_pres
    to_decr_s <= unsigned(val_i) when (en_div_i = '1' and eq_zero_s = '1') else
                      cpt_pres_s;
    decr_out_s <= to_decr_s - 1;

    -- décodeur pour mode mono
    dec_mono_s <= unsigned(val_i) when run_mono_i = '0' else
                    to_unsigned(0, cpt_pres_s'length) when eq_zero_s = '1' else
                    decr_out_s;
    -- décodeur pour mode div
    dec_div_s <= to_unsigned(0, cpt_pres_s'length) when en_div_i = '0' else
                decr_out_s;

    -- décodeur d'états futurs
    cpt_fut_s <= dec_mono_s when Mono_nDiv_i = '1' else
                    dec_div_s;


    -- registre
    process(reset_s, clock_i)
    begin
        if reset_s = '1' then
            cpt_pres_s <= (others => '0');
        elsif rising_edge(clock_i) then
            cpt_pres_s <= cpt_fut_s;
        end if;
    end process;

    -- décodeur de sorties
    -- égalité à '0' -> fin du timer
    eq_zero_s <= '1' when (cpt_pres_s = 0) else
    	         '0';

    -- mise à '1' si en mod div sans l'en activé sinon égalité avec zéro
    done_o <= eq_zero_s;

end timer;
