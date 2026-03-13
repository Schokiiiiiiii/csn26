-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : addn.vhd
-- Description  : N bits adder with carry in/out
--
-- Author       : Fabien Léger
-- Date         : 13.03.36
-- Version      : 3.0
--
-- Dependencies : none
--
--| Changelog |----------------------------------------------------------------
-- Version  Author  Date        Description
-- 0.0      EMI     10.10.14    Initial version
-- 1.0      YNG     28.01.25    Update header
-- 2.0	    FLR     06.03.26    Added basic additionner
-- 3.0	    FLR     06.03.26    Transformed to a generic additionner
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- forcing entity to accept [1, 32] for performance issues
entity addn is
  generic(N : positive range 1 to 32 := 4);
  port (nbr_a_i : in  std_logic_vector(N-1 downto 0);
        nbr_b_i : in  std_logic_vector(N-1 downto 0);
        cin_i   : in  std_logic;
        sum_o   : out std_logic_vector(N-1 downto 0);
        cout_o  : out std_logic
        );
end addn;

architecture flot_don of addn is

  -- need to be 1 bit higher for cout handling
  signal na_s, nb_s : unsigned(N downto 0);
  signal ci_s       : unsigned(N downto 0);
  signal sum_s      : unsigned(N downto 0);
  
begin

  -- add 1 bit for MSB to account for possible carry
  na_s <= '0' & unsigned(nbr_a_i);
  nb_s <= '0' & unsigned(nbr_b_i);
  ci_s <= (ci_s'low => cin_i, others => '0');
  
  -- sum both number with carry in
  sum_s <= na_s + nb_s + ci_s;
  
  -- separate sum out and carry out
  sum_o  <= std_logic_vector(sum_s(sum_o'length-1 downto 0));
  cout_o <= std_logic(sum_s(sum_s'high)); -- MSB as carry

end flot_don;
