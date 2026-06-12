-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : UT.vhd
--
-- Description  : UT pour la commande des 3 moteurs pas-a-pas
--
-- Auteur       : ....
-- Date         : 21.05.2024
-- Version      : 1.0
--
-- Utilise dans : Labo moteur pas-à-pas (MSS cplx)
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
--
--
-------------------------------------------------------------------------------

--| Library |------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity UT is
    port(
        clk_i                 : in  std_logic;
        rst_i                 : in  std_logic;
        nb_tour_i             : in  std_logic_vector(2 downto 0);

        --Commande from UC
        incr_sp_i             : in  std_logic;
        decr_sp_i             : in  std_logic;
        init_sp_i             : in  std_logic;
        dir_h_i               : in  std_logic;
        dir_a_i               : in  std_logic;
        dis_ml_i              : in  std_logic;
        en_ml_i               : in  std_logic;
        dis_mm_i              : in  std_logic;
        en_mm_i               : in  std_logic;
        dis_mr_i              : in  std_logic;
        en_mr_i               : in  std_logic;
        init_tour_i           : in  std_logic;
        decr_tour_i           : in  std_logic;
        init_enc_i            : in  std_logic;
        incr_enc_i            : in  std_logic;

        --Contrainte : l'activation des moteurs est fait depuis l'UT
        --L'UT aura des elements memoires pour ces actions commandees par l'UC
        en_l_o                : out std_logic;
        en_m_o                : out std_logic;
        en_r_o                : out std_logic;
        dir_l_o               : out std_logic;
        dir_m_o               : out std_logic;
        dir_r_o               : out std_logic;

        sel_speed_o           : out std_logic_vector(1 downto 0);

        --Signal to UC
        min_sp_o              : out std_logic;
        max_sp_o              : out std_logic;
        ml_pres_o             : out std_logic;
        mm_pres_o             : out std_logic;
        mr_pres_o             : out std_logic;
        tour_in_null_o        : out std_logic;
        zero_tour_o           : out std_logic;
        last_tour_o           : out std_logic;
        mult_tour_o           : out std_logic;
        det_tour_o            : out std_logic
    );
end UT;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture behave of UT is

    --| Constantes |-----------------------------------------------------------

    constant MAX_SPEED        : unsigned(1 downto 0) := "11";
    constant MIN_SPEED        : unsigned(1 downto 0) := "00";
    constant ENCOCHE_PER_TOUR : unsigned(2 downto 0) := "101";
    constant LAST_TOUR        : unsigned(2 downto 0) := "001";

    --| Signals |--------------------------------------------------------------

    signal sp_pres_s, sp_fut_s : unsigned(1 downto 0);
    signal tour_pres_s, tour_fut_s : unsigned(2 downto 0);
    signal enc_pres_s, enc_fut_s : unsigned(2 downto 0);
    signal ml_pres_s, ml_fut_s : std_logic;
    signal mm_pres_s, mm_fut_s : std_logic;
    signal mr_pres_s, mr_fut_s : std_logic;
    signal dir_pres_s, dir_fut_s : std_logic;

    --| Components |-----------------------------------------------------------

    -- to be completed


begin

    -- early check
    tour_in_null_o <= '1' when tour_pres_s = "000" else '0';

    ---------------
    --   Speed   --
    ---------------

    -- decodeur etats futur
    sp_fut_s <= (others =>'0')  when init_sp_i = '1' else
                sp_fut_s + 1    when incr_sp_i = '1' else
                sp_fut_s - 1    when decr_sp_i = '1' else
                sp_fut_s;

    -- registre interne
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            sp_pres_s <= (others =>'0');
        elsif Rising_Edge(clk_i) then
            sp_pres_s <= sp_fut_s;
        end if;
    end process;

    -- decodeur sortie
    min_sp_o <= '1' when sp_pres_s = MIN_SPEED else '0';
    max_sp_o <= '1' when sp_pres_s = MAX_SPEED else '0';
    sel_speed_o <= std_logic_vector(sp_pres_s);

    --------------
    --   Tour   --
    --------------

    -- decodeur etats futur
    tour_fut_s <= (others =>'0')    when init_tour_i = '1' else
                  tour_fut_s - 1    when decr_tour_i = '1' else
                  tour_fut_s;

    -- registre interne
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            tour_pres_s <= (others =>'0');
        elsif Rising_Edge(clk_i) then
            tour_pres_s <= tour_fut_s;
        end if;
    end process;

    -- decodeur sortie
    zero_tour_o <= '1' when tour_pres_s < LAST_TOUR else '0';
    last_tour_o <= '1' when tour_pres_s = LAST_TOUR else '0';
    mult_tour_o <= '1' when tour_pres_S > LAST_TOUR else '0';

    -----------------
    --   Encoche   --
    -----------------

    -- decodeur etats futur
    enc_fut_s <= (others =>'0')    when init_enc_i = '1' else
                  enc_fut_s - 1    when incr_enc_i = '1' else
                  enc_fut_s;

    -- registre interne
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            enc_pres_s <= (others =>'0');
        elsif Rising_Edge(clk_i) then
            enc_pres_s <= enc_fut_s;
        end if;
    end process;

    -- decodeur sortie
    det_tour_o <= '1' when enc_pres_s = ENCOCHE_PER_TOUR else '0';
    
    ------------------
    --   Direction  --
    ------------------

    -- decodeur etats futur
    dir_fut_s <= '0' when dir_a_i = '1' else
                 '1' when dir_h_i = '1' else
                 dir_fut_s;
    
    -- registre interne
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            dir_fut_s <= '0';
        elsif Rising_Edge(clk_i) then
            dir_pres_s <= dir_fut_s;
        end if;
    end process;

    --------------------
    --   Moteur Left  --
    --------------------

    -- decodeur etats futur
    ml_fut_s <= '0' when dis_ml_i = '1' else
                '1' when en_ml_i = '1' else
                ml_fut_s;
    
    -- registre interne
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            ml_fut_s <= '0';
        elsif Rising_Edge(clk_i) then
            ml_pres_s <= ml_fut_s;
        end if;
    end process;

    -- decodeur sortie
    ml_pres_o <= ml_pres_s;
    en_l_o <= ml_pres_s;
    dir_l_o <= dir_pres_s;

    ----------------------
    --   Moteur Milieu  --
    ----------------------

    -- decodeur etats futur
    mm_fut_s <= '0' when dis_mm_i = '1' else
                '1' when en_mm_i = '1' else
                mm_fut_s;
    
    -- registre interne
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            mm_fut_s <= '0';
        elsif Rising_Edge(clk_i) then
            mm_pres_s <= mm_fut_s;
        end if;
    end process;

    -- decodeur sortie
    mm_pres_o <= mm_pres_s;
    en_m_o <= mm_pres_s;
    dir_m_o <= dir_pres_s;

    ----------------------
    --   Moteur Right  --
    ----------------------

    -- decodeur etats futur
    mr_fut_s <= '0' when dis_mr_i = '1' else
                '1' when en_mr_i = '1' else
                mr_fut_s;
    
    -- registre interne
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            mr_fut_s <= '0';
        elsif Rising_Edge(clk_i) then
            mr_pres_s <= mr_fut_s;
        end if;
    end process;

    -- decodeur sortie
    mr_pres_o <= mr_pres_s;
    en_r_o <= mr_pres_s;
    dir_r_o <= dir_pres_s;


end behave;
