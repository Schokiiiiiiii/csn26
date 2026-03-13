###########################################################################
# HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
# Institut REDS, Reconfigurable & Embedded Digital Systems
#
# Fichier      : run_alu12_top_tb.tcl
# Description  : Script pour la simulation automatique
#                de l'alu 12 bits (alu12_top.vhd)
#
# Auteur       : Etienne Messerli
# Date         : 15.03.2015
# Version      : 0.0
#
# Utilise      : Labo ALU avec 8 operations, unite CSNE
#
#--| Modifications |--------------------------------------------------------
# Ver  Aut.  Date        Description
# 1.0  EMI   24.03.2016  Ajout de signaux dans le wave
# 1.1  LFR   07.03.2024  Modif pour version 2024
############################################################################

# files compilation
do ../comp_alu.tcl

#Chargement fichier pour la simulation
if {$argc>0} {
    vsim -voptargs="+acc" work.alu_top_tb -GVAL_N=$1
} else {
    vsim -voptargs="+acc" work.alu_top_tb -GVAL_N=6
}

set NumericStdNoWarnings 1
run 0 ps

# Ajoute les signaux au wave
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider ALU
add wave -noupdate -radix unsigned /alu_top_tb/uut/opcode_i
add wave -noupdate -radix binary /alu_top_tb/uut/na_i
add wave -noupdate -radix binary /alu_top_tb/uut/nb_i
add wave -noupdate -radix binary /alu_top_tb/uut/result_o
add wave -noupdate /alu_top_tb/uut/z_o
add wave -noupdate /alu_top_tb/uut/dep_nsgn_o
add wave -noupdate /alu_top_tb/uut/dep_sgn_o
add wave -noupdate -divider TestBench
add wave -noupdate /alu_top_tb/error_s
add wave -noupdate -childformat {{/alu_top_tb/reference_ref.result -radix binary}} -expand -subitemconfig {/alu_top_tb/reference_ref.result {-radix binary}} /alu_top_tb/reference_ref
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {250485 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 150
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {509385 ns}

run -all