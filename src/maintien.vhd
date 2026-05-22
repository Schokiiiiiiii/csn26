-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : Maintien.vhd
-- Auteur       : Etienne Messerli, le 05.05.2016
-- 
-- Description  : Detection d'un clic et double clic
--                Projet repris du labo Det_Clic_DblClic 2012
-- 
-- Utilise      : Labo SysLog2 2016
--| Modifications |------------------------------------------------------------
-- Ver   Date      Qui         Description
-- 2.0  27.11.2017 EMI    Descritpion sans machine d'etats
-- 2.1  20.11.2020 EMI    Ajout cst generique pour duree maintien
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maintien is
    generic (T_HOLD : natural range 1 to 1023 := 2
            );
    port (clock_i    : in  std_logic;
          reset_i    : in  std_logic;
          pulse_i    : in  std_logic;
          top_ms_i   : in  std_logic;
          p_hold_o   : out std_logic
          );
end maintien;


architecture comport of maintien is
    --Maintien de pulse pendant T_HOLD a la frequence de top_ms_i (soit 1KHz)
    constant DEMI_SEC               : natural := T_HOLD;

    signal cnt_fut, cnt_pres : unsigned(9 downto 0);  --10 bits, delai max 1023
    signal det_zero_s : std_logic;

begin

-- timer --------------------------------------------------
    cnt_fut <= to_unsigned(T_HOLD+1, cnt_pres'length)    -- T_HOLD+1 compense temps chargement counter
                           when pulse_i = '1'    else    -- init tempo
               cnt_pres    when det_zero_s = '1' else    -- maintien lorsque tempo termine
               cnt_pres -1 when top_ms_i = '1'   else    -- decompte si top_ms
               cnt_pres;                                 -- maintien

    timer : process(clock_i, reset_i)
    begin
        if reset_i = '1' then
            cnt_pres <= (others => '0');
        elsif rising_edge(clock_i) then
            cnt_pres <= cnt_fut;
        end if;
    end process;

    det_zero_s <= '1' when cnt_pres = 0 else
                  '0';
    p_hold_o   <= not det_zero_s;
    
end comport;
