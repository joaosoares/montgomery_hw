#!/bin/bash -f
xv_path="/esat/micas-data/software/xilinx_vivado_2016.2/Vivado/2016.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 917798f55d0047e7b0ce8dc2685263eb -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot tb_adder_behav xil_defaultlib.tb_adder xil_defaultlib.glbl -log elaborate.log
