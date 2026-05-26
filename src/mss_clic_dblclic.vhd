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
        top_ms_i       : in  std_logic;
        start_o        : out std_logic;
	simple_click_o : out std_logic;
	double_click_o : out std_logic
        );
end mss_clic_dblclic;

architecture state_machine of mss_clic_dblclic is

  signal state_pres_s : std_logic_vector(3 downto 0);
  signal state_fut_s  : std_logic_vector(3 downto 0);

  constant INIT          : std_logic_vector(3 downto 0) := "0000";
  constant WAIT_PRESS1   : std_logic_vector(3 downto 0) := "0001";
  constant START1	 : std_logic_vector(3 downto 0) := "0010";
  constant WAIT_RELEASE1 : std_logic_vector(3 downto 0) := "0011";
  constant START2	 : std_logic_vector(3 downto 0) := "0100";
  constant WAIT_PRESS2   : std_logic_vector(3 downto 0) := "0101";
  constant START3	 : std_logic_vector(3 downto 0) := "0110";
  constant WAIT_RELEASE2 : std_logic_vector(3 downto 0) := "0111";
  constant PULSE_SINGLE  : std_logic_vector(3 downto 0) := "1000";
  constant PULSE_DOUBLE  : std_logic_vector(3 downto 0) := "1001";

begin

  -- processing future state
  Fut: process (trigger1_i, trigger2_i, bouton_i, top_ms_i, state_pres_s)
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
          state_fut_s <= WAIT_PRESS1; -- bouton released
        else
          state_fut_s <= INIT;        -- bouton pressed
        end if;
        
      when WAIT_PRESS1 => 
        if (bouton_i = '1') then
          state_fut_s <= START1;      -- bouton pressed
        else 
          state_fut_s <= WAIT_PRESS1; -- bouton not pressed
        end if;
        
      when START1 =>
        start_o <= '1';
        state_fut_s <= WAIT_RELEASE1; -- timer started, waiting for release 1 or timeout
        
      when WAIT_RELEASE1 =>
        if (trigger1_i = '0' and bouton_i = '0') then
          state_fut_s <= START2;                  -- stopped pressing
        elsif (trigger1_i = '0' and bouton_i = '1') then
          state_fut_s <= WAIT_RELEASE1;           -- still pressing
        elsif (trigger1_i = '1' and bouton_i = '0') then
          state_fut_s <= WAIT_PRESS1;             -- timeout and stopped pressing
        else
          state_fut_s <= INIT;                    -- timeout but still pressing
        end if;
        
      when START2 =>
        start_o <= '1';
        state_fut_s <= WAIT_PRESS2; -- timer started -> waiting for press 2 or timeout
        
      when WAIT_PRESS2 =>
        if trigger2_i = '1' then
          state_fut_s <= PULSE_SINGLE; -- timeout -> single click
        elsif bouton_i = '1' then
          state_fut_s <= START3;       -- bouton pressed -> start double click timer
        else
          state_fut_s <= WAIT_PRESS2;  -- not pressed and no timeout -> wait
        end if;
        
      when START3 =>
        start_o <= '1';
        state_fut_s <= WAIT_RELEASE2;  -- timer started, waiting for release 2 or timeout
        
      when WAIT_RELEASE2 =>
        if (trigger1_i = '1' and bouton_i = '1') then
          state_fut_s <= INIT;          -- timeout -> invalid sequence back to init
        elsif (trigger1_i = '1' and bouton_i = '0') then
          state_fut_s <= WAIT_PRESS1;   -- timeout -> invalid sequence back to wait first click
        elsif bouton_i = '0' then
          state_fut_s <= PULSE_DOUBLE;  -- bouton released -> send double signal
        else
          state_fut_s <= WAIT_RELEASE2; -- no timeout or release
        end if;
        
      when PULSE_SINGLE =>
        simple_click_o <= '1';
        if (bouton_i = '1') then
          state_fut_s <= INIT;         -- bouton pressed -> wait for release
        else
          state_fut_s <= WAIT_PRESS1;  -- bouton released -> wait for bouton
        end if;
        
      when PULSE_DOUBLE =>
        double_click_o <= '1';
        if (bouton_i = '1') then
          state_fut_s <= INIT;        -- bouton pressed -> wait for release
        else
          state_fut_s <= WAIT_PRESS1; -- bouton released -> wait for bouton
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
