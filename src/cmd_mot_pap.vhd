-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : cmd_mot_pap.vhd
--
-- Description  : Connexion UT/UC
--
-- Auteur       : Arnaut LEYRE
-- Date         : 12.06.2026
-- Version      : 3.0
--
-- Utilise dans : Labo moteur pas-à-pas
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur         Date               Description
-- 1.0       LFR            06.09.2022         First version.
-- 2.0       LFR            16.02.2024         2024 version for SysLog2 (MSS cplx)
-- 3.0       Arnaut LEYRE   12.06.2026         Connexion UT/UC
-------------------------------------------------------------------------------

--| Library |------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
-------------------------------------------------------------------------------

--| Entity |-------------------------------------------------------------------
entity cmd_mot_pap is
    generic(SIMULATION : boolean := false);
    port(
        clk_i       : in  std_logic;
        rst_i       : in  std_logic;
        cap_l_i     : in  std_logic;
        cap_m_i     : in  std_logic;
        cap_r_i     : in  std_logic;
        mode_i      : in  std_logic;
        start_i     : in  std_logic;
        init_i      : in  std_logic;
        nb_tour_i   : in  std_logic_vector(2 downto 0);
        run_l_i     : in  std_logic;
        run_m_i     : in  std_logic;
        run_r_i     : in  std_logic;
        en_l_o      : out std_logic;
        dir_l_o     : out std_logic;
        en_m_o      : out std_logic;
        dir_m_o     : out std_logic;
        en_r_o      : out std_logic;
        dir_r_o     : out std_logic;
        sel_speed_o : out std_logic_vector(1 downto 0);
        err_o       : out std_logic
    );
end cmd_mot_pap;
-------------------------------------------------------------------------------

--| Architecture |-------------------------------------------------------------
architecture struct of cmd_mot_pap is

    --| Internal signals |-----------------------------------------------------
    signal en_l_s                : std_logic;
    signal en_m_s                : std_logic;
    signal en_r_s                : std_logic;
    signal dir_l_s               : std_logic;
    signal dir_r_s               : std_logic;
    signal dir_m_s               : std_logic;
    signal err_s                 : std_logic;
    signal sel_speed_s           : std_logic_vector(1 downto 0);

    -- entrees
    signal cap_l_s     : std_logic;
    signal cap_m_s     : std_logic;
    signal cap_r_s     : std_logic;
    signal mode_s      : std_logic;
    signal start_s     : std_logic;
    signal init_s      : std_logic;
    signal nb_tour_s   : std_logic_vector(2 downto 0);
    signal run_l_s     : std_logic;
    signal run_m_s     : std_logic;
    signal run_r_s     : std_logic;

    --Commande UC
    signal incr_sp_s             : std_logic;
    signal decr_sp_s             : std_logic;
    signal init_sp_s             : std_logic;
    signal dir_h_s               : std_logic;
    signal dir_a_s               : std_logic;
    signal dis_ml_s              : std_logic;
    signal en_ml_s               : std_logic;
    signal dis_mm_s              : std_logic;
    signal en_mm_s               : std_logic;
    signal dis_mr_s              : std_logic;
    signal en_mr_s               : std_logic;
    signal init_tour_s           : std_logic;
    signal decr_tour_s           : std_logic;
    signal init_enc_s            : std_logic;
    signal incr_enc_s            : std_logic;

    --Signal tUT
    signal min_sp_s              : std_logic;
    signal max_sp_s              : std_logic;
    signal ml_pres_s             : std_logic;
    signal mm_pres_s             : std_logic;
    signal mr_pres_s             : std_logic;
    signal tour_in_null_s        : std_logic;
    signal zero_tour_s           : std_logic;
    signal last_tour_s           : std_logic;
    signal mult_tour_s           : std_logic;
    signal det_tour_s            : std_logic;



    ---------------------------------------------------------------------------

    --| Components |-----------------------------------------------------------
    component UC is
        port(
            clk_i                 : in  std_logic;
            rst_i                 : in  std_logic;

            -----------------
            --   Entries   --
            -----------------
            cap_l_i			: in  std_logic;
            cap_m_i			: in  std_logic;
            cap_r_i			: in  std_logic;
            mode_i			: in  std_logic;
            start_i			: in  std_logic;
            init_i			: in  std_logic;
            run_l_i			: in  std_logic;
            run_m_i			: in  std_logic;
            run_r_i			: in  std_logic;
        
            ------------
            --   UT   --
            ------------
            min_sp_i                : in  std_logic;
            max_sp_i              	: in  std_logic;
            ml_pres_i             	: in  std_logic;
            mm_pres_i             	: in  std_logic;
            mr_pres_i               : in  std_logic;
            tour_in_null_i        	: in  std_logic;
            zero_tour_i           	: in  std_logic;
            last_tour_i           	: in  std_logic;
            mult_tour_i           	: in  std_logic;
            det_tour_i            	: in  std_logic;
            
            -----------------
            --   OUTPUTS   --
            -----------------
            -- error
            err_o			: out std_logic;
            -- cmd
            incr_sp_o		: out std_logic;
            decr_sp_o		: out std_logic;
            init_sp_o		: out std_logic;
            dir_h_o			: out std_logic;
            dir_a_o			: out std_logic;
            dis_ml_o		: out std_logic;
            en_ml_o			: out std_logic;
            dis_mm_o		: out std_logic;
            en_mm_o			: out std_logic;
            dis_mr_o		: out std_logic;
            en_mr_o			: out std_logic;
            init_tour_o		: out std_logic;
            decr_tour_o		: out std_logic;
            init_enc_o		: out std_logic;
            incr_enc_o		: out std_logic
        );
    end component;
    for all : UC use entity work.UC(fsm);

    component UT is
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
            det_tour_o            : out std_logic;

            sel_speed_o           : out std_logic_vector(1 downto 0);
            --Contrainte : l'activation des moteurs est fait depuis l'UT
            --L'UT aura des elements memoires pour ces actions commandees par l'UC
            en_l_o                : out std_logic;
            en_m_o                : out std_logic;
            en_r_o                : out std_logic;
            dir_l_o               : out std_logic;
            dir_m_o               : out std_logic;
            dir_r_o               : out std_logic
        );
    end component;
    for all : UT use entity work.UT(behave);
    ---------------------------------------------------------------------------

