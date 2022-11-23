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
