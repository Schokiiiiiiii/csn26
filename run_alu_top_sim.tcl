###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_alu_n_top_sim.tcl
# Description  : Script pour la simulation manuelle
#                de l'alu N bits (alu_n.vhd)
#                avec top_sim (compilation, lancement console)
# 
# Auteur       : Etienne Messerli
# Date         : 15.03.2015
# Version      : 0.0
#
# Utilise      : Labo ALU avec 8 operations, unite CSNE
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date   Description
#                         
############################################################################


# files compilation
do ../comp_alu.tcl

#Chargement fichier pour la simulation
vsim work.console_sim 

#ajout signaux composant simuler dans la fenetre wave
add wave UUT/*

#lance la console REDS
do /opt/tools_reds/REDS_console.tcl

#ouvre le fichier format predefini
#do wave_alu_n_top_sim.do
