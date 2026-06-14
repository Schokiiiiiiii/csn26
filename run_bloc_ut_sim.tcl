###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_bloc_ut_sim.tcl.tcl
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
vcom -2008 -reportprogress 300 -work work   ../src_tb/console_sim_ut.vhd

#Chargement fichier pour la simulation
vsim -voptargs="+acc" work.console_sim 

#lance la console REDS
do /opt/tools_reds/REDS_console.tcl

# Entrées générales
add wave -label clk_i      sim:/console_sim/UUT/clk_i
add wave -label rst_i      sim:/console_sim/UUT/rst_i
add wave -label nb_tour_i  sim:/console_sim/UUT/nb_tour_i

# Registre vitesse
add wave -label init_sp_i    sim:/console_sim/UUT/init_sp_i
add wave -label incr_sp_i    sim:/console_sim/UUT/incr_sp_i
add wave -label decr_sp_i    sim:/console_sim/UUT/decr_sp_i
add wave -label sel_speed_o  sim:/console_sim/UUT/sel_speed_o
add wave -label min_sp_o     sim:/console_sim/UUT/min_sp_o
add wave -label max_sp_o     sim:/console_sim/UUT/max_sp_o

# Direction
add wave -label dir_a_i  sim:/console_sim/UUT/dir_a_i
add wave -label dir_h_i  sim:/console_sim/UUT/dir_h_i
add wave -label dir_l_o  sim:/console_sim/UUT/dir_l_o
add wave -label dir_m_o  sim:/console_sim/UUT/dir_m_o
add wave -label dir_r_o  sim:/console_sim/UUT/dir_r_o

# Enables moteurs
add wave -label en_ml_i   sim:/console_sim/UUT/en_ml_i
add wave -label dis_ml_i  sim:/console_sim/UUT/dis_ml_i
add wave -label en_l_o    sim:/console_sim/UUT/en_l_o

add wave -label en_mm_i   sim:/console_sim/UUT/en_mm_i
add wave -label dis_mm_i  sim:/console_sim/UUT/dis_mm_i
add wave -label en_m_o    sim:/console_sim/UUT/en_m_o

add wave -label en_mr_i   sim:/console_sim/UUT/en_mr_i
add wave -label dis_mr_i  sim:/console_sim/UUT/dis_mr_i
add wave -label en_r_o    sim:/console_sim/UUT/en_r_o

# Compteur de tours
add wave -label init_tour_i      sim:/console_sim/UUT/init_tour_i
add wave -label decr_tour_i      sim:/console_sim/UUT/decr_tour_i
add wave -label zero_tour_o      sim:/console_sim/UUT/zero_tour_o
add wave -label last_tour_o      sim:/console_sim/UUT/last_tour_o
add wave -label mult_tour_o      sim:/console_sim/UUT/mult_tour_o
add wave -label tour_in_null_o   sim:/console_sim/UUT/tour_in_null_o

# Compteur d'encoches
add wave -label init_enc_i   sim:/console_sim/UUT/init_enc_i
add wave -label incr_enc_i   sim:/console_sim/UUT/incr_enc_i
add wave -label det_tour_o   sim:/console_sim/UUT/det_tour_o

# Présence moteurs
add wave -label ml_pres_o  sim:/console_sim/UUT/ml_pres_o
add wave -label mm_pres_o  sim:/console_sim/UUT/mm_pres_o
add wave -label mr_pres_o  sim:/console_sim/UUT/mr_pres_o