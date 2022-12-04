"""Rule for verilator"""

load(":provider.bzl", "get_transitive_srcs", "get_transitive_includes", "get_transitive_filelists", "get_transitive_data")

script_template = """\
verilator {ARGUMENTS} --top-module {TOP_MODULE} {SRCS} {INCDIRS} --Mdir {MDIR}
make -j -C {MDIR} -f V{TOP_MODULE}.mk
mv {MDIR} {MDIR_PATH}
cp {MDIR_PATH}/V{TOP_MODULE} {EXECUTABLE}\
"""

def _verilator_impl(ctx):
    make_dir = ctx.actions.declare_file(ctx.label.name)
    executable = ctx.actions.declare_file(ctx.attr.top_module)

    trans_srcs = get_transitive_srcs(ctx.files.srcs, ctx.attr.deps)
    srcs = [src.path for src in trans_srcs.to_list()]

    trans_includes = get_transitive_includes(ctx.files.includes, ctx.attr.deps)
    includes = [include for include in trans_includes.to_list()]

    trans_filelists = get_transitive_filelists(ctx.files.filelists, ctx.attr.deps)
    filelists = [filelist for filelist in trans_filelists.to_list()]

    if filelists:
        srcs += ["-f %s" % filelist for filelist in filelists]
        local = True
    else:
        local = ctx.attr.local

    trans_data = get_transitive_data(ctx.files.data, ctx.attr.deps)
    verilog_read_data = [data for data in trans_data.to_list()]

    script_content = script_template.format(
        ARGUMENTS = " ".join(ctx.attr.arguments),
        TOP_MODULE = ctx.attr.top_module,
        SRCS = " ".join(srcs),
        INCDIRS = " ".join(["-I %s" % include.path for include in includes]),
        MDIR = make_dir.short_path,
        MDIR_PATH = make_dir.path,
        EXECUTABLE = executable.path,
    )

    ctx.actions.run_shell(
        outputs = [make_dir, executable],
        inputs = ctx.files.srcs + ctx.files.hdrs + includes + filelists + verilog_read_data,
        command = script_content,
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
