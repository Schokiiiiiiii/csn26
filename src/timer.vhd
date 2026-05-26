-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : timer.vhd
-- Auteur       : Etienne Messerli, le 05.05.2016
-- 
-- Description  : Detection d'un clic et double clic
--                Projet repris du labo Det_Clic_DblClic 2012
-- 
-- Utilise      : Labo SysLog2 2016
--| Modifications |------------------------------------------------------------
-- Ver   Date      Qui         Description
-- 1.0   05.05.16  EMI         version initiale
-- 1.1   19.11.20  SMS         remplacement des constantes par des generiques
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    generic (
        T1_g : natural range 1 to 1023 := 300;
        T2_g : natural range 1 to 1023 := 200 );	
    port (
        clock_i    : in  std_logic;
        reset_i    : in  std_logic;
        start_i    : in  std_logic;
        top_ms_i   : in  std_logic;
        trigger1_o : out std_logic;
        trigger2_o : out std_logic
        );
end timer;

architecture comport of timer is
	
  signal reg_pres_s 	: unsigned(9 downto 0);
  signal reg_fut_s 	: unsigned(9 downto 0);


begin
	
  reg_fut_s <= (others => '0') when start_i = '1' else -- load 0
	       reg_pres_s when reg_pres_s >= 1023 else -- hold (max)
	       reg_pres_s + 1 when top_ms_i = '1' else -- increment
	       reg_pres_s;			       -- hold
	
  --Description of synchronous register
  Mem: process (clock_i, reset_i)
  begin
    if (reset_i = '1') then
      reg_pres_s <= (others => '0');
    elsif rising_edge(clock_i) then
      reg_pres_s <= reg_fut_s;
    end if;
  end process;
	
  -- determine the outputs
  trigger1_o <= '1' when reg_pres_s > T1_g else
                '0';
  trigger2_o <= '1' when reg_pres_s > T2_g else
                '0';

end comport;
