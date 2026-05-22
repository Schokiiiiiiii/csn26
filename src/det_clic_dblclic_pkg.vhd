--------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : det_clic_dblclic_pkg.vhd
--
-- Description  : package pour le détecteur de clic/double clic
-- 
-- Auteur       : Sébastien Masle
-- Date         : 19.11.2020
-- Version      : 0.0
-- 
--| Modifications |------------------------------------------------------------
-- Version  Date   Auteur     Description
--
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;

package det_clic_dblclic_pkg is
    
    --Duree d'attente de 0,3 sec => compter 300 périodes a 1KHz
    constant T1_c : natural := 300;
    --Duree d'attente de 0,2 sec => compter 200 périodes a 1KHz
    constant T2_c : natural := 200;
    --Duree de maintien de 0.5 sec => compter 500 périodes a 1KHz
    constant T_HOLD_c : natural := 500;
    
    --Duree d'attente de 0,3 sec => compter 300 périodes a 1KHz 
    --    => divisé par 50 pour la simulation
    constant T1_sim_c : natural := 6;
    --Duree d'attente de 0,2 sec => compter 200 périodes a 1KHz 
    --    => divisé par 50 pour la simulation
    constant T2_sim_c : natural := 4;
    --Duree de maintien de 0.5 sec => compter 500 périodes a 1KHz
    --    => divisé par 50 pour la simulation
    constant T_HOLD_sim_c : natural := 10;

end det_clic_dblclic_pkg;
