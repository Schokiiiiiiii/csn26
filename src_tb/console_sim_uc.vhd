-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : console_sim_uc.vhd
--
-- Description  : Ce fichier permet l'utilisation de la console generique du REDS.
-- 
-- Auteur       : Etienne Messerli
-- Date         : 17.05.2024
-- 
-- Utilise      : -
-- 
--| Modifications |------------------------------------------------------------
-- Ver   Qui   Date         Description
-- 0.0   EMI   17.05.2024   Version initial
--  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

-- Declarations

end console_sim ;

architecture struct of console_sim is
  
   -- Internal signal declarations
   signal clk_s  : Std_Logic := '1';  -- clock for the simulation
   constant PERIODE : time := 100 ns;
   
      component UC
    port(
        clk_i          : in  std_logic;
        rst_i          : in  std_logic;

        cap_l_i        : in  std_logic;
        cap_m_i        : in  std_logic;
        cap_r_i        : in  std_logic;

        mode_i         : in  std_logic;
        start_i        : in  std_logic;
        init_i         : in  std_logic;

        run_l_i        : in  std_logic;
        run_m_i        : in  std_logic;
        run_r_i        : in  std_logic;

        min_sp_i       : in  std_logic;
        max_sp_i       : in  std_logic;

        ml_pres_i      : in  std_logic;
        mm_pres_i      : in  std_logic;
        mr_pres_i      : in  std_logic;

        tour_in_null_i : in  std_logic;
        zero_tour_i    : in  std_logic;
        last_tour_i    : in  std_logic;
        mult_tour_i    : in  std_logic;
        det_tour_i     : in  std_logic;

        err_o          : out std_logic;

        incr_sp_o      : out std_logic;
        decr_sp_o      : out std_logic;
        init_sp_o      : out std_logic;

        dir_h_o        : out std_logic;
        dir_a_o        : out std_logic;

        dis_ml_o       : out std_logic;
        en_ml_o        : out std_logic;
        dis_mm_o       : out std_logic;
        en_mm_o        : out std_logic;
        dis_mr_o       : out std_logic;
        en_mr_o        : out std_logic;

        init_tour_o    : out std_logic;
        decr_tour_o    : out std_logic;

        init_enc_o     : out std_logic;
        incr_enc_o     : out std_logic
    );
   end component;
   for all : UC use entity work.UC;

   --signaux interne pour la simulation
   signal min_sp_s       : std_logic;
   signal max_sp_s       : std_logic;

   signal ml_pres_s      : std_logic;
   signal mm_pres_s      : std_logic;
   signal mr_pres_s      : std_logic;

   signal tour_in_null_s : std_logic;
   signal zero_tour_s    : std_logic;
   signal last_tour_s    : std_logic;
   signal mult_tour_s    : std_logic;
   signal det_tour_s     : std_logic;

begin

  -- Clock generator for the simulation ---------------------------------------
  process
  begin
    clk_s <= '0', '1' after PERIODE/4, '0' after 3 * PERIODE/4;
    wait for PERIODE;
  end process;

    -- Stimuli simulant les retours de l'UT via Val_A
  	min_sp_s       <= Val_A_sti(0);
  	max_sp_s       <= Val_A_sti(1);

  	ml_pres_s      <= Val_A_sti(2);
  	mm_pres_s      <= Val_A_sti(3);
  	mr_pres_s      <= Val_A_sti(4);

  	tour_in_null_s <= Val_A_sti(5);
  	zero_tour_s    <= Val_A_sti(6);
  	last_tour_s    <= Val_A_sti(7);
  	mult_tour_s    <= Val_A_sti(8);
  	det_tour_s     <= Val_A_sti(9);

  	Result_A_obs <= Val_A_sti;

  -- Instance port mappings.
  UUT : UC port map (
        clk_i          => clk_s,
        rst_i          => S15_sti,

        -- Entrées utilisateur / capteurs
        mode_i         => S0_sti,
        start_i        => S1_sti,
        init_i         => S2_sti,
        run_l_i        => S3_sti,
        run_m_i        => S4_sti,
        run_r_i        => S5_sti,

        cap_l_i        => S6_sti,
        cap_m_i        => S7_sti,
        cap_r_i        => S8_sti,

        -- Retours de l'UT
        min_sp_i       => min_sp_s,
        max_sp_i       => max_sp_s,
        ml_pres_i      => ml_pres_s,
        mm_pres_i      => mm_pres_s,
        mr_pres_i      => mr_pres_s,
        tour_in_null_i => tour_in_null_s,
        zero_tour_i    => zero_tour_s,
        last_tour_i    => last_tour_s,
        mult_tour_i    => mult_tour_s,
        det_tour_i     => det_tour_s,

        -- Sorties UC
        incr_sp_o      => L0_obs,
        decr_sp_o      => L1_obs,
        init_sp_o      => L2_obs,

        dir_h_o        => L3_obs,
        dir_a_o        => L4_obs,

        en_ml_o        => L5_obs,
        dis_ml_o       => L6_obs,
        en_mm_o        => L7_obs,
        dis_mm_o       => L8_obs,
        en_mr_o        => L9_obs,
        dis_mr_o       => L10_obs,

        init_tour_o    => L11_obs,
        decr_tour_o    => L12_obs,

        init_enc_o     => L13_obs,
        incr_enc_o     => L14_obs,

        err_o          => L15_obs
  );

end struct;
