###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_timer_top_sim.do
# Description  : Script de compilation des fichiers et 
#                de lancement de la simulation manuelle
# 
# Auteur       : Gaëtan Matthey
# Date         : 04.11.2015
# Version      : 1.0
#
# Utilise      : lancement de la simulation manuelle de timer_top.vhd
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date       Description
# 2.0  EMI  10.11.2017  Ajout wave, supprime lignes inutiles
#                         
############################################################################


#compile all file
do ../comp_timer.tcl

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.console_sim 

#ajout signaux composant simuler dans la fenetre wave
#add wave UUT/*

#lance la console REDS
do /opt/tools_reds/REDS_console.tcl

#ouvre le fichier format predefini
do timer_top_sim_wave.do
