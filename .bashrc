# .bashrc

# Questa environment

# IntelFPGA Questa license daemon
export MGLS_LICENSE_FILE=1800@localhost
export MGLS_DAEMON_HOME=/opt/intelFPGA/lic_daemon
# Questa Intel Starter Edition
export MTI_HOME=/opt/intelFPGA/22.2/questa_fse

export PATH=$PATH:$MGLS_DAEMON_HOME:$MTI_HOME/bin


# Icarus Verilog environment
export ICARUS_HOME=/usr/local/iverilog
export PATH=$PATH:$ICARUS_HOME/bin


# Risc-V environment
export RV32_HOME=/opt/riscv32i
export RV64_HOME=/opt/riscv/riscv64-unknown-elf
export PATH=$PATH:$RV32_HOME/bin:$RV64_HOME/bin

# SystemC environment
export SYSTEMC_HOME=/usr/local/systemc-2.3.3

export SYSTEMC_INCLUDE=$SYSTEMC_HOME/include
export SYSTEMC_LIBDIR=$SYSTEMC_HOME/lib-linux64

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC_LIBDIR
