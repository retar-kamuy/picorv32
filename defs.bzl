"""Rule for verilator"""

load(":provider.bzl", "VerilogInfo", "get_transitive_srcs", "get_transitive_includes", "get_transitive_filelists", "get_transitive_data")

#VerilogInfo = provider(
#    doc = "list of Verilog files.",
#    fields = {
#        "srcs": "depset of Verilog files",
#        "includes": "depset of include directories",
#        "filelists": "depset of filelists",
#        "data": "depset of data files"
#    },
#)

#def get_transitive_srcs(srcs, deps):
#    return depset(
#        srcs,
#        transitive = [dep[VerilogInfo].srcs for dep in deps]
#    )
#
#def get_transitive_includes(includes, deps):
#    return depset(
#        includes,
#        transitive = [dep[VerilogInfo].includes for dep in deps],
#    )
#
#def get_transitive_filelists(filelists, deps):
#    return depset(
#        filelists,
#        transitive = [dep[VerilogInfo].filelists for dep in deps],
#    )
#
#def get_transitive_data(data, deps):
#    return depset(
#        data,
#        transitive = [dep[VerilogInfo].data for dep in deps],
#    )

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

    trans_includes = get_transitive_includes(ctx.files.includes, ctx.attr.deps)
    includes = [include for include in trans_includes.to_list()]

    args += ["+incdir+%s" % include.path for include in includes]

    trans_filelists = get_transitive_filelists(ctx.files.filelists, ctx.attr.deps)
    filelists = [filelist for filelist in trans_filelists.to_list()]

    if filelists:
        args += ["-f %s" % filelist for filelist in filelists]
        local = True
    else:
        local = ctx.attr.local

    trans_data = get_transitive_data(ctx.files.data, ctx.attr.deps)
    verilog_read_data = [data for data in trans_data.to_list()]

    ctx.actions.run_shell(
        outputs = [obj_dir, executable],
        inputs = ctx.files.srcs + ctx.files.hdrs + includes + filelists + verilog_read_data,
        command = "verilator %s && \
                    make -j -C %s -f V%s.mk && \
                    cp -r %s %s && \
                    cp %s/V%s %s" % (" ".join(args), obj_dir.basename, ctx.attr.top_module, obj_dir.basename, obj_dir.path, obj_dir.basename, ctx.attr.top_module, executable.path),
        use_default_shell_env = True,
        execution_requirements = {"local": str(local)},
    )

    runfiles = ctx.runfiles(
        files = ctx.files.srcs
            + ctx.files.filelists
            + ctx.files.hdrs
            + ctx.files.includes
            + ctx.files.data
    )

    transitive_runfiles = []
    for runfiles_attr in (
        ctx.attr.deps,
    ):
        for target in runfiles_attr:
            transitive_runfiles.append(target[DefaultInfo].default_runfiles)

    runfiles = runfiles.merge_all(transitive_runfiles)
    return [DefaultInfo(executable = executable, runfiles = runfiles)]

verilator = rule(
    implementation = _verilator_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = ["v", "sv", "sva", "c", "cc", "cpp"]),
        "filelists": attr.label_list(mandatory = False),
        "hdrs": attr.label_list(allow_files = ["h", "hpp"]),
        "includes": attr.label_list(allow_files = True),
        "arguments": attr.string_list(),
        "top_module": attr.string(),
        "data": attr.label_list(allow_files = True),
        "local": attr.bool(default = False),
        "deps": attr.label_list(),
    },
    executable = True,
)

#def _verilog_library_impl(ctx):
#    trans_srcs = get_transitive_srcs(ctx.files.srcs, ctx.attr.deps)
#    trans_includes = get_transitive_includes(ctx.files.includes, ctx.attr.deps)
#    trans_filelists = get_transitive_filelists(ctx.files.filelists, ctx.attr.deps)
#    trans_data = get_transitive_data(ctx.files.data, ctx.attr.deps)
#
#    runfiles = ctx.runfiles(
#        files = ctx.files.srcs
#            + ctx.files.includes
#            + ctx.files.filelists
#            + ctx.files.data
#    )
#
#    return [
#        VerilogInfo(
#            srcs = trans_srcs,
#            includes = trans_includes,
#            filelists = trans_filelists,
#            data = trans_data,
#        ),
#        DefaultInfo(runfiles = runfiles),
#    ]
#
#verilog_library = rule(
#    implementation = _verilog_library_impl,
#    attrs = {
#        "srcs": attr.label_list(allow_files = ["v", "sv", "sva"]),
#        "includes": attr.label_list(allow_files = True),
#        "filelists": attr.label_list(allow_files = True),
#        "data": attr.label_list(allow_files = True),
#        "deps": attr.label_list(),
#    },
#)
