#from vunit import VUnitCLI
from vunit.verilog import VUnit

#cli = VUnitCLI()
#cli.parser.add_argument('--custom-arg', ...)
#args = cli.parse_args()
#VU = VUnit.from_args(args=args)

VU = VUnit.from_argv()

def pre_config(output_path):
    return True

lib = VU.add_library("lib")
lib.add_source_files("picorv32.v")
lib.set_compile_option("modelsim.vlog_flags", ["+define+COMPRESSED_ISA+DEBUGREGS"])

tb_lib = VU.add_library("tb_lib")
tb_lib.add_source_files("testbench_ez.sv")

VU.set_sim_option("vhdl_assert_stop_level", "failure")

#tb_objs = tb_lib.get_test_benches(pattern="*", allow_empty=False)
#for tb in tb_objs:
##        tb_obj = tb_lib.test_bench(tb.name)
#tb_obj.set_pre_config(pre_config)

VU.main()
