-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : flipflop_t.vhd
-- Description  : Flip-flop T (toggle) soit 
--                  si T_i actif alors Q+ = not Q sinon Q+ = Q
-- 
-- Auteur       : Fabien Léger
-- Date         : 22.04.2026
-- Version      : 1.0
--
-- Utilise      : Exos description d'elements memoire en VHDL synthetisable
--| Modifications |------------------------------------------------------------
-- Version   Author Date               Description
-- 1.0       EMI    03.04.2019         Change nom entite/fichier => flipflop_t
-- 2.0       FLR    22.04.2026         Completed comportment definition
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity flipflop_t is
   port(clk_i    : in     std_logic;
        reset_i  : in     std_logic;
        T_i      : in     std_logic;
        Q_o      : out    std_logic
   );
end flipflop_t ;


architecture comport of flipflop_t is
  signal reset_s : std_logic;
  signal q_s     : std_logic;

begin
  -- Adaptation polarite
  reset_s <= reset_i;
  -- q_s = '-' otherwise ? => no need to affect q_s
  
  process(reset_s, clk_i)
  begin
    if reset_s = '1' then
      q_s <= '0';
    elsif rising_edge(clk_i) then
      if T_i = '1' then
        q_s <= not q_s;
      end if;
    end if;
  end process;

  Q_o <= q_s;
  
end comport;
