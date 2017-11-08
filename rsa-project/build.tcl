set origin_dir [file dirname [info script]]

# Create project
create_project rsa_project $origin_dir/rsa_project -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog

# Add source files
set files [list \
               [file normalize $origin_dir/src/rtl/adder.v                     ] \
               [file normalize $origin_dir/src/rtl/montgomery.v                ] \
               [file normalize $origin_dir/src/rtl/hweval_adder.v              ] \
               [file normalize $origin_dir/src/rtl/hweval_montgomery.v         ] \
            ]
add_files -norecurse -fileset [get_filesets sources_1] $files

set_property top hweval_adder [get_filesets sources_1]

# Add Simulation files
set files [list \
               [file normalize $origin_dir/src/rtl/tb_adder.v                  ] \
               [file normalize $origin_dir/src/rtl/tb_montgomery.v             ] \
             ]
add_files -norecurse -fileset [get_filesets sim_1] $files

set_property top tb_adder [get_filesets sim_1]

# Remove design sources from simulation
set files [list \
               [file normalize $origin_dir/src/rtl/hweval_adder.v                                                   ] \
               [file normalize $origin_dir/src/rtl/hweval_montgomery.v                                              ] \
            ]
set_property used_in_simulation false [get_files $files]

# Add Constraints
add_files -fileset constrs_1 -norecurse $origin_dir/src/constraints/constraints.tcl

update_compile_order -fileset sim_1
update_compile_order -fileset sources_1

# Latches -> Error
set_msg_config -id {Synth 8-327}     -new_severity {ERROR}

# Multi-driven -> Error
set_msg_config -id {Synth 8-3352}    -new_severity {ERROR}
set_msg_config -id {Synth 8-5559}    -new_severity {ERROR}

# Timing not meet -> Error
set_msg_config -id {Timing 38-282}   -new_severity {ERROR}

set_msg_config -id {BD 41-1343}      -new_severity {INFO}
set_msg_config -id {BD_TCL-1000}     -new_severity {INFO}
set_msg_config -id {IP_Flow 19-3899} -new_severity {INFO}
set_msg_config -id {IP_Flow 19-3153} -new_severity {INFO}
set_msg_config -id {IP_Flow 19-2207} -new_severity {INFO}
set_msg_config -id {Vivado 12-3482}  -new_severity {INFO}
