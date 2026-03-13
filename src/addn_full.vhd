-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : addn_full.vhd
-- Description  : N bits adder with carry in/out & overflow
--
-- Author       : Fabien Léger
-- Date         : 13.03.26
-- Version      : 4.0
--
-- Dependencies : addn.vhd
--
--| Changelog |----------------------------------------------------------------
-- Version  Author  Date        Description
-- 0.0      EMI     10.10.14    Initial version
-- 1.0      YNG     28.01.25    Update header
-- 2.0	    FLR     06.03.26    Added basic additionner
-- 3.0      FLR     06.03.26    Added overflow handling
-- 4.0	    FLR     13.03.26    Transformed to a generic additionner
--
-------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-- forcing entity to accept [2, 32] for performance and adder separation
entity addn_full is
  generic(N : positive range 2 to 32 := 4);
  port (nbr_a_i : in  std_logic_vector(N-1 downto 0);
        nbr_b_i : in  std_logic_vector(N-1 downto 0);
        cin_i   : in  std_logic;
        sum_o   : out std_logic_vector(N-1 downto 0);
        cout_o  : out std_logic;
        ovr_o   : out std_logic  );
end addn_full;

architecture struct of addn_full is

  -- carry n-1 and n
  signal cn_m1_s : std_logic;
  signal cn_s : std_logic;
  
  -- adder n bit
  component addn is
    generic(N : positive range 1 to 32 := 4);
    port (nbr_a_i : in  std_logic_vector(N-1 downto 0);
          nbr_b_i : in  std_logic_vector(N-1 downto 0);
          cin_i   : in  std_logic;
          sum_o   : out std_logic_vector(N-1 downto 0);
          cout_o  : out std_logic
          );
  end component;
  for all : addn use
  	    entity work.addn(flot_don);
  
begin

  -- calculate the n-2 bits addition and take carry n-1
  add3: addn
    generic map (N => N-1)
    port map (nbr_a_i => nbr_a_i(N-2 downto 0),
              nbr_b_i => nbr_b_i(N-2 downto 0),
              cin_i   => cin_i,
              sum_o   => sum_o(N-2 downto 0),
              cout_o  => cn_m1_s
              );

  -- calculate the n-1 bit and take carry n
  add1: addn
    generic map (N => 1)
    port map (nbr_a_i => nbr_a_i(N-1 downto N-1),
              nbr_b_i => nbr_b_i(N-1 downto N-1),
              cin_i   => cn_m1_s,
              sum_o   => sum_o(N-1 downto N-1),
              cout_o  => cn_s
              );
     
  -- compute overflow and carry out    
  ovr_o  <= cn_m1_s xor cn_s;
  cout_o <= cn_s;           

end struct;
