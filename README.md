# Script Examples

## Python venv
```bash
mkdir .venv
python3 -m venv .venv
source .venv/bin/activate
pip install vunit_hdl
```

## Questa (Bash)
* WildcardFilterは2次元アレイをダンプするためのコマンド
* Questa-ise 22.2の場合、voptargsオプションを付けないと波形がダンプされず、空のwlfファイルが生成される
```bash
#!/usr/bin/env bash
vlog -sv testbench_ez.sv picorv32.v +define+COMPRESSED_ISA+DEBUGREGS -l vlog.log

vsim -c testbench -voptargs="+acc" -wlf vsim.wlf -do "set WildcardFilter [lsearch -not -all -inline \$WildcardFilter Memory]; add wave -r /*; run -all; quit" -l vsim.log
```
## VUnit
* [testbench_ez.sv](testbench_ez.sv)がSystemVerilogのサンプル
* [run.py](run.py)が実行スクリプト

## Verilator
* make test_verilator_scでSystemC実行
* バイナリ実行時に、"+vcd"フラグを付けるとVCDダンプ
```bash
export SYSTEMC_INCLUDE=/usr/local/systemc-2.3.3/include
export SYSTEMC_LIBDIR=/usr/local/systemc-2.3.3/lib-linux64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC_LIBDIR

verilator --sc --exe -Wno-lint -trace --top-module picorv32_wrapper testbench.v picorv32.v test_picorv32.cpp -DCOMPRESSED_ISA --Mdir testbench_verilator_dir
make -j -C testbench_verilator_dir -f Vpicorv32_wrapper.mk
testbench_verilator_dir/Vpicorv32_wrapper +vcd
vcd2wlf testbench.vcd testbench.wlf
```