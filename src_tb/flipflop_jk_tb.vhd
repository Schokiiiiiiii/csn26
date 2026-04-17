-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : flipflop_rs_tb.vhd
-- Description  : Testbench pour la simulation du fichier flipflop_t.vhd
--                
-- Auteur       : E. Messerli
-- Date         : 20.04.2020
--
-- Utilise      : Exercice formation VHDL
--                                                                              
--| Modifications |------------------------------------------------------------
-- Version   Auteur  Date           Description
-- 1.0      MBI      23.04.2020     changement de flipflop_rs a flipflop_jk
--
-------------------------------------------------------------------------------
-- MBI : Michael Binggeli, etudiant SysLog2 mai 2020

library IEEE;
  use IEEE.Std_Logic_1164.all;
  --use IEEE.Numeric_Std.all;

entity flipflop_jk_tb is

end flipflop_jk_tb;

------------------------------------------------------------------------
-- Architecture du testbench VHDL 
------------------------------------------------------------------------

architecture test_bench of flipflop_jk_tb is

  component flipflop_jk 
   port(clk_i    : in     std_logic;
        reset_i  : in     std_logic;
        J_i      : in     std_logic;
        K_i      : in     std_logic;
        Q_o      : out    std_logic;
        nQ_o     : out    std_logic
    );
  end component;
  for all : flipflop_jk use entity work.flipflop_jk(comport);

  constant Periode_c   : time := 100 ns;
  --constant Unite_Min_c : time := 1 ns;
  constant Pulse_c     : time := 4 ns;
  
  --signaux de base pour la simulation sequentiel (HORLOGE)
  signal Sim_End_s : boolean := false;
  signal Horloge_int : std_logic;           -- signal d'horloge
  
  --signaux de detection des erreurs (check), propre a l'application
  signal Erreur_s : Std_Logic := '0';
  shared variable Nbr_Err_v : Natural; --partagee process stimuli et verif
  
  --signaux intermediares pour la simulation, propre a l'application
  signal reset_sti    : std_logic;
  signal K_sti, J_sti : std_logic;
  signal Q_obs, Q_ref : std_logic;
  signal nQ_obs, nQ_ref : std_logic;
  
  ---------------------------------------------------------------------------
  -- Procedure permettant plusieurs cycles d'horloge
  -- Le premier appel de la procedure termine le cycle precedent si celui-ci
  -- n'etait pas complet (par exemple : si on a fait quelques pas de 
  -- simulation non synchronises avant, reset asynchrone, combinatoire, ...)
  ---------------------------------------------------------------------------
    procedure cycle (nombre_de_cycles : Integer := 1) is
      begin
        for i in 1 to nombre_de_cycles loop
           wait until Falling_Edge(Horloge_int);
           wait for 2 ns; --assigne stimuli 2ns apres flanc montant 
        end loop;
    end cycle;
  
  begin
  
  ------------------------------------------------------------------
  --Process de generation de l'horloge
  ------------------------------------------------------------------
  process
  begin
    while not Sim_End_s loop
      Horloge_Int <= '1', '0' after Periode_c/2;
      wait for Periode_c;
    end loop;
    wait;
  end process;

---------------------------------------------------------------------------
-- Interconnexion du module VHDL a simuler
---------------------------------------------------------------------------
uut: flipflop_jk port map (clk_i    => Horloge_int,
                           reset_i  => reset_sti,
                           k_i      => K_sti,
                           J_i      => J_sti,
                           Q_o      => Q_obs,
                           nQ_o     => nQ_obs
                           );

---------------------------------------------------------------------------
-- Debut des pas de simulation
---------------------------------------------------------------------------

  process
  begin
    Nbr_Err_v := 0; -- initialise compteur d'erreur
     
    report ">> Debut de la simulation";

    reset_sti <= '0';
    k_sti  <= 'X';
    j_sti  <= 'X';
    Q_ref  <= 'X';
	 nQ_ref <= 'X';
    cycle;
   

-----Test du reset asynchrone
    reset_sti <= '1';
    Q_ref  <= '0';
	 nQ_ref <= '1';
    cycle(2);
    K_sti <= '0';
    J_sti <= '1';
    cycle;
    reset_sti <= '0';
    J_sti <= '0';
    --Q_ref pas modifie, reste a '0'
    cycle;
   
-----Test du set synchrone
    J_sti <= '1';
    wait until Rising_Edge(Horloge_Int);
    Q_ref <= '1';
	nQ_ref <= '0';
    cycle; 

-----Test du maintien 
    J_sti <= '0';
    wait until Rising_Edge(Horloge_Int);
    Q_ref <= '1';
	nQ_ref <= '0';
    cycle; 

-----Test du reset synchrone
    K_sti <= '1';
    wait until Rising_Edge(Horloge_Int);
    Q_ref <= '0';
	nQ_ref <= '1';
    cycle; 

-----Test du maintien 
    K_sti <= '0';
    wait until Rising_Edge(Horloge_Int);
    Q_ref <= '0';
	nQ_ref <= '1';
    cycle; 

-----Test toggle synchrone
    J_sti <= '1';
    K_sti <= '1';
    wait until Rising_Edge(Horloge_Int);
    Q_ref <= '1';
	nQ_ref <= '0';
    cycle; 

-----Test du maintien 
    J_sti <= '0';
    K_sti <= '0';
    wait until Rising_Edge(Horloge_Int);
    Q_ref <= '1';
	nQ_ref <= '0';
    cycle; 

-----Test du reset asynchrone prioritaire sur le set synchrone
    reset_sti <= '1';
    J_sti <= '1';
    Q_ref <= '0';
	nQ_ref <= '1';
    cycle(2);
    reset_sti <= '0';
    wait until Rising_Edge(Horloge_Int);
    Q_ref <= '1';
	nQ_ref <= '0';
    cycle;
    
  report ">>Nombre d'erreur détectée = " & integer'image(Nbr_Err_v);
  report ">>Fin de la simulation";
        
  Sim_End_s <= true;
  wait; --Attente infinie, stop la simulation
  end process;
  
---------------------------------------------------------------------------
-- Process de verification
---------------------------------------------------------------------------
  process
  begin
    while not Sim_End_s loop
      wait until Falling_Edge(Horloge_int);
      wait for (Periode_c/2)- 2 ns;
    --Verification asynchrone Q
      if Q_obs /= Q_ref then
        Erreur_s <= '1', '0' after Pulse_c;
        Nbr_Err_v := Nbr_Err_v + 1;
        report"Lors verif Sortie, asynch Q"
          severity ERROR;
      end if;
	  --Verification asynchrone nQ
      if nQ_obs /= nQ_ref then
        Erreur_s <= '1', '0' after Pulse_c;
        Nbr_Err_v := Nbr_Err_v + 1;
        report"Lors verif Sortie, asynch nQ"
          severity ERROR;
      end if;
      wait until Rising_Edge(Horloge_Int);
      wait for (Periode_c/2)- 2 ns;
    --Verification synchrone
      if Q_obs /= Q_ref then
        Erreur_s <= '1', '0' after Pulse_c;
        Nbr_Err_v := Nbr_Err_v + 1;
        report"Lors verif Sortie, synch Q"
          severity ERROR;
      end if;
	  --Verification synchrone
      if nQ_obs /= nQ_ref then
        Erreur_s <= '1', '0' after Pulse_c;
        Nbr_Err_v := Nbr_Err_v + 1;
        report"Lors verif Sortie, synch nQ"
          severity ERROR;
      end if;
    end loop;
    wait;
  end process;

end Test_Bench;





