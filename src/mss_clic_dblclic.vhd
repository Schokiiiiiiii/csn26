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

architecture state_machine of mss_clic_dblclic is

  signal state_pres_s(2 downto 0);
  signal state_fut_s(2 downto 0);

  constant INIT       : std_logic_vector(2 downto 0) := "000";
  constant IDLE       : std_logic_vector(2 downto 0) := "001";
  constant C1_PRESSED : std_logic_vector(2 downto 0) := "010";
  constant C1_VALID   : std_logic_vector(2 downto 0) := "011";
  constant C1_SINGLE  : std_logic_vector(2 downto 0) := "100";
  constant C2_PRESSED : std_logic_vector(2 downto 0) := "101";
  constant C2_DOUBLE  : std_logic_vector(2 downto 0) := "110";

begin

  -- processing future state
  Fut: process (trigger1_i, trigger2_i, bouton_i, state_pres_s)
  begin
  
    -- default value state
    state_fut_s <= INIT;
    -- default value outputs
    start_o <= '0';
    simple_click_o <= '0';
    double_click_o <= '0';
    
    case state_pres_s is
    
      when INIT =>
        if (bouton_i = '0') then
          state_fut_s <= IDLE;
        else
          state_fut_s <= INIT;
        end if;
        
      when IDLE => 
        if (bouton_i = '1') then
          state_fut_s <= C1_PRESSED;
        else 
          state_fut_s <= IDLE;
        end if;
        
      when C1_PRESSED =>
        start_o <= '1';
        if (trigger1_i = '0' and bouton_i = '0') then
          state_fut_s <= C1_VALID
        elsif (trigger1_i = '0' and bouton_i = '1') then
          state_fut_s <= C1_PRESSED;
        elsif (trigger1_i = '1' and bouton_i = '0') then
          state_fut_s <= IDLE;
        else
          state_fut_s <= INIT;
        end if;
        
      when C1_VALID =>
        start_o <= '1';
        if (trigger2_i = '0' and bouton_i = '1') then
          state_fut_s <= C2_PRESSED;
        elsif (trigger2_i = '1') then
          state_fut_s <= C1_SINGLE;
        else
          state_fut_s <= C1_VALID;
        end if;
        
      when C1_SINGLE =>
        simple_click_o <= '1';
        if (bouton_i = '1') then
          state_fut_s <= C1_PRESSED;
        else
          state_fut_s <= IDLE;
        end if;
        
      when C2_PRESSED =>
        start_o <= '1';
        if (trigger1_i = '0' and bouton_i = '0') then
          state_fut_s <= C2_DOUBLE;
        elsif (trigger1_i = '1') then 
          state_fut_s <= C1_SINGLE;
        else
          state_fut_s <= C2_PRESSED;
        end if;
        
      when C2_DOUBLE =>
        double_click_o <= '1';
        if (bouton_i = '1') then
          state_fut_s <= C1_PRESSED;
        else
          state_fut_s <= IDLE;
        end if;
        
      when others =>
        null; -- default
        
    end case;
  end process;
  
  -- processing memorisation
  Mem: process (clock_i, reset_i)
  begin
    if (reset_i = '1') then
      state_pres_s <= INIT;
    elsif rising_edge(clock_i) then
      state_pres_s <= state_fut_s;
    end if;
  end process;

end state_machine;
