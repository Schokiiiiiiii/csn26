-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : det_clic_dblclic_top_tb.vhd
-- Auteur       : Etienne Messerli, le 05.05.2016
-- 
-- Description  : Fichier tb structurelle pour le labo 
--                Detection d'un clic et double clic
--                Projet repris du labo Det_Clic_DblClic 2012
-- 
-- Utilise      : Labo SysLog2 2016
--| Modifications |------------------------------------------------------------
-- Ver   Date      Qui         Description
-- 
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.ALL;
    use ieee.numeric_std.ALL;

library work;
    use work.det_clic_dblclic_pkg.all;

entity det_clic_dblclic_top_tb is

end det_clic_dblclic_top_tb;

architecture struct of det_clic_dblclic_top_tb is

    -- Architecture declarations

    -- Internal signal declarations
    signal Button_sti      : std_logic;
    signal top_ms_sti      : std_logic;   
    signal Clic_obs        : std_logic;
    signal Clock_sti       : std_logic;
    signal DblClic_obs     : std_logic;
    signal LongClic_obs    : std_logic;
    signal LongDblClic_obs : std_logic;
    signal nReset_sti      : std_logic;
    
    
   -- Component Declarations
    component det_clic_dblclic_top
    generic (T1_g      : natural := 1;
             T2_g      : natural := 1;
             T_HOLD    : natural range 1 to 1023 := 2
             );
    port(Clock_i       : in     std_logic;  --horloge systeme 1MHz
         nReset_i      : in     std_logic;  --reset asynchrone
         button_i      : in     std_logic;
         top_ms_i      : in     std_logic;
         clic_o        : out    std_logic;
         dbl_clic_o    : out    std_logic;
         clic_lg_o     : out    std_logic;
         dbl_clic_lg_o : out    std_logic
    );
    end component;
    for all : det_clic_dblclic_top use entity work.det_clic_dblclic_top;
    
    component det_clic_dblclic_top_tester
    port (
        Clic_obs        : in     std_logic ;
        DblClic_obs     : in     std_logic ;
        LongClic_obs    : in     std_logic ;
        LongDblClic_obs : in     std_logic ;
        top_ms_sti      : out    std_logic ;
        Button_sti      : out    std_logic ;
        Clock_sti       : out    std_logic ;
        nReset_sti      : out    std_logic 
    );
    end component;
    for all : det_clic_dblclic_top_tester use entity work.det_clic_dblclic_top_tester;

begin

    -- Instance port mappings.
    UUT : det_clic_dblclic_top
        generic map (T1_g       => T1_c,
                     T2_g       => T2_c,
                     T_HOLD     => T_HOLD_c )
        port map (Clock_i        => Clock_sti,
                  nReset_i       => nReset_sti,
                  button_i       => Button_sti,
                  top_ms_i       => top_ms_sti,
                  clic_o         => Clic_obs,
                  dbl_clic_o     => DblClic_obs,
                  clic_lg_o      => LongClic_obs,
                  dbl_clic_lg_o  => LongDblClic_obs
        );
    tester : det_clic_dblclic_top_tester
        port map (
            Clic_obs        => Clic_obs,
            DblClic_obs     => DblClic_obs,
            LongClic_obs    => LongClic_obs,
            LongDblClic_obs => LongDblClic_obs,
            top_ms_sti      => top_ms_sti,
            Button_sti      => Button_sti,
            Clock_sti       => Clock_sti,
            nReset_sti      => nReset_sti
        );

end struct;
