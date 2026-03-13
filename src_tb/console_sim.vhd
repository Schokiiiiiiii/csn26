-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : console_sim.vhd
--
-- Description  : Ce fichier permet l'utilisation de la console generique du REDS.
-- 
-- Auteur       : Gilles Habegger
-- Date         : 20.04.2015
-- 
-- Utilise      : -
-- 
--| Modifications |------------------------------------------------------------
-- Version   	Auteur 	Date              Description
-- 0.0			 	GHR			20.04.2015				Premiere version de console_sim
--  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity console_sim is
  port(
    -- 16 switchs
    S0_sti       : in     std_logic;
    S1_sti       : in     std_logic;
    S2_sti       : in     std_logic;
    S3_sti       : in     std_logic;
    S4_sti       : in     std_logic;
    S5_sti       : in     std_logic;
    S6_sti       : in     std_logic;
    S7_sti       : in     std_logic;
    S8_sti       : in     std_logic;
    S9_sti       : in     std_logic;
    S10_sti      : in     std_logic;
    S11_sti      : in     std_logic;
    S12_sti      : in     std_logic;
    S13_sti      : in     std_logic;
    S14_sti      : in     std_logic;
    S15_sti      : in     std_logic;
    -- 2 valeurs sur 16 bits
    Val_A_sti    : in     std_logic_vector (15 downto 0);
    Val_B_sti    : in     std_logic_vector (15 downto 0);
    -- 16 LEDs
    L0_obs       : out    std_logic;
    L1_obs       : out    std_logic;
    L2_obs       : out    std_logic;
    L3_obs       : out    std_logic;
    L4_obs       : out    std_logic;
    L5_obs       : out    std_logic;
    L6_obs       : out    std_logic;
    L7_obs       : out    std_logic;
    L8_obs       : out    std_logic;
    L9_obs       : out    std_logic;
    L10_obs      : out    std_logic;
    L11_obs      : out    std_logic;
    L12_obs      : out    std_logic;
    L13_obs      : out    std_logic;
    L14_obs      : out    std_logic;
    L15_obs      : out    std_logic;
    -- 2 valeurs hexadecimales
    Hex0_obs     : out    Std_Logic_Vector ( 3 downto 0);
    Hex1_obs     : out    Std_Logic_Vector ( 3 downto 0);
    -- 2 resultats sur 16 bits
    Result_A_obs : out    std_logic_vector (15 downto 0);
    Result_B_obs : out    std_logic_vector (15 downto 0);
    -- 1 affichage 7 segments
    -- seg7_obs(0) -> DP (pas present)
    -- seg7_obs(1) -> G
    -- seg7_obs(2) -> F
    -- seg7_obs(3) -> E
    -- seg7_obs(4) -> D
    -- seg7_obs(5) -> C
    -- seg7_obs(6) -> B
    -- seg7_obs(7) -> A
    seg7_obs     : out    std_logic_vector ( 7 downto 0)
  );
end console_sim ;

architecture struct of console_sim is

  constant VAL_N : natural range 1 to 16 := 4; --declaration taille alu_n
  
  component alu_nbits_top
     generic( N : positive range 1 to 16 := 4);
     port(
        opcode_i        : in std_logic_vector(2 downto 0);   
        na_i            : in std_logic_vector(N-1 downto 0);
        nb_i            : in std_logic_vector(N-1 downto 0);
        result_o        : out std_logic_vector(N-1 downto 0);
        z_o             : out std_logic;
        dep_nsgn_o      : out std_logic;
        dep_sgn_o       : out std_logic
      );
  end component;
  for all : alu_nbits_top use entity work.alu_nbits_top;

  signal opcode_s   : std_logic_vector(2 downto 0);
  signal na_s, nb_s : std_logic_vector(3 downto 0);
  signal result_s   : std_logic_vector(3 downto 0); 
  
begin

-- Affectation signaux
  opcode_s(0) <= S0_sti;
  opcode_s(1) <= S1_sti;
  opcode_s(2) <= S2_sti;
  na_s        <= Val_A_sti(3 downto 0);
  nb_s        <= Val_B_sti(3 downto 0);
  
  --affectation de Result_A_obs avec result_s, puis bits de poids fort a '0'
  process(result_s)
  begin
    Result_A_obs <= (others => '0');
    for I in 0 to VAL_N-1 loop
      Result_A_obs(I) <= result_s(I);
    end loop;
  end process;

-- Instanciation du composant a simuler
   UUT : alu_nbits_top
      generic map (N => 4)
      port map (opcode_i    => opcode_s,
                na_i        => na_s,
                nb_i        => nb_s,
                result_o    => result_s,
                z_o         => L0_obs,
                dep_nsgn_o  => L1_obs,
                dep_sgn_o   => L2_obs
      );   

  
end struct;