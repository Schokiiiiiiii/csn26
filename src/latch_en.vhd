-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : latch_en.vhd
--
-- Description  : 
-- 
-- Auteur       : Fabien Léger
-- Date         : 22.04.2026
-- Version      : 1.0
-- 
-- Utilise      : Exercice de description d'elements memoire
--                en VHDL synthetisable
-- 
--| Modifications |------------------------------------------------------------
-- Version   Auteur Date               Description
-- 1.0       FLR    22.04.2026         Finished first version 
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity latch_en is
   port( 
      en_i    : in     std_logic;
      reset_i : in     std_logic;
      D_i     : in     std_logic;
      Q_o     : out    std_logic
   );
end latch_en ;

architecture comport of latch_en is

begin

  process(D_i, en_i, reset_i)
  begin
    if reset_i = '1' then
      Q_o  <= '0';
    elsif en_i = '1' then
      Q_o <= D_i;
    end if;
  end process;

end comport;

