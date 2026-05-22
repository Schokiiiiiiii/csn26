-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : det_clic_dblclic_top.vhd
-- Auteur       : Etienne Messerli, le 05.05.2016
-- 
-- Description  : Detection d'un clic et double clic
--                Projet repris du labo Det_Clic_DblClic 2012
-- 
-- Utilise      : Labo SysLog2 2016
--| Modifications |------------------------------------------------------------
-- Ver   Date        Qui         Description
-- 1.0   20.11.2020  EMI   Ajout generique pour timer et maintien
-- 
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity det_clic_dblclic_top is
    generic (T1_g      : natural range 1 to 1023 := 4;
             T2_g      : natural range 1 to 1023 := 6;
             T_HOLD    : natural range 1 to 1023 := 2
             );
    port(clock_i       : in  std_logic;  --horloge systeme 1MHz
         nReset_i      : in  std_logic;  --reset asynchrone
         button_i      : in  std_logic;
         top_ms_i      : in  std_logic;
         clic_o        : out std_logic;
         dbl_clic_o    : out std_logic;
         clic_lg_o     : out std_logic;
         dbl_clic_lg_o : out std_logic
         );
end det_clic_dblclic_top;

architecture struct of det_clic_dblclic_top is

  -- Internal signal declarations
  signal reset_s       : std_logic;

    ----------
    -- TODO --
    ----------

  
   -- Component declarations
   
   
    ----------
    -- TODO --
    ----------
   
   
   

    component maintien
        generic (T_HOLD : natural range 1 to 1023 := 2
                );
        port (clock_i    : in  std_logic;
              reset_i    : in  std_logic;
              pulse_i    : in  std_logic;
              top_ms_i   : in  std_logic;
              p_hold_o   : out std_logic
              );
    end component;
    for all : maintien use entity work.maintien;


begin


    ----------
    -- TODO --
    ----------



end struct;
