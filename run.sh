#!/usr/bin/env bash

vlog -sv testbench_ez.sv picorv32.v +define+COMPRESSED_ISA+DEBUGREGS -l vlog.log

vsim -c testbench -voptargs="+acc" -wlf vsim.wlf -do "set WildcardFilter [lsearch -not -all -inline \$WildcardFilter Memory]; add wave -r /*; run -all; quit" -l vsim.log