begin
    --| Bloc de pre-traitement des entrees |------------------------------------
    --synchro entrees
    process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            cap_l_s     <= '0';
            cap_m_s     <= '0';
            cap_r_s     <= '0';
            mode_s      <= '0';
            start_s     <= '0';
            init_s      <= '0';
            nb_tour_s   <= (others =>'0');
            run_l_s     <= '0';
            run_m_s     <= '0';
            run_r_s     <= '0';
        elsif Rising_Edge(clk_i) then
            cap_l_s     <= cap_l_i  ;
            cap_m_s     <= cap_m_i  ;
            cap_r_s     <= cap_r_i  ;
            mode_s      <= mode_i   ;
            start_s     <= start_i  ;
            init_s      <= init_i   ;
            nb_tour_s   <= nb_tour_i;
            run_l_s     <= run_l_i  ;
            run_m_s     <= run_m_i  ;
            run_r_s     <= run_r_i  ;
        end if;
    end process;

    --| Components instanciation |---------------------------------------------
    UC_inst : UC
    port map(
        clk_i                 => clk_i,
        rst_i                 => rst_i,

        -----------------
        --   Entries   --
        -----------------
        cap_l_i			=> cap_l_s,
        cap_m_i			=> cap_m_s,
        cap_r_i			=> cap_r_s,
        mode_i			=> mode_s,
        start_i			=> start_s,
        init_i			=> init_s,
        run_l_i			=> run_l_s,
        run_m_i			=> run_m_s,
        run_r_i			=> run_r_s,

        ------------
        --   UT   --
        ------------
        min_sp_i                => min_sp_s,
        max_sp_i              	=> max_sp_s,
        ml_pres_i             	=> ml_pres_s,
        mm_pres_i             	=> mm_pres_s,
        mr_pres_i               => mr_pres_s,
        tour_in_null_i        	=> tour_in_null_s,
        zero_tour_i           	=> zero_tour_s,
        last_tour_i           	=> last_tour_s,
        mult_tour_i           	=> mult_tour_s,
        det_tour_i            	=> det_tour_s,

        -----------------
        --   OUTPUTS   --
        -----------------
        -- error
        err_o			=> err_s,
        -- cmd
        incr_sp_o		=> incr_sp_s,
        decr_sp_o		=> decr_sp_s,
        init_sp_o		=> init_sp_s,
        dir_h_o			=> dir_h_s,
        dir_a_o			=> dir_a_s,
        dis_ml_o		=> dis_ml_s,
        en_ml_o			=> en_ml_s,
        dis_mm_o		=> dis_mm_s,
        en_mm_o			=> en_mm_s,
        dis_mr_o		=> dis_mr_s,
        en_mr_o			=> en_mr_s,
        init_tour_o		=> init_tour_s,
        decr_tour_o		=> decr_tour_s,
        init_enc_o		=> init_enc_s,
        incr_enc_o		=> incr_enc_s
    );

    UT_inst : UT
    port map(
        clk_i                 => clk_i,
        rst_i                 => rst_i,
        nb_tour_i             => nb_tour_s,

        --Commande from UC
        incr_sp_i             => incr_sp_s,
        decr_sp_i             => decr_sp_s,
        init_sp_i             => init_sp_s,
        dir_h_i               => dir_h_s,
        dir_a_i               => dir_a_s,
        dis_ml_i              => dis_ml_s,
        en_ml_i               => en_ml_s,
        dis_mm_i              => dis_mm_s,
        en_mm_i               => en_mm_s,
        dis_mr_i              => dis_mr_s,
        en_mr_i               => en_mr_s,
        init_tour_i           => init_tour_s,
        decr_tour_i           => decr_tour_s,
        init_enc_i            => init_enc_s,
        incr_enc_i            => incr_enc_s,

        --Signal to UC
        min_sp_o              => min_sp_s,
        max_sp_o              => max_sp_s,
        ml_pres_o             => ml_pres_s,
        mm_pres_o             => mm_pres_s,
        mr_pres_o             => mr_pres_s,
        tour_in_null_o        => tour_in_null_s,
        zero_tour_o           => zero_tour_s,
        last_tour_o           => last_tour_s,
        mult_tour_o           => mult_tour_s,
        det_tour_o            => det_tour_s,

        sel_speed_o           => sel_speed_s,
        en_l_o                => en_l_s,
        en_m_o                => en_m_s,
        en_r_o                => en_r_s,
        dir_l_o               => dir_l_s,
        dir_r_o               => dir_r_s,
        dir_m_o               => dir_m_s
    );

     --| Output affectation |---------------------------------------------------
    en_l_o      <= en_l_s;
    en_m_o      <= en_m_s;
    en_r_o      <= en_r_s;
    dir_l_o     <= dir_l_s;
    dir_r_o     <= dir_r_s;
    dir_m_o     <= dir_m_s;
    sel_speed_o <= sel_speed_s;
    err_o       <= err_s;

end struct;
