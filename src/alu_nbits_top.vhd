-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : alu_nbits_top.vhd
--
-- Description  : ALU N bits comportant 6 fonctions arithmetiques et 
--                2 fonctions logique
-- 
-- Auteur       : Etienne Messerli
-- Date         : 20.03.2018 (version labo ALU 2018)
-- Version      : 0.0
-- 
--| Modifications |------------------------------------------------------------
-- Version  Date   Auteur     Description
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.ALL;
  use ieee.numeric_std.ALL;

entity alu_nbits_top is
  generic( N : positive range 1 to 16 := 4);
   port(
      opcode_i      : in  std_logic_vector(2 downto 0);   
      na_i          : in  std_logic_vector(N-1 downto 0);
      nb_i          : in  std_logic_vector(N-1 downto 0);
      result_o      : out std_logic_vector(N-1 downto 0);
      z_o           : out std_logic;
      dep_nsgn_o    : out std_logic;
      dep_sgn_o     : out std_logic
   );
end alu_nbits_top ;


architecture struct of alu_nbits_top is

  -- Signaux interne

     -- to be completed
    
  -- Component Declaration

     -- to be completed

begin


  -- to be completed








               
end struct;
