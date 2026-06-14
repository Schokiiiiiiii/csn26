###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_bloc_uc_sim.tcl.tcl
# Description  : Script permmettant le lancement de la simulation manuelle
#                de l'UC seul
# 
# Auteur       : Etienne Messerli
# Date         : 02.12.2014
# Version      : 1.0
#
# Utilise      : Labo CSN/SysLog2, commande de 3 moteurs pas-a-pas
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date        Description
# 0.0  EMI  13.03.2013   Version originale
#                         
############################################################################
#create library work        
vlib work
#map library work to work
vmap work work

#compile all file 
do ../comp_mot_pap_top.tcl

# top_sim compilation
vcom -2008 -reportprogress 300 -work work   ../src_tb/console_sim_uc.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.console_sim 

#lance la console REDS
do /opt/tools_reds/REDS_console.tcl

#ajout signaux du composant simuler dans la fenetre wave
# Entrées générales
add wave -label clk_i    sim:/console_sim/UUT/clk_i
add wave -label rst_i    sim:/console_sim/UUT/rst_i
add wave -label mode_i   sim:/console_sim/UUT/mode_i
add wave -label start_i  sim:/console_sim/UUT/start_i
add wave -label init_i   sim:/console_sim/UUT/init_i

# Capteurs et commandes utilisateur
add wave -label cap_l_i  sim:/console_sim/UUT/cap_l_i
add wave -label cap_m_i  sim:/console_sim/UUT/cap_m_i
add wave -label cap_r_i  sim:/console_sim/UUT/cap_r_i
add wave -label run_l_i  sim:/console_sim/UUT/run_l_i
add wave -label run_m_i  sim:/console_sim/UUT/run_m_i
add wave -label run_r_i  sim:/console_sim/UUT/run_r_i

# Retours principaux de l'UT
add wave -label min_sp_i       sim:/console_sim/UUT/min_sp_i
add wave -label max_sp_i       sim:/console_sim/UUT/max_sp_i
add wave -label zero_tour_i    sim:/console_sim/UUT/zero_tour_i
add wave -label last_tour_i    sim:/console_sim/UUT/last_tour_i
add wave -label mult_tour_i    sim:/console_sim/UUT/mult_tour_i
add wave -label det_tour_i     sim:/console_sim/UUT/det_tour_i

# Commandes vers l'UT - vitesse et direction
add wave -label init_sp_o  sim:/console_sim/UUT/init_sp_o
add wave -label incr_sp_o  sim:/console_sim/UUT/incr_sp_o
add wave -label decr_sp_o  sim:/console_sim/UUT/decr_sp_o
add wave -label dir_h_o    sim:/console_sim/UUT/dir_h_o
add wave -label dir_a_o    sim:/console_sim/UUT/dir_a_o

# Commandes vers l'UT - moteurs
add wave -label en_ml_o   sim:/console_sim/UUT/en_ml_o
add wave -label dis_ml_o  sim:/console_sim/UUT/dis_ml_o
add wave -label en_mm_o   sim:/console_sim/UUT/en_mm_o
add wave -label dis_mm_o  sim:/console_sim/UUT/dis_mm_o
add wave -label en_mr_o   sim:/console_sim/UUT/en_mr_o
add wave -label dis_mr_o  sim:/console_sim/UUT/dis_mr_o

# Commandes vers l'UT - compteurs et erreur
add wave -label init_tour_o  sim:/console_sim/UUT/init_tour_o
add wave -label decr_tour_o  sim:/console_sim/UUT/decr_tour_o
add wave -label init_enc_o   sim:/console_sim/UUT/init_enc_o
add wave -label incr_enc_o   sim:/console_sim/UUT/incr_enc_o
add wave -label err_o        sim:/console_sim/UUT/err_o