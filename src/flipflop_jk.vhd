-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : flipflop_jk.vhd
-- Description  : Flip-flop JK
-- 
-- Auteur       : Fabien Léger
-- Date         : 22.04.2026
-- Version      : 1.0
-- 
-- Utilise      : Exos description d'elements memoire en VHDL synthetisable
--| Modifications |------------------------------------------------------------
-- Version   Author Date               Description
-- 1.0       FLR    22.04.2026         Implemented jk flipflop
--
-------------------------------------------------------------------------------

--   Table de fonctionnement synchrone
--   du flip-flop JK
--
--    J  K |   Q+
--   ------+-------
--    0  0 |   Q
--    0  1 |   0
--    1  0 |   1
--    1  1 | not Q




library ieee;
  use ieee.std_logic_1164.all;

entity flipflop_jk is
   port(clk_i    : in     std_logic;
        reset_i  : in     std_logic;
        J_i      : in     std_logic;
        K_i      : in     std_logic;
        Q_o      : out    std_logic;
        nQ_o     : out    std_logic
   );
end flipflop_jk ;

architecture comport of flipflop_jk is

signal q_s: std_logic;

begin
  --Adaptation polarite
  
  process(reset_i, clk_i)
  begin
    if reset_i = '1' then
      q_s <= '0';
    elsif rising_edge(clk_i) then
      if J_i = '1' and K_i = '1' then
        q_s <= not q_s;
      elsif J_i = '1' then
        q_s <= '1';
      elsif K_i = '1' then
        q_s <= '0';
      end if;
    end if;
  end process;
  
  Q_o  <= q_s;
  nQ_o <= not q_s;

end comport;
