VerilogInfo = provider(
    doc = "list of Verilog files.",
    fields = {
        "srcs": "depset of Verilog files",
        #"includes": "depset of include files",
        #"incdirs": "depset of include directories",
        "filelists": "depset of filelists",
        "data": "depset of data files"
    },
)

def get_transitive_srcs(srcs, deps):
    return depset(
        srcs,
        transitive = [dep[VerilogInfo].srcs for dep in deps]
    )

def get_transitive_data(data, deps):
    return depset(
        data,
        transitive = [dep[VerilogInfo].data for dep in deps],
    )

def get_transitive_filelists(filelists, deps):
    return depset(
        filelists,
        transitive = [dep[VerilogInfo].filelists for dep in deps],
    )

def _verilator_impl(ctx):
    obj_dir = ctx.actions.declare_file(ctx.label.name)
    executable = ctx.actions.declare_file(ctx.attr.top_module)

    args = []
    args += ctx.attr.arguments
    args += ["--top-module", ctx.attr.top_module]
    args += [src.path for src in ctx.files.srcs]
    args += ["--Mdir", obj_dir.basename]

    trans_srcs = get_transitive_srcs(ctx.files.srcs, ctx.attr.deps)
    args += [src.path for src in trans_srcs.to_list()]

    trans_filelists = get_transitive_filelists(ctx.files.filelists, ctx.attr.deps)
    filelists = [filelist for filelist in trans_filelists.to_list()]

    trans_data = get_transitive_data(ctx.files.data, ctx.attr.deps)
    verilog_read_data = [data for data in trans_data.to_list()]

    if filelists:
        args += ["-f %s" % filelist.path for filelist in filelists]
        local = True
    else:
        local = ctx.attr.local

    ctx.actions.run_shell(
        outputs = [obj_dir, executable],
        inputs = ctx.files.srcs + ctx.files.hdrs + filelists + verilog_read_data,
        command = "verilator %s && \
                    make -j -C %s -f V%s.mk && \
                    cp -r %s %s && \
                    cp %s/V%s %s" % (" ".join(args), obj_dir.basename, ctx.attr.top_module, obj_dir.basename, obj_dir.path, obj_dir.basename, ctx.attr.top_module, executable.path),
        use_default_shell_env = True,
        execution_requirements = {"local": str(local)},
    )

    runfiles = ctx.runfiles(files = [obj_dir] + filelists + verilog_read_data)
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

    return [DefaultInfo(files = depset(out_files))]

example = rule(
    implementation = _example_impl,
    attrs = {
        "srcs": attr.string_list(),
        "includes": attr.string_list(
            default = ["."],
        ),
    },
)

script_template = """\
#!/usr/bin/env bash
while read file; do
    echo "copy $file to {COPY_DIR}/$file"
    cp $file {COPY_DIR}
done
"""

def _verilog_library_impl(ctx):
    trans_srcs = get_transitive_srcs(ctx.files.srcs, ctx.attr.deps)
    trans_filelists = get_transitive_filelists(ctx.files.filelists, ctx.attr.deps)
    trans_data = get_transitive_data(ctx.files.data, ctx.attr.deps)
    return [
        VerilogInfo(srcs = trans_srcs, filelists = trans_filelists, data = trans_data),
        DefaultInfo(files = trans_srcs),
    ]

    #return [
    #    VerilogInfo(
    #        #srcs = depset(ctx.attr.srcs),
    #        srcs = ctx.attr.srcs,
    #        #includes = depset(ctx.attr.includes),
    #        #filelists = depset(ctx.attr.filelists),
    #        #data = depset(ctx.attr.data),
    #    ),
    #]

verilog_library = rule(
    implementation = _verilog_library_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = False,
            allow_files = ["v", "sv", "sva"],
        ),
        "includes": attr.label_list(
            allow_files = ["v", "vh", "sv", "svh", "sva", "h"],
        ),
        "filelists": attr.label_list(
            allow_files = True,
        ),
        "data": attr.label_list(
            allow_files = True,
        ),
        "deps": attr.label_list(),
    },
)
