###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : comp_alu_n.tcl
# Description  : Script de compilation des fichiers pour
#                l'alu N bits (alu_n.vhd)
#
# Auteur       : Etienne Messerli
# Date         : 15.03.2015
# Version      : 0.0
#
# Utilise      : Labo ALU avec 8 operations, unite CSNE
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date        Description
# 0.1  LFR   07.03.2024  Add file for TestBench
############################################################################

#create library work
vlib work
#map library work to work
vmap work work

# alu_n files compilation
# TO COMPLETE: add your adder files
vcom -reportprogress 300 -work work   ../src/alu_nbits_top.vhd


# test-bench compilation
vcom -2008 -reportprogress 300 -work work   ../src_tb/logger_pkg.vhd
vcom -2008 -reportprogress 300 -work work   ../src_tb/project_logger_pkg.vhd
vcom -2008 -reportprogress 300 -work work   ../src_tb/common_pkg.vhd
vcom -2008 -reportprogress 300 -work work   ../src_tb/alu_top_tb.vhd
vcom -2008 -reportprogress 300 -work work   ../src_tb/console_sim.vhd

