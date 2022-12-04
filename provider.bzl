"""System Verilog provider"""

VerilogInfo = provider(
    doc = "list of Verilog files.",
    fields = {
        "srcs": "depset of Verilog files",
        "includes": "depset of include directories",
        "filelists": "depset of filelists",
        "data": "depset of data files"
    },
)

def get_transitive_srcs(srcs, deps):
    return depset(
        srcs,
        transitive = [dep[VerilogInfo].srcs for dep in deps]
    )

def get_transitive_includes(includes, deps):
    return depset(
        includes,
        transitive = [dep[VerilogInfo].includes for dep in deps],
    )

def get_transitive_filelists(filelists, deps):
    return depset(
        filelists,
        transitive = [dep[VerilogInfo].filelists for dep in deps],
    )

def get_transitive_data(data, deps):
    return depset(
        data,
        transitive = [dep[VerilogInfo].data for dep in deps],
    )

def _verilog_library_impl(ctx):
    trans_srcs = get_transitive_srcs(ctx.files.srcs, ctx.attr.deps)
    trans_includes = get_transitive_includes(ctx.files.includes, ctx.attr.deps)
    trans_filelists = get_transitive_filelists(ctx.files.filelists, ctx.attr.deps)
    trans_data = get_transitive_data(ctx.files.data, ctx.attr.deps)

    runfiles = ctx.runfiles(
        files = ctx.files.srcs
            + ctx.files.includes
            + ctx.files.filelists
            + ctx.files.data
    )

    return [
        VerilogInfo(
            srcs = trans_srcs,
            includes = trans_includes,
            filelists = trans_filelists,
            data = trans_data,
        ),
        DefaultInfo(runfiles = runfiles),
    ]

verilog_library = rule(
    implementation = _verilog_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = ["v", "sv", "sva"]),
        "includes": attr.label_list(allow_files = True),
        "filelists": attr.label_list(allow_files = True),
        "data": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
    },
)
