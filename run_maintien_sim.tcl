###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_timer_sim.tcl
# Description  : Script de lancement de la simulation manuelle
#                avec REDS_Console
# 
# Auteur       : Etienne Messerli, le 05.05.2016
#
# Utilise      : Simulation du composatn Timer pour det_clic_dblclic_top
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date       Description
# 2.0  MIM   27.11.17   Target -> REDS_console.tcl                      
############################################################################

#create library work        
vlib work
#map library work to work
vmap work work

# Files compilation
vcom -reportprogress 300 -work work ../src/det_clic_dblclic_pkg.vhd
vcom -reportprogress 300 -work work ../src/maintien.vhd

#compile fichier tb, tester et console_sim 
vcom -reportprogress 300 -work work ../src_tb/console_sim_maintien.vhd

#Chargement fichier pour la simulation
vsim work.console_sim 

#ajout signaux composant simuler dans la fenetre wave
add wave UUT/*

#lance la console REDS
do /opt/tools_reds/REDS_console.tcl

#ouvre le fichier format predefini
#do wave_timer_sim.do




