-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : dff_ar.vhd
--
-- Description  : 
-- 
-- Auteur       : Fabien Léger
-- Date         : 17.04.2026
-- Version      : 0.0
-- 
-- Utilise      : Exercice de description d'elements memoire
--                en VHDL synthetisable
-- 
--| Modifications |------------------------------------------------------------
-- Version   Auteur Date               Description
-- 1.0       FLR    17.04.2026         First version of the flip-flop D
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dff_ar is
   port( 
      clk_i   : in     std_logic;
      reset_i : in     std_logic;
      D_i     : in     std_logic;
      Q_o     : out    std_logic;
      nQ_o    : out    std_logic
   );
end dff_ar ;

architecture comport of dff_ar is

signal Q_s: std_logic;

begin

  process(reset_i, clk_i)
  begin
    if reset_i = '1' then
      Q_s  <= '0';
    elsif rising_edge(clk_i) then
      Q_s  <= D_i;
    end if;
  end process;

  Q_o  <= Q_s;
  nQ_o <= not Q_s;
  
end comport;

