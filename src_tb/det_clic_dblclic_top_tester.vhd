-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : det_clic_dblclic_top_tb.vhd
-- Auteur       : Etienne Messerli, le 05.05.2016
-- 
-- Description  : Fichier tester pour la verifcation automatique 
--                Detection d'un clic et double clic
--                Projet repris du labo Det_Clic_DblClic 2012
-- 
-- Utilise      : Labo SysLog2 2016
--| Modifications |------------------------------------------------------------
-- Ver  Date        Qui  Description
-- 2.0  05.05.2016  EMI  Adaptation pour clk a 1MHz et ajout signal top_ms_sti
-- 3.0  08.12.2017  MIM  Adaptation au cahier des charges fourni aux étudiants
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.MATH_REAL.ALL;

library STD;
use STD.textio.all;

entity Det_Clic_DblClic_top_tester is
    port (
        Clic_obs        : in  std_logic;
        DblClic_obs     : in  std_logic;
        LongClic_obs    : in  std_logic;
        LongDblClic_obs : in  std_logic;
        top_ms_sti      : out std_logic;
        Button_sti      : out std_logic;
        Clock_sti       : out std_logic;
        nReset_sti      : out std_logic
        );
end Det_Clic_DblClic_top_tester;

architecture tester of Det_Clic_DblClic_top_tester is
-- taille du compteur
    constant COUNTERSIZE : integer := 32;

    -- definition de la période d'horloge
--  constant CLK_BASE: time := 1 ms;     -- 1 miliseconde  a supprimer *************
    constant CLK_BASE               : time    := 1 us;   -- 1 MHz
    constant CLK_FREQUENCY          : real    := 0.001;  -- fréquence à 1KHz
    constant RAP_CLKBASE_TOPMS_real : real    := 1.0/CLK_FREQUENCY;
    constant RAP_CLKBASE_TOPMS      : natural := natural(RAP_CLKBASE_TOPMS_real);
    constant CLK_TOP_MS             : time    := CLK_BASE/CLK_FREQUENCY;
    signal sim_end                  : boolean := false;
    signal start_clock_s            : boolean := true;


    --constant MINDOWN: integer:=200; -- millisecondes
    --constant MAXUP: integer:=100; -- millisecondes
    --constant MAXTIMEDOWN: integer:=integer(real(MINDOWN*1000)*CLK_FREQUENCY);
    --constant MAXTIMEUP: integer:=integer(real(MAXUP*1000)*CLK_FREQUENCY);

    -- nombre maximal de coups d'horloge où le bouton doit rester enfoncé
    constant MAXTIMEDOWN : integer := 300;
    -- nombre maximal de coups d'horloge où le bouton doit rester relâché pour 
    -- détecter un double-clic
    constant MAXTIMEUP   : integer := 200;
    -- Durée du signal Longclick ou Longdblclick
    constant LONGTIME    : integer := 500;  --500 donne une erreur

    -- registre contenant le nombre maximal de coups d'horloge où le bouton
    -- doit rester enfoncé
    constant reg_maxdown : unsigned(COUNTERSIZE-1 downto 0) := To_Unsigned(MAXTIMEDOWN, COUNTERSIZE);
    -- registre contenant le nombre maximal de coups d'horloge où le bouton
    -- doit rester relâché pour détected un double-clic
    constant reg_maxup   : unsigned(COUNTERSIZE-1 downto 0) := To_unsigned(MAXTIMEUP, COUNTERSIZE);

    -- constantes définissant l'activation du bouton
    constant BUTTONDOWN : std_logic := '1';
    constant BUTTONUP   : std_logic := not BUTTONDOWN;

--  -- composant à tester
--  component ClickDetector
--  generic(COUNTERSIZE:integer:=32;
--      BUTTONDOWN: std_logic:='1');
--  port (   clk:     in std_logic;
--      rst:     in std_logic;
--      button:   in std_logic;
--      maxtimedown:in std_logic_vector(COUNTERSIZE-1 downto 0);
--      maxtimeup:  in std_logic_vector(COUNTERSIZE-1 downto 0);
--      click:     out std_logic;
--      dblclick:   out std_logic);
--  end component;

    -- signaux d'entrée/sortie du composant à tester
    signal clk              : std_logic;  -- horloge globale
    signal rst              : std_logic;  -- reset global
    signal button           : std_logic;  -- indique si le bouton est enfoncé ou non
    signal top_ms           : std_logic;  -- top a F= 1KHz
    signal click            : std_logic;  -- détection d'un clic souris
    signal Longclick        : std_logic;  -- Signal de 500ms lors de la détection d'un clic souris
    signal dblclick         : std_logic;  -- détection d'un double-clic souris
    signal Longdblclick     : std_logic;  -- Signal de 500ms lors de la détection d'un double-clic souris
    -- Signaux pour maintien des valeurs afin d'accélerer le processus de simulation
    signal clic_check_s     : std_logic;  -- Maintient le signal de clic_o jusqu'au
    -- prochain coup de top_ms
    signal dbl_clic_check_s : std_logic;  -- Maintient le signal de dbl_clic_o
    -- jusqu'au prochain coup de top_ms

