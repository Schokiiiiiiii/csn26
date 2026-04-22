-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : flipflop_rs.vhd
-- Description  : Flip-flop RS
-- 
-- Auteur       : Fabien Léger
-- Date         : 22.04.2026
-- Version      : 1.0
-- 
-- Utilise      : Exos description d'elements memoire en VHDL synthetisable
--| Modifications |------------------------------------------------------------
-- Version   Author Date               Description
-- 1.0       FLR    22.04.2026         Implemented rs flipflop
--
-------------------------------------------------------------------------------

--   Table de fonctionnement synchrone
--   du flip-flop RS
--
--    R  S |   Q+
--   ------+-------
--    0  0 |   Q
--    0  1 |   1
--    1  0 |   0
--    1  1 | interdit




library ieee;
  use ieee.std_logic_1164.all;

entity flipflop_rs is
   port(clk_i    : in     std_logic;
        reset_i  : in     std_logic;  --asynchrone
        R_i      : in     std_logic;  --synchrone
        S_i      : in     std_logic;  --synchrone
        Q_o      : out    std_logic
   );
end flipflop_rs ;

architecture comport of flipflop_rs is

signal q_s: std_logic;

begin
  --Adaptation polarite
  
  process(reset_i, clk_i)
  begin
    if reset_i = '1' then
      q_s <= '0';
    elsif rising_edge(clk_i) then
      if R_i = '1' then
        q_s <= '0';
      elsif S_i = '1' then
        q_s <= '1';
      end if;
    end if;
  end process;

  Q_o <= q_s;

end comport;
