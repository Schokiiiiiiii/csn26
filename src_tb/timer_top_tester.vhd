-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : Timer_top_tester_Test_Bench.vhd
--
-- Description  : 
-- 
-- Auteur       : Messerli
-- Date         : 07.12.2010
-- Version      : 0.0
-- 
-- Utilise      : Ce fichier est genere automatiquement par le logiciel 
--              : \"HDL Designer Series HDL Designer\".
-- 
--| Modifications |------------------------------------------------------------
-- Ver   Auteur   Date      Description
-- 1.0   GAA    03.12.2015  Correction de la partie monostable :
--                             for J in 1 to Val_v-2 loop ==> 
--                                    for J in 1 to Val_v-1 loop.
-- 1.1   FCC    22.11.2016   Adapter au nouvel énoncé 2016.  
-- 1.2   EMI    02.12.2016   Modifier modulo Val_v a 128
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity Timer_top_tester is
   port( 
      Done_obs       : in     std_logic;
      Clock_sti      : out    std_logic;
      En_Div_sti     : out    std_logic;
      Mono_nDiv_sti  : out    std_logic;
      run_mono_sti   : out    std_logic;
      Val_sti        : out    std_logic_vector (6 downto 0);
      nReset_sti     : out    std_logic
   );

-- Declarations

end Timer_top_tester ;



architecture Test_Bench of Timer_top_tester is

  constant Periode_c   : time := 100 ns;
  constant Pulse_c     : time := 4 ns;  --duree impulsion sur erreur, ..  
  constant Tp_c        : time := 5 ns;  --temps de propagation

  --signaux de base pour la simulation sequentiel (HORLOGE)
  signal Sim_End_s : boolean := false;
  signal Horloge_s : Std_Logic;       -- signal d'horloge
  --signal Debut_Cycle : Std_Logic;   -- indique debut cycle horloge

  --signaux de detection des erreurs (check), propre a l'application
  signal Erreur_s : Std_Logic := '0';
  shared variable Nbr_Err_v : Integer;

  --signaux intermediares pour la simulation, propre a l'application
  signal Reset_sti : Std_Logic;
  signal Done_ref : Std_logic;
---------------------------------------------------------------------------
-- Procedure permettant plusieurs cycles d'horloge
-- Le premier appel de la procedure termine le cycle precedent si celui-ci
-- n'etait pas complet (par exemple : si on a fait quelques pas de 
-- simulation non synchronises avant, reset asynchrone, combinatoire, ...)
---------------------------------------------------------------------------
  procedure cycle (nombre_de_cycles : Integer := 1) is
    begin
      for i in 1 to nombre_de_cycles loop
         wait until Falling_Edge(Horloge_s);
         wait for 2 ns; --assigne stimuli 2ns apres flanc montant 
      end loop;
  end cycle;

begin

	-- ASK THE ASSISTANT FOR THE COMPLETE FILE ONCE YOU HAVE MANUALLY VALIDATED YOUR SOLUTION

end architecture Test_Bench;

