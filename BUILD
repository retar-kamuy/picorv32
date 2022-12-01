load(":verilator.bzl", "verilator", "example")

genrule(
    name = "testbench_verilator_sc",
    srcs = ["testbench.v", "picorv32.sv", "test_picorv32.cpp"],
    outs = ["testbench_verilator"],
    cmd = "verilator --sc --exe -Wno-lint -trace --top-module picorv32_wrapper $(SRCS) \
            -DCOMPRESSED_ISA --Mdir testbench_verilator_dir && \
            make -j -C testbench_verilator_dir -f Vpicorv32_wrapper.mk && \
            cp testbench_verilator_dir/Vpicorv32_wrapper $@",
    tools = ["Makefile", "test_picorv32.h"],
    executable =True,
)

verilator(
    name = "test_verilator_sc",
    srcs = ["testbench.v", "picorv32.sv", "test_picorv32.cpp"],
    hdrs = ["test_picorv32.h"],
    arguments = ["--sc", "--exe", "-Wno-lint", "-trace", "-DCOMPRESSED_ISA"],
    top_module = "picorv32_wrapper",
    data = ["firmware/firmware.hex"],
)


example(
    name = "run_example",
    srcs = ["testbench.v", "picorv32.sv", "test_picorv32.cpp"],
)
