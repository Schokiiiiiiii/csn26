###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : comp_bin_lin.do
# Description  : Script de lancement de la simulation automatique
# 
# Auteur       : Etienne Messerli
# Date         : 17.09.2014
# Version      : 1.0
#
# Utilise      : Compilation bin_lin_2a4.vhd
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date   Description
#                         
############################################################################

#create library work and compile files
do comp_det_clic_dblclic_top.tcl

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.det_clic_dblclic_top_tb 

#ajout signaux composant simuler dans la fenetre wave
#add wave UUT/*

#ouvre le fichier format predefini
do wave_det_clic_dblclic_top_tb.do


