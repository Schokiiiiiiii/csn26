-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : alu_nbits_top.vhd
--
-- Description  : ALU N bits with 6 arithmetical functions and 
--                2 logical functions
-- 
-- Auteur       : Fabien Léger & Nadia Cattin
-- Date         : 20.03.2026
-- Version      : 1.0
-- 
--| Modifications |------------------------------------------------------------
-- Version  Date      Auteur    Description
-- 1.0      20.03.26  FLR	Created general schema
-- 1.1      23.03.26  FLR       Simplified schema and fixed a selection
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

  ------------------------------------------------------------------
  -- Intern signals
  
  -- adder signals
  signal sel_p_s             : std_logic;
  signal add_p_s             : std_logic_vector(N-1 downto 0);
  signal add_q_s             : std_logic_vector(N-1 downto 0);
  signal add_q_before_sign_s : std_logic_vector(N-1 downto 0);
  signal add_res_s           : std_logic_vector(N-1 downto 0);
  signal cn_s, ovr_s         : std_logic;
  
  -- logic signals
  signal sel_logic_s : std_logic;
  signal logic_res_s : std_logic_vector(N-1 downto 0);
  
  -- result signals
  signal res_s : std_logic_vector(N-1 downto 0);
    
  ------------------------------------------------------------------
  -- Component declaration

  -- adder
  component addn_full is
    generic(N : positive range 2 to 32 := 4);
    port (nbr_a_i : in  std_logic_vector(N-1 downto 0);
          nbr_b_i : in  std_logic_vector(N-1 downto 0);
          cin_i   : in  std_logic;
          sum_o   : out std_logic_vector(N-1 downto 0);
          cout_o  : out std_logic;
          ovr_o   : out std_logic  );
  end component;
  for all : addn_full use
              entity work.addn_full(flot_don);

begin
  
  ------------------------------------------------------------------
  -- Adder
  
  -- selection for p
  sel_p_s <= '1' when opcode_i(2 downto 0) = "101" else
             '0';
  
  -- left operand
  add_p_s <= nb_i when sel_p_s = '1' else
             na_i;
  
  -- right operand
  with opcode_i(1 downto 0) select
    add_q_before_sign_s <= nb_i when "00",
                           na_i when "01",
                           (others => '-') when "10",
                           (0 => '1', others => '0') when "11",
                           (others => 'X') when others;
                          
  -- right operand possible inversion
  add_q_s <= (not add_q_before_sign_s) when opcode_i(2) = '1' else
                  add_q_before_sign_s;
                 
  -- addition
  adder: addn_full
    generic map (N => N)
    port map (nbr_a_i => add_p_s,
              nbr_b_i => add_q_s,
              cin_i   => opcode_i(2),
              sum_o   => add_res_s,
              cout_o  => cn_s,
              ovr_o   => ovr_s);

  ------------------------------------------------------------------
  -- Logic
  
  sel_logic_s <= '1' when opcode_i(1 downto 0) = "10" else
                 '0';

  logic_res_s <= (na_i or nb_i) when opcode_i(2) = '1' else
                 (na_i and nb_i);
  
  ------------------------------------------------------------------
  -- Result
  
  res_s <= logic_res_s when sel_logic_s = '1' else
           add_res_s;
          
  result_o <= res_s;
  
  ------------------------------------------------------------------
  -- Flags

  -- zero
  z_o <= '1' when unsigned(res_s) = 0 else
         '0';
    
  -- excess unsigned
  dep_nsgn_o <= (not cn_s) when opcode_i(2) = '1' else
                cn_s;
  
  -- excess signed
  dep_sgn_o  <= ovr_s;
               
end struct;
