# include an additional script, which implements testcase-specific functions
set sim_extensions "sim_ext.tcl"
if { [file exists $sim_extensions] == 1} {
    source $sim_extensions
}

# add checks and breakpoints
# ...

add wave /cva6_subsys_tb/i_cva6_subsys/*
# set a timeout
run 10000ms

quit