begin

--************************************************************
-- adaptation banc de test
    -- MIM : modify this to handle data to synchronize on top_ms
    -- click        <= Clic_obs;
    -- dblclick     <= DblClic_obs;
    click        <= clic_check_s;
    dblclick     <= dbl_clic_check_s;
    Longclick    <= LongClic_obs;
    Longdblclick <= LongDblClic_obs;
    top_ms_sti   <= top_ms;
    Button_sti   <= button;
    Clock_sti    <= clk;
    nReset_sti   <= not rst;
--************************************************************

--  -- instanciation du composant à tester
--  detector: clickdetector
--  generic map(BUTTONDOWN  =>  BUTTONDOWN)
--  port map(
--        clk=>clk,
--        rst=>rst,
--        button=>button,
--        maxtimedown =>  Std_Logic_Vector(reg_maxdown),
--        maxtimeup  =>  Std_Logic_Vector(reg_maxup),
--        click=>click,
--        dblclick=>dblclick);

    -- génération de l'horloge a 1MHz
    clock : process
    begin
        if(start_clock_s) then  -- retarde le début de la génération de l'horloge
            clk           <= '1';
            start_clock_s <= false;
            wait for CLK_BASE;
        end if;
        clk <= '1';
        wait for CLK_BASE/2;
        clk <= '0';
        wait for CLK_BASE/2;
        if (sim_end) then
            wait;
        end if;
    end process;

    -- génération du reset
    reset : process
    begin
        rst <= '1';
        wait for 3 * CLK_BASE;
        rst <= '0';
        wait;
    end process;

    -- génération de signal top_ms_sti a 1KHz
    topms : process(clk, rst)
        variable delai_v : natural;
    begin
        if rst = '1' then
            top_ms  <= '0';
            delai_v := 1;
        elsif rising_edge(clk) then     -- action synchrone
            if delai_v = RAP_CLKBASE_TOPMS then
                top_ms  <= '1';
                delai_v := 1;
            else
                top_ms  <= '0';
                delai_v := delai_v + 1;
            end if;
        end if;
    end process;

    -- Maintien de clic_o
    clic_check_maintien : process
    begin
        clic_check_s <= '0';
        wait until rising_edge(Clic_obs);
        clic_check_s <= '1';
        wait until falling_edge(top_ms);
    end process;

    -- Maintien de dbl_clic_o
    dbl_clic_check_maintien : process
    begin
        dbl_clic_check_s <= '0';
        wait until rising_edge(DblClic_obs);
        dbl_clic_check_s <= '1';
        wait until falling_edge(top_ms);
    end process;

    -- génération du signal correspondant au bouton
    bouton : process
        variable sim_text_v : line;
    begin
        -- par défaut, le bouton n'est pas enfoncé
        button <= BUTTONUP;
        wait for 10*CLK_TOP_MS;

        --placer la simulation au milieu de la preriode de top_ms
        wait until rising_edge(top_ms);
        wait for CLK_TOP_MS/2;

        -- génération d'un clic
        report "génération d'un clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN-3)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+3)*CLK_TOP_MS;

        -- génération d'un double-clic
        report "génération d'un double-clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN-3)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP-3)*CLK_TOP_MS;
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN-3)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+3)*CLK_TOP_MS;

        --placer la simulation au milieu de la preriode de top_ms
        wait until rising_edge(top_ms);
        wait for CLK_TOP_MS/2;

        -- génération d'un clic
        report "génération d'un clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN-1)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+10)*CLK_TOP_MS;  -- en cas de longclick décalé


        -- génération d'un clic
        report "génération d'un clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+1)*CLK_TOP_MS;
        wait for 10*CLK_TOP_MS;

        -- pas de détection clic
        report "Pas de détection de clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN+1)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+1)*CLK_TOP_MS;

        -- pas de détection clic
        report "Pas de détection de clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN+MAXTIMEDOWN/2)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+3)*CLK_TOP_MS;

        -- génération d'un double-clic
        report "génération d'un double-clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP-2)*CLK_TOP_MS;
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+2)*CLK_TOP_MS;

        -- pas de détection de double-clic
        report "Pas de détection de double-clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP-1)*CLK_TOP_MS;
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN+1)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+2)*CLK_TOP_MS;

        -- génération d'un double-clic
        report "génération d'un double-clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP-2)*CLK_TOP_MS;
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+2)*CLK_TOP_MS;

        -- génération d'un clic
        report "génération d'un clic";
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+1)*CLK_TOP_MS;

        -- génération d'un double-clic
        report "génération d'un double-clic";
        button <= BUTTONUP;
        wait for CLK_TOP_MS;
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP-2)*CLK_TOP_MS;
        button <= BUTTONDOWN;
        wait for (MAXTIMEDOWN)*CLK_TOP_MS;
        button <= BUTTONUP;
        wait for (MAXTIMEUP+2)*CLK_TOP_MS;

        -- fin de la simulation    
        write(sim_text_v, now);
        write(sim_text_v, string'("  >> fin de la simulation"));
        write(sim_text_v, LF & "        " & "       >> ");
        write(sim_text_v, string'("Vérifiez dans le log si il y des erreurs!"));
        writeline(output, sim_text_v);

        button  <= BUTTONUP;
        sim_end <= true;
        wait;
    end process;

-- assertions permettant de vérifier que la détection du clic fonctionne
-- --modifer assertion: psl default clock is rising_edge(clk);  EMI 2016 mai
-- psl default clock is rising_edge(top_ms);

-- psl property pclick is always ({(not button);button[*1 to MAXTIMEDOWN];
--                   (not button)[*MAXTIMEUP+1]}|=>{[*0 to 3];click}) abort dblclick;

-- psl assert pclick report "Erreur lors d'un clic, code de l'erreur: pc0";
-- psl property pclick1 is always ({(not button);button[*1 to MAXTIMEDOWN];
--                  (not button)[*0 to MAXTIMEUP]}
--                  |=>{[*0 to 3];not click}) abort dblclick='1';
-- psl assert pclick1 report "Erreur lors d'un clic, code de l'erreur: pc1";
-- psl property pclick2 is always ({(not button);button[*MAXTIMEDOWN+1 to inf];
--                  (not button)[*MAXTIMEUP+1]}|=>{[*0 to 3];not click});
-- psl assert pclick2 report "Erreur lors d'un clic, code de l'erreur: pc2";
-- psl property pclick4 is never ({(not button)[*MAXTIMEUP+3 to inf];click});
-- psl assert pclick4 report "Erreur détection d'un clic, code de l'erreur: pc4";
-- psl property pclick5 is never ({button;(not button)[*1 to MAXTIMEUP];
--                   click});
-- psl assert pclick5 report "Erreur détection d'un clic, code de l'erreur: pc5";
-- psl property pclick6 is never ({button;click});
-- psl assert pclick6 report "Erreur détection d'un clic, code de l'erreur: pc6";

-- assertions permettant de vérifier le signal Longclick lors de la détection du clic
-- psl property plgclick is always {click}|=>{[*0 to 3];Longclick[*LONGTIME];(not Longclick)};
-- psl assert plgclick report "Erreur lors Longclick, code de l'erreur: plgc0";

-- assertions permettant de vérifier le signal Longdblclick lors de la détection du double-clic
-- psl property plgdblclick is always {dblclick}|=>{[*0 to 3];Longdblclick[*LONGTIME];(not Longdblclick)};
-- psl assert plgdblclick report "Erreur lors Longdblclick, code de l'erreur: plgdblc0";

-- ************  Cette assertion genere des erreurs  ************************
-- assertions permettant de vérifier que la détection du double-clic fonctionne
-- psl property pdblclick is always ({(not button);button[*1 to MAXTIMEDOWN];
--                    (not button)[*1 to MAXTIMEUP];
--                    button[*1 to MAXTIMEDOWN];
--                    (not button)}|->{[*0 to 3];dblclick});
-- psl assert pdblclick report "Erreur lors d'un double-clic, code de l'erreur: pdblc0";


-- psl property pdblclick1 is always ({(not button);
--                     button[*MAXTIMEDOWN+1 to inf];
--                     (not button)}|=>{[*0 to 3];not dblclick});
-- psl assert pdblclick1 report "Erreur lors d'un double-clic, code de l'erreur: pdblc1";
-- psl property pdblclick2 is always ({(not button);button[*1 to MAXTIMEDOWN];
--                     (not button)[*MAXTIMEUP+1 to inf];
--                     button[*1 to MAXTIMEDOWN];
--                     (not button)}|=>{[*0 to 3];not dblclick});
-- psl assert pdblclick2 report "Erreur lors d'un double-clic, code de l'erreur: pdblc2";
-- psl property pdblclick3 is always ({(not button);
--                     button[*MAXTIMEDOWN+1 to inf];
--                     (not button)[*1 to MAXTIMEUP];
--                     button[*1 to MAXTIMEDOWN];
--                     (not button)}|=>{[*0 to 3];not dblclick});
-- psl assert pdblclick3 report "Erreur lors d'un double-clic, code de l'erreur: pdblc3";

-- psl property pdblclick5 is never({not button;not button;not button;dblclick});
-- psl assert pdblclick5 report "Erreur double-clic détecté, code de l'erreur: pdblc4";

end tester;


