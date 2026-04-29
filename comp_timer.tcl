###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : comp_timer.tcl
# Description  : Script de compilation des fichiers
# 
# Auteur       : Etienne Messerli
# Date         : 12.11.2016
# Version      : 1.0
#
# Utilise      : Compilation fichiers projet timer
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date   Description
#                         
############################################################################


#create library work        
vlib work
#map library work to work
vmap work work

# timer_top file compilation
vcom -reportprogress 300 -work work   ../src/timer_top.vhd

# ajouter vos fichiers a compiler 
#vcom -reportprogress 300 -work work   ../src/.....

 # test-bench compilation
vcom -reportprogress 300 -work work   ../src_tb/console_sim.vhd
vcom -reportprogress 300 -work work   ../src_tb/timer_top_tester.vhd
vcom -reportprogress 300 -work work   ../src_tb/timer_top_tb.vhd
