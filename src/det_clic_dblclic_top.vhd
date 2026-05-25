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
	 
use work.det_clic_dblclic_pkg.all;

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
  signal reset_s        : std_logic;
  signal start_s        : std_logic;
  signal button_s       : std_logic;
  signal trigger1_s     : std_logic;
  signal trigger2_s     : std_logic;
  signal simple_click_s : std_logic;
  signal double_click_s : std_logic;

    ----------
    -- TODO --
    ----------

  
   -- Component declarations
   
   
    ----------
    -- TODO --
    ----------
   
	component timer
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
   end component;
	for all : timer use entity work.timer;
	
	component mss_clic_dblclic
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
   end component;
	for all : mss_clic_dblclic use entity work.mss_clic_dblclic;

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
	
	reset_s <= not nReset_i;
	
	process(clock_i, button_i)
	begin
		if rising_edge(clock_i) then
			button_s <= button_i;
		end if;
	end process;
		

	U_timer : timer
		generic map (
			T1_g => T1_c,
			T2_g => T2_c
			
		)
		port map (
			clock_i => clock_i,
			reset_i => reset_s,
			start_i => start_s,
			top_ms_i => top_ms_i,
			trigger1_o => trigger1_s,
			trigger2_o => trigger2_s
		);
		
	mss : mss_clic_dblclic
		port map(
		  clock_i        => clock_i,
        reset_i        => reset_s,
        trigger1_i     => trigger1_s,
        trigger2_i     => trigger2_s,
        bouton_i       => button_s,
		  top_ms_i       => top_ms_i,
        start_o        => start_s,
		  simple_click_o => simple_click_s,
		  double_click_o => double_click_s
		);
	
	clic_lg : maintien
		generic map (
		  T_HOLD => T_HOLD_C
		)
		port map (
		  clock_i    => clock_i,
        reset_i    => reset_s,
        pulse_i    => simple_click_s,
        top_ms_i   => top_ms_i,
        p_hold_o   => clic_lg_o
		);
		
	dbl_clic_lg : maintien
		generic map (
		  T_HOLD => T_HOLD_C
		)
		port map (
		  clock_i    => clock_i,
        reset_i    => reset_s,
        pulse_i    => double_click_s,
        top_ms_i   => top_ms_i,
        p_hold_o   => dbl_clic_lg_o
		);
	
		clic_o <= simple_click_s;
		dbl_clic_o <= double_click_s;



end struct;
