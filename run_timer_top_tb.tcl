###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_timer_top_tb.tcl
# Description  : Script de compilation des fichiers et 
#                de lancement de la simulation automatique
#                (utilisation du test bench)
# 
# Auteur       : Gaëtn Matthey
# Date         : 04.11.2015
# Version      : 1.0
#
# Utilise      : Labo timer_top.vhd
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date      Description
# 2.0  EMI  10.11.2017 Corrections
#                         
############################################################################


#compile all file
do ../comp_timer.tcl

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.timer_top_tb 

#Ouvre et place les fenetres signal et wave    
#do C:/EDA/Tools_REDS/QuestaSim/QuestaSim.do

#ajout signaux composant simuler dans la fenetre wave
add wave -divider UUT
add wave UUT/*

add wave -divider Testbench
add wave -position end  sim:/timer_top_tb/tst/Done_ref
add wave -position end  sim:/timer_top_tb/tst/Erreur_s

add wave -divider Check
add wave -position end  sim:/timer_top_tb/tst/Done_ref
add wave -position end  sim:/timer_top_tb/uut/Done_o

# noms des signaux sans hierarchie
config wave -signalnamewidth 1

#ouvre le fichier format predefini
#do wave_timer_top_tb.do



