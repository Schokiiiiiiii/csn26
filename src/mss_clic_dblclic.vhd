-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : mss_clic_dblclic.vhd
-- Auteur       : Fabien Léger, 22.05.2026
-- 
-- Description  : Single and double click detection
--                Project taken from Det_Clic_DblClic lab 2012
-- 
-- Utilise      : SysLog2 lab 2016
--| Modifications |------------------------------------------------------------
-- Ver   Date      Who         Description
-- 1.0   22.05.26  FLR         Initial version
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mss_clic_dblclic is
    port (
        clock_i        : in  std_logic;
        reset_i        : in  std_logic;
        trigger1_i     : in  std_logic;
        trigger2_i     : in  std_logic;
        bouton_i       : in  std_logic;
        start_o        : out std_logic;
	simple_click_o : out std_logic;
	double_click_o : out std_logic
        );
end mss_clic_dblclic;

architecture comport of mss_clic_dblclic is

  ----------
  -- TODO --
  ----------


begin


  ----------
  -- TODO --
  ----------


end comport;
