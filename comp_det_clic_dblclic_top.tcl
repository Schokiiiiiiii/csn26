###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : comp_det_clic_dblclic_top.tcl
# Description  : Script de compilation des fichiers
#
# Auteur       : Etienne Messerli, le 05.05.2016
#
# Utilise      : Compilation projet Det_Clic_Dbl_Clic
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date   Description
#
############################################################################


#create library work
vlib work
#map library work to work
vmap work work

###########################################################################
# to be complete with all your new files
#vcom -reportprogress 300 -work work   ../src/ **** to complete *****

###########################################################################

#Compilation of supplieds files
  #vcom -reportprogress 300 -work work   ../src/ **** to complete *****
vcom -reportprogress 300 -work work ../src/det_clic_dblclic_pkg.vhd
vcom -reportprogress 300 -work work ../src/timer.vhd
vcom -reportprogress 300 -work work ../src/maintien.vhd

#compile top file
vcom -reportprogress 300 -work work ../src/det_clic_dblclic_top.vhd

#compile fichier tb, tester et console_sim
vcom -reportprogress 300 -work work ../src_tb/det_clic_dblclic_top_tester.vhd
vcom -reportprogress 300 -work work ../src_tb/det_clic_dblclic_top_tb.vhd
