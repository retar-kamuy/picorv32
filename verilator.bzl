VerilogInfo = provider(
    doc = "list of Verilog files.",
    fields = {
        "srcs": "depset of Verilog files",
        "includes": "depset of include files",
        "incdirs": "depset of include directories",
        "data": "depset of data files"
    },
)

def _transitive_srcs(deps):
    return depset(
        [],
        transitive = [dep[VerilogInfo].srcs for dep in deps],
    )

def _transitive_data(deps):
    return depset(
        [],
        transitive = [dep[VerilogInfo].data for dep in deps],
    )

def _verilator_impl(ctx):
    obj_dir = ctx.actions.declare_file(ctx.label.name)
    executable = ctx.actions.declare_file(ctx.attr.top_module)

    args = []
    args += ctx.attr.arguments
    args += ["--top-module", ctx.attr.top_module]
    args += [src.path for src in ctx.files.srcs]
    args += ["--Mdir", obj_dir.basename]

    transitive_srcs = _transitive_srcs([dep for dep in ctx.attr.deps if VerilogInfo in dep])
    verilog_srcs = [verilog_info_struct.files for verilog_info_struct in transitive_srcs.to_list()]
    verilog_files = [src for sub_tuple in verilog_srcs for src in sub_tuple.to_list()]
    args += [src.path for src in verilog_files]

    transitive_data = _transitive_data([dep for dep in ctx.attr.deps if VerilogInfo in dep])
    verilog_data = [verilog_info_struct.files for verilog_info_struct in transitive_data.to_list()]
    data_files = [src for sub_tuple in verilog_data for src in sub_tuple.to_list()]

    #for dep in ctx.attr.deps:
    #    if VerilogInfo in dep:
    #        for src in dep[VerilogInfo].srcs:
    #            args += [test.path for test in src.files.to_list()]

    if ctx.files.filelists:
        args += ["-f %s" % filelist.path for filelist in ctx.files.filelists]
        local = True
    else:
        local = ctx.attr.local

    ctx.actions.run_shell(
        outputs = [obj_dir, executable],
        inputs = ctx.files.srcs + ctx.files.hdrs,
        command = "verilator %s && \
                    make -j -C %s -f V%s.mk && \
                    cp -r %s %s && \
                    cp %s/V%s %s" % (" ".join(args), obj_dir.basename, ctx.attr.top_module, obj_dir.basename, obj_dir.path, obj_dir.basename, ctx.attr.top_module, executable.path),
        use_default_shell_env = True,
        execution_requirements = {"local": str(local)},
    )

    #runfiles = ctx.runfiles(files = [obj_dir] + ctx.files.data)
    runfiles = ctx.runfiles(files = [obj_dir] + ctx.files.data + data_files)
    return [DefaultInfo(executable = executable, runfiles = runfiles)]

verilator = rule(
    implementation = _verilator_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = False,
            allow_files = ["v", "sv", "c", "cc", "cpp"],
        ),
        "filelists": attr.label_list(
            mandatory = False,
            allow_files = True,
        ),
        "hdrs": attr.label_list(
            allow_files = ["h", "hpp"],
        ),
        "arguments": attr.string_list(),
        "top_module": attr.string(),
        "data": attr.label_list(
            allow_files = True,
        ),
        "local": attr.bool(
            default = False,
        ),
        "deps": attr.label_list(),
    },
    executable = True,
)

#def _attention_current_directory(srcs):
#    for src in srcs:
#        if len(src.split("/")) == 1:
#        
#    return [for src in srcs if len(src.split("/")) == 1]

def _example_impl(ctx):
    #find . -maxdepth 1 -type f -name '*.cpp' -or -name '*.h'
    #find . -name *.JPG | xargs -i cp -p {} /temp

    incdir_list = ctx.actions.declare_directory("%s_incdir" % ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [incdir_list],
        arguments = [incdir_list.path, ctx.attr.includes[0]],
        command = "mkdir -p $1 && find $2 -maxdepth 1 -type f -name '*.cpp' -or -name '*.h' | xargs -i cp -p $(realpath {}) > $2",
        execution_requirements = {"local": "True"},
    )

    out_files = []
    for src in ctx.attr.srcs:
        if "+incdir+" in src:
            print(src.split("+incdir+"))
            src_path = src.split("+incdir+")[1]
        else:
            src_path = src
        out_file = ctx.actions.declare_file(src_path)
        ctx.actions.run_shell(
            outputs = [out_file],
            command = "cp $(realpath \"%s\") %s" % (src_path, out_file.path),
            execution_requirements = {"local": "True"},
        )
        out_files.append(out_file)

    return [DefaultInfo(files = depset(out_files + [incdir_list]))]

example = rule(
    implementation = _example_impl,
    attrs = {
        "srcs": attr.string_list(),
        "includes": attr.string_list(
            default = ["."],
        ),
    },
)

def _verilog_library_impl(ctx):
    return [VerilogInfo(
        srcs = depset(ctx.attr.srcs),
        includes = depset(ctx.attr.includes),
        data = depset(ctx.attr.data),
    )]

verilog_library = rule(
    implementation = _verilog_library_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = ["v", "sv", "sva"],
        ),
        "includes": attr.label_list(
            allow_files = ["v", "vh", "sv", "svh", "sva", "h"],
        ),
        "data": attr.label_list(
            allow_files = True,
        ),
    },
)